
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "SupplyCapacity" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "CapacityAtTimeOfSurvey" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Stress" double precision;


-- set up trigger for demand and stress

CREATE OR REPLACE FUNCTION "demand"."update_demand_vrms"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
	 --vehicleLength real := 0.0;
	 --vehicleWidth real := 0.0;
	 --motorcycleWidth real := 0.0;
	 restrictionLength real := 0.0;

    Supply_Capacity INTEGER := 0;
    Capacity INTEGER := 0;
    demand REAL := 0;
	NrBaysSuspended INTEGER := 0;
	RestrictionTypeID INTEGER;

	controlled BOOLEAN;
	vrm_survey BOOLEAN;
	check_exists BOOLEAN;
	
	check_dual_restrictions_exists BOOLEAN;

    primary_geometry_id VARCHAR (12);
    secondary_geometry_id VARCHAR (12);
    time_period_id INTEGER;

BEGIN

	-- Check that we are dealing with VRMs
	SELECT EXISTS INTO check_exists (
	SELECT FROM
		pg_tables
	WHERE
		schemaname = 'demand' AND
		tablename  = 'Surveys_VRMs'
	) ;

	IF check_exists THEN

		SELECT EXISTS
		(SELECT 1
		FROM demand."Surveys_VRMs" sv
		WHERE sv."SurveyID" = NEW."SurveyID")
		INTO vrm_survey;
		
		IF vrm_survey IS FALSE OR vrm_survey IS NULL THEN
			RETURN NEW;
		END IF;

	END IF;


    -- NrBaysSuspended
    SELECT "NrBaysSuspended"
    INTO NrBaysSuspended
    FROM demand."RestrictionsInSurveys"
    WHERE "GeometryID" = NEW."GeometryID"
    AND "SurveyID" = NEW."SurveyID";

    -- Demand from VRMs
    demand = 0.0;
    
    SELECT COALESCE(SUM("PCU"), 0.0)
    INTO demand
    FROM demand."VRMs" a, "demand_lookups"."VehicleTypes" b
    WHERE COALESCE(a."VehicleTypeID", 0) = b."Code"
    AND a."GeometryID" = NEW."GeometryID"
    AND a."SurveyID" = NEW."SurveyID";

    NEW."Demand" = demand;

    -- Capacity from Supply
	SELECT "Capacity", "RestrictionTypeID"   -- what happens if field does not exist?
    INTO Supply_Capacity, RestrictionTypeID
	FROM mhtc_operations."Supply"
	WHERE "GeometryID" = NEW."GeometryID";
	
	-- Check PCU value for MCL/PCL bays
	IF (RestrictionTypeID = 117 OR RestrictionTypeID = 118 OR   -- MCLs
		RestrictionTypeID = 116 OR RestrictionTypeID = 119 OR RestrictionTypeID = 168 OR 
		RestrictionTypeID = 169       -- PCLs
		) THEN
		
		RAISE NOTICE '--- MCL/PCL bay - changing demand values ...';
		
		SELECT COALESCE(SUM("PCUinSameTypeBay"), 0.0)
		INTO demand
		FROM demand."VRMs" a, "demand_lookups"."VehicleTypes" b
		WHERE COALESCE(a."VehicleTypeID", 0) = b."Code"
		AND a."GeometryID" = NEW."GeometryID"
		AND a."SurveyID" = NEW."SurveyID";
		
	END IF;
	
    -- Consider controls
	IF (RestrictionTypeID = 201 OR RestrictionTypeID = 221 OR RestrictionTypeID = 224 OR   -- SYLs
		RestrictionTypeID = 217 OR RestrictionTypeID = 222 OR RestrictionTypeID = 226 OR   -- SRLs
		RestrictionTypeID = 227 OR RestrictionTypeID = 228 OR RestrictionTypeID = 220 OR   -- Unmarked within PPZ
		RestrictionTypeID = 203 OR RestrictionTypeID = 206 OR RestrictionTypeID = 207 OR RestrictionTypeID = 208     -- SKC
		) THEN

        -- Need to check whether or not effected by control hours

        RAISE NOTICE '--- considering capacity for (%); survey (%) ', NEW."GeometryID", NEW."SurveyID";

        SELECT EXISTS INTO check_exists (
            SELECT FROM
                pg_tables
            WHERE
                schemaname = 'demand' AND
                tablename  = 'TimePeriodsControlledDuringSurveyHours'
            ) ;

        IF check_exists THEN

            SELECT "Controlled"
            INTO controlled
            FROM mhtc_operations."Supply" s, demand."TimePeriodsControlledDuringSurveyHours" t
            WHERE s."GeometryID" = NEW."GeometryID"
            AND s."NoWaitingTimeID" = t."TimePeriodID"
            AND t."SurveyID" = NEW."SurveyID";

            IF controlled THEN
                RAISE NOTICE '*****--- capacity set to 0 ...';
                Supply_Capacity = 0.0;
            END IF;

        END IF;

	END IF;

	-- Now consider dual restrictions

    SELECT EXISTS INTO check_dual_restrictions_exists (
    SELECT FROM
        pg_tables
    WHERE
        schemaname = 'mhtc_operations' AND
        tablename  = 'DualRestrictions'
    ) ;

    IF check_dual_restrictions_exists THEN
        -- check for primary

        SELECT d."GeometryID", "LinkedTo", COALESCE("TimePeriodID", "NoWaitingTimeID") AS "ControlledTimePeriodID"
        INTO secondary_geometry_id, primary_geometry_id, time_period_id
        FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d
        WHERE s."GeometryID" = d."GeometryID"
        AND d."LinkedTo" = NEW."GeometryID";

        IF primary_geometry_id IS NOT NULL THEN

            -- restriction is "primary". Need to check whether or not the linked restriction is active
            RAISE NOTICE '*****--- % Primary restriction. Checking time period % ...', NEW."GeometryID", time_period_id;

            SELECT "Controlled"
            INTO controlled
            FROM demand."TimePeriodsControlledDuringSurveyHours" t
            WHERE t."TimePeriodID" = time_period_id
            AND t."SurveyID" = NEW."SurveyID";

            -- TODO: Deal with multiple secondary bays ...

            IF controlled THEN
                RAISE NOTICE '*****--- Primary restriction. Setting capacity set to 0 ...';
                Supply_Capacity = 0.0;
            END IF;

        END IF;

        -- Now check for secondary

        SELECT d."GeometryID", "LinkedTo", COALESCE("TimePeriodID", "NoWaitingTimeID") AS "ControlledTimePeriodID"
        INTO secondary_geometry_id, primary_geometry_id, time_period_id
        FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d
        WHERE s."GeometryID" = d."GeometryID"
        AND d."GeometryID" = NEW."GeometryID";

        IF secondary_geometry_id IS NOT NULL THEN

            -- restriction is "secondary". Need to check whether or not it is active
            RAISE NOTICE '*****--- % Secondary restriction. Checking time period % ...', NEW."GeometryID", time_period_id;

            SELECT "Controlled"
            INTO controlled
            FROM demand."TimePeriodsControlledDuringSurveyHours" t
            WHERE t."TimePeriodID" = time_period_id
            AND t."SurveyID" = NEW."SurveyID";

            IF NOT controlled OR controlled IS NULL THEN
                RAISE NOTICE '*****--- Secondary restriction. Setting capacity set to 0 ...';
                Supply_Capacity = 0.0;
            END IF;

        END IF;
    END IF;
	
    Capacity = COALESCE(Supply_Capacity::float, 0.0) - COALESCE(NrBaysSuspended::float, 0.0);
    IF Capacity < 0.0 THEN
        Capacity = 0.0;
    END IF;
    NEW."SupplyCapacity" = Supply_Capacity;
    NEW."CapacityAtTimeOfSurvey" = Capacity;

    IF NEW."CapacityAtTimeOfSurvey" <= 0.0 THEN
        IF NEW."Demand" > 0.0 THEN
            NEW."Stress" = 1.0;
        ELSE
            NEW."Stress" = 0.0;
        END IF;
    ELSE
        NEW."Stress" = NEW."Demand"::float / NEW."CapacityAtTimeOfSurvey"::float;
    END IF;

	RETURN NEW;

END;
$$;

-- create trigger

DROP TRIGGER IF EXISTS update_demand ON demand."RestrictionsInSurveys";
CREATE TRIGGER "update_demand" BEFORE INSERT OR UPDATE ON "demand"."RestrictionsInSurveys" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand_vrms"();

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";

