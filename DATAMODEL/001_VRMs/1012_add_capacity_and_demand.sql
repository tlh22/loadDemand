
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
	check_exists BOOLEAN;

BEGIN

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
    WHERE a."VehicleTypeID" = b."Code"
    AND a."GeometryID" = NEW."GeometryID"
    AND a."SurveyID" = NEW."SurveyID";

    NEW."Demand" = demand;

    -- Capacity from Supply
	SELECT "Capacity", "RestrictionTypeID"   -- what happens if field does not exist?
    INTO Supply_Capacity, RestrictionTypeID
	FROM mhtc_operations."Supply"
	WHERE "GeometryID" = NEW."GeometryID";

    -- Consider controls
	IF (RestrictionTypeID = 201 OR RestrictionTypeID = 221 OR RestrictionTypeID = 224 OR   -- SYLs
		RestrictionTypeID = 217 OR RestrictionTypeID = 222 OR RestrictionTypeID = 226 OR   -- SRLs
		RestrictionTypeID = 227 OR RestrictionTypeID = 228 OR RestrictionTypeID = 220      -- Unmarked within PPZ
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

	-- TODO: dual restrictions ...
	
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

