-- set up fields in RiS

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCars" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxis" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrPCLs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrEScooters" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrDocklessPCLs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBuses" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBuses" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrSpaces" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Notes" character varying(10000);

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "DoubleParkingDetails" character varying;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCars_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxis_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrPCLs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrEScooters_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrDocklessPCLs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBuses_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBuses_Suspended" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCarsIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCarsParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVsIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVsParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLsIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLsParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxisIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxisParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVsIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVsParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBusesIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBusesParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCarsWithDisabledBadgeParkedInPandD" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "MCL_Notes" character varying(10000);
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Supply_Notes" character varying(10000);
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Parking_Notes" character varying(10000);

-- Add relevant calculated fields

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedAvailableSpaces" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedCapacityAtTimeOfSurvey" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedStress" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "SupplyCapacity" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "CapacityAtTimeOfSurvey" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Stress" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Suspended" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Waiting" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Idling" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_ParkedIncorrectly" double precision;
	
-- And now for Counts
    
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "MCL_Notes" character varying(10000);
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "Supply_Notes" character varying(10000);
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "Parking_Notes" character varying(10000);
    
-- Now copy

UPDATE demand."RestrictionsInSurveys" AS RiS
SET "NrCars"=c."NrCars", "NrLGVs"=c."NrLGVs", "NrMCLs"=c."NrMCLs", "NrTaxis"=c."NrTaxis", "NrPCLs"=c."NrPCLs",
"NrEScooters"=c."NrEScooters", "NrDocklessPCLs"=c."NrDocklessPCLs", "NrOGVs"=c."NrOGVs", "NrMiniBuses"=c."NrMiniBuses", "NrBuses"=c."NrBuses", "NrSpaces"=c."NrSpaces",
"Notes"=c."Notes", "DoubleParkingDetails"=c."DoubleParkingDetails", "NrCars_Suspended"=c."NrCars_Suspended", "NrLGVs_Suspended"=c."NrLGVs_Suspended", "NrMCLs_Suspended"=c."NrMCLs_Suspended",
"NrTaxis_Suspended"=c."NrTaxis_Suspended", "NrPCLs_Suspended"=c."NrPCLs_Suspended", "NrEScooters_Suspended"=c."NrEScooters_Suspended", "NrDocklessPCLs_Suspended"=c."NrDocklessPCLs_Suspended",
"NrOGVs_Suspended"=c."NrOGVs_Suspended", "NrMiniBuses_Suspended"=c."NrMiniBuses_Suspended", "NrBuses_Suspended"=c."NrBuses_Suspended", "NrCarsIdling"=c."NrCarsIdling",
"NrCarsParkedIncorrectly"=c."NrCarsParkedIncorrectly", "NrLGVsIdling"=c."NrLGVsIdling", "NrLGVsParkedIncorrectly"=c."NrLGVsParkedIncorrectly", "NrMCLsIdling"=c."NrMCLsIdling", "NrMCLsParkedIncorrectly"=c."NrMCLsParkedIncorrectly", 
"NrTaxisIdling"=c."NrTaxisIdling", "NrTaxisParkedIncorrectly"=c."NrTaxisParkedIncorrectly", "NrOGVsIdling"=c."NrOGVsIdling", "NrOGVsParkedIncorrectly"=c."NrOGVsParkedIncorrectly", 
"NrMiniBusesIdling"=c."NrMiniBusesIdling", "NrMiniBusesParkedIncorrectly"=c."NrMiniBusesParkedIncorrectly", "NrBusesIdling"=c."NrBusesIdling", "NrBusesParkedIncorrectly"=c."NrBusesParkedIncorrectly", 
"NrCarsWithDisabledBadgeParkedInPandD"=c."NrCarsWithDisabledBadgeParkedInPandD", "MCL_Notes"=c."MCL_Notes", "Supply_Notes"=c."Supply_Notes"
FROM demand."Counts" c
	WHERE RiS."GeometryID" = c."GeometryID"
	AND RiS."SurveyID" = c."SurveyID"
	--AND (RiS."Done" IS NULL OR RiS."Done" IS FALSE)
	;

-- Waiting vehicles

-- Waiting vehicles

ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrCarsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrLGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMCLsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrTaxisWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrOGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrBusesWaiting" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCarsWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLsWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxisWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBusesWaiting" integer;

-- Change trigger

-- set up trigger for demand and stress

CREATE OR REPLACE FUNCTION "demand"."update_demand_counts_ris"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
	 --vehicleLength real := 0.0;
	 --vehicleWidth real := 0.0;
	 --motorcycleWidth real := 0.0;
	 restrictionLength real := 0.0;
	 carPCU real := 0.0;
	 lgvPCU real := 0.0;
	 mclPCU real := 0.0;
	 ogvPCU real := 0.0;
	 busPCU real := 0.0;
	 pclPCU real := 0.0;
	 taxiPCU real := 0.0;
	 otherPCU real := 0.0;
	 minibusPCU real := 0.0;
	 docklesspclPCU real := 0.0;
	 escooterPCU real := 0.0;

	 NrCars INTEGER := 0;
	 NrLGVs INTEGER := 0;
	 NrMCLs INTEGER := 0;
	 NrTaxis INTEGER := 0;
	 NrPCLs INTEGER := 0;
	 NrEScooters INTEGER := 0;
	 NrDocklessPCLs INTEGER := 0;
	 NrOGVs INTEGER := 0;
	 NrMiniBuses INTEGER := 0;
	 NrBuses INTEGER := 0;
	 NrSpaces INTEGER := 0;
     Notes VARCHAR (10000);
     SuspensionReference VARCHAR (250);
    ReasonForSuspension VARCHAR (250);
    DoubleParkingDetails VARCHAR (250);
    NrCars_Suspended INTEGER := 0;
    NrLGVs_Suspended INTEGER := 0;
    NrMCLs_Suspended INTEGER := 0;
    NrTaxis_Suspended INTEGER := 0;
    NrPCLs_Suspended INTEGER := 0;
    NrEScooters_Suspended INTEGER := 0;
    NrDocklessPCLs_Suspended INTEGER := 0;
    NrOGVs_Suspended INTEGER := 0;
    NrMiniBuses_Suspended INTEGER := 0;
    NrBuses_Suspended INTEGER := 0;

    NrCarsWaiting INTEGER := 0;
    NrLGVsWaiting INTEGER := 0;
    NrMCLsWaiting INTEGER := 0;
    NrTaxisWaiting INTEGER := 0;
    NrOGVsWaiting INTEGER := 0;
    NrMiniBusesWaiting INTEGER := 0;
    NrBusesWaiting INTEGER := 0;

    NrCarsIdling INTEGER := 0;
    NrLGVsIdling INTEGER := 0;
    NrMCLsIdling INTEGER := 0;
    NrTaxisIdling INTEGER := 0;
    NrOGVsIdling INTEGER := 0;
    NrMiniBusesIdling INTEGER := 0;
    NrBusesIdling INTEGER := 0;

    NrCarsParkedIncorrectly INTEGER := 0;
    NrLGVsParkedIncorrectly INTEGER := 0;
    NrMCLsParkedIncorrectly INTEGER := 0;
    NrTaxisParkedIncorrectly INTEGER := 0;
    NrOGVsParkedIncorrectly INTEGER := 0;
    NrMiniBusesParkedIncorrectly INTEGER := 0;
    NrBusesParkedIncorrectly INTEGER := 0;

    NrCarsWithDisabledBadgeParkedInPandD INTEGER := 0;

    Supply_Capacity INTEGER := 0;
    Capacity INTEGER := 0;
	NrBaysSuspended INTEGER := 0;
	RestrictionTypeID INTEGER;

	controlled BOOLEAN;
	check_exists BOOLEAN;
	count_survey BOOLEAN;
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
		tablename  = 'Surveys_Counts'
	) ;

	IF check_exists THEN

		SELECT EXISTS
		(SELECT 1
		FROM demand."Counts" sv
		WHERE sv."SurveyID" = NEW."SurveyID")
		INTO count_survey;

		IF count_survey IS FALSE OR count_survey IS NULL THEN
			RETURN NEW;
		END IF;

	END IF;


    RAISE NOTICE '--- considering (%) in survey (%) ', NEW."GeometryID", NEW."SurveyID";

    ---
    select "PCU" into carPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Car';

    select "PCU" into lgvPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'LGV';

    select "PCU" into mclPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'MCL';

    select "PCU" into ogvPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'OGV';

    select "PCU" into busPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Bus';

    select "PCU" into pclPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'PCL';

    select "PCU" into taxiPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Taxi';

    select "PCU" into otherPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Other';

    select "PCU" into minibusPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Minibus';

    select "PCU" into docklesspclPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Dockless PCL';

    select "PCU" into escooterPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'E-Scooter';


    IF carPCU IS NULL OR lgvPCU IS NULL OR mclPCU IS NULL OR ogvPCU IS NULL OR busPCU IS NULL OR
       pclPCU IS NULL OR taxiPCU IS NULL OR otherPCU IS NULL OR minibusPCU IS NULL OR docklesspclPCU IS NULL OR escooterPCU IS NULL THEN
        RAISE NOTICE '--- (%); (%); (%); (%); (%); (%); (%); (%); (%); (%); (%) ', carPCU, lgvPCU, mclPCU, ogvPCU, busPCU, pclPCU, taxiPCU, otherPCU, minibusPCU, docklesspclPCU, escooterPCU;
        RAISE EXCEPTION 'PCU parameters not available ...';
        RETURN OLD;
    END IF;


	RAISE NOTICE '*****--- Getting demand details ...';

    SELECT COALESCE(RiS."NrCars", 0), COALESCE(RiS."NrLGVs", 0), COALESCE(RiS."NrMCLs", 0), COALESCE(RiS."NrTaxis", 0),
	    COALESCE(RiS."NrPCLs", 0), COALESCE(RiS."NrEScooters", 0), COALESCE(RiS."NrDocklessPCLs", 0),
	    COALESCE(RiS."NrOGVs", 0), COALESCE(RiS."NrMiniBuses", 0), COALESCE(RiS."NrBuses", 0),
	    COALESCE(RiS."NrSpaces", 0),

        -- RiS."Notes", RiS."DoubleParkingDetails",

        COALESCE(RiS."NrCars_Suspended", 0), COALESCE(RiS."NrLGVs_Suspended", 0), COALESCE(RiS."NrMCLs_Suspended", 0),
        COALESCE(RiS."NrTaxis_Suspended", 0), COALESCE(RiS."NrPCLs_Suspended", 0), COALESCE(RiS."NrEScooters_Suspended", 0),
        COALESCE(RiS."NrDocklessPCLs_Suspended", 0), COALESCE(RiS."NrOGVs_Suspended", 0),
        COALESCE(RiS."NrMiniBuses_Suspended", 0), COALESCE(RiS."NrBuses_Suspended", 0),

        COALESCE(RiS."NrCarsWaiting", 0), COALESCE(RiS."NrLGVsWaiting", 0), COALESCE(RiS."NrMCLsWaiting", 0),
        COALESCE(RiS."NrTaxisWaiting", 0), COALESCE(RiS."NrOGVsWaiting"), COALESCE(RiS."NrMiniBusesWaiting", 0),
        COALESCE(RiS."NrBusesWaiting", 0),

        COALESCE(RiS."NrCarsIdling", 0), COALESCE(RiS."NrLGVsIdling", 0), COALESCE(RiS."NrMCLsIdling", 0),
        COALESCE(RiS."NrTaxisIdling", 0), COALESCE(RiS."NrOGVsIdling", 0), COALESCE(RiS."NrMiniBusesIdling", 0),
        COALESCE(RiS."NrBusesIdling", 0),

        COALESCE(RiS."NrCarsParkedIncorrectly", 0), COALESCE(RiS."NrLGVsParkedIncorrectly", 0), COALESCE(RiS."NrMCLsParkedIncorrectly", 0),
        COALESCE(RiS."NrTaxisParkedIncorrectly", 0), COALESCE(RiS."NrOGVsParkedIncorrectly", 0), COALESCE(RiS."NrMiniBusesParkedIncorrectly", 0),
        COALESCE(RiS."NrBusesParkedIncorrectly", 0),

        COALESCE(RiS."NrCarsWithDisabledBadgeParkedInPandD", 0),

        COALESCE(RiS."NrBaysSuspended", 0)

    INTO
        NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, NrSpaces,
        --Notes, DoubleParkingDetails,
        NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended,
        NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended,

        NrCarsWaiting, NrLGVsWaiting, NrMCLsWaiting, NrTaxisWaiting, NrOGVsWaiting, NrMiniBusesWaiting, NrBusesWaiting,

        NrCarsIdling, NrLGVsIdling, NrMCLsIdling, NrTaxisIdling, NrOGVsIdling, NrMiniBusesIdling, NrBusesIdling,

        NrCarsParkedIncorrectly, NrLGVsParkedIncorrectly, NrMCLsParkedIncorrectly,
        NrTaxisParkedIncorrectly, NrOGVsParkedIncorrectly, NrMiniBusesParkedIncorrectly,
        NrBusesParkedIncorrectly,

        NrCarsWithDisabledBadgeParkedInPandD,

        NrBaysSuspended

	FROM demand."RestrictionsInSurveys" RiS
	WHERE RiS."GeometryID" = NEW."GeometryID"
	AND RiS."SurveyID" = NEW."SurveyID"
    ;

    -- From Camden where determining capacity from sections
	SELECT "Capacity", "RestrictionTypeID"   -- what happens if field does not exist?
    INTO Supply_Capacity, RestrictionTypeID
	FROM mhtc_operations."Supply"
	WHERE "GeometryID" = NEW."GeometryID";

	-- Check PCU value for MCL/PCL bays
	IF (RestrictionTypeID = 117 OR RestrictionTypeID = 118 OR   -- MCLs
		RestrictionTypeID = 119 OR RestrictionTypeID = 168 OR
		RestrictionTypeID = 169       -- PCLs
		) THEN
		RAISE NOTICE '--- MCL/PCL bay - changing PCU values FROM %; %; %; % ', mclPCU, pclPCU, docklesspclPCU, escooterPCU;
		mclPCU := 1.0;
		pclPCU := 1.0;
		docklesspclPCU := 1.0;
		escooterPCU := 1.0;
		RAISE NOTICE '--- MCL/PCL bay - changing PCU values TO %; %; %; % ', mclPCU, pclPCU, docklesspclPCU, escooterPCU;
	END IF;

    NEW."Demand" = COALESCE(NrCars::float, 0.0) * carPCU +
        COALESCE(NrLGVs::float, 0.0) * lgvPCU +
        COALESCE(NrMCLs::float, 0.0) * mclPCU +
        COALESCE(NrOGVs::float, 0.0) * ogvPCU + COALESCE(NrMiniBuses::float, 0.0) * minibusPCU + COALESCE(NrBuses::float, 0.0) * busPCU +
        COALESCE(NrTaxis::float, 0.0) * taxiPCU +
        COALESCE(NrPCLs::float, 0.0) * pclPCU +
        COALESCE(NrEScooters::float, 0.0) * escooterPCU +
        COALESCE(NrDocklessPCLs::float, 0.0) * docklesspclPCU +

        /***
        -- include suspended vehicles
        COALESCE(NrCars_Suspended::float, 0.0) * carPCU +
        COALESCE(NrLGVs_Suspended::float, 0.0) * lgvPCU +
        COALESCE(NrMCLs_Suspended::float, 0.0) * mclPCU +
        COALESCE(NrOGVs_Suspended::float, 0) * ogvPCU + COALESCE(NrMiniBuses_Suspended::float, 0) * minibusPCU + COALESCE(NrBuses_Suspended::float, 0) * busPCU +
        COALESCE(NrTaxis_Suspended::float, 0) +
        COALESCE(NrPCLs_Suspended::float, 0.0) * pclPCU +
        COALESCE(NrEScooters_Suspended::float, 0.0) * escooterPCU +
        COALESCE(NrDocklessPCLs_Suspended::float, 0.0) * docklesspclPCU +
        ***/

        COALESCE(NrCarsWaiting::float, 0.0) * carPCU +
        COALESCE(NrLGVsWaiting::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsWaiting::float, 0.0) * mclPCU +
        COALESCE(NrOGVsWaiting::float, 0) * ogvPCU + COALESCE(NrMiniBusesWaiting::float, 0) * minibusPCU + COALESCE(NrBusesWaiting::float, 0) * busPCU +
        COALESCE(NrTaxisWaiting::float, 0) * carPCU +

        COALESCE(NrCarsIdling::float, 0.0) * carPCU +
        COALESCE(NrLGVsIdling::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsIdling::float, 0.0) * mclPCU +
        COALESCE(NrOGVsIdling::float, 0) * ogvPCU + COALESCE(NrMiniBusesIdling::float, 0) * minibusPCU + COALESCE(NrBusesIdling::float, 0) * busPCU +
        COALESCE(NrTaxisIdling::float, 0) * carPCU
		+

        COALESCE(NrCarsParkedIncorrectly::float, 0.0) * carPCU +
        COALESCE(NrLGVsParkedIncorrectly::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsParkedIncorrectly::float, 0.0) * mclPCU +
        COALESCE(NrOGVsParkedIncorrectly::float, 0) * ogvPCU + COALESCE(NrMiniBusesParkedIncorrectly::float, 0) * minibusPCU + COALESCE(NrBusesParkedIncorrectly::float, 0) * busPCU +
        COALESCE(NrTaxisParkedIncorrectly::float, 0) * carPCU +

  		COALESCE(NrCarsWithDisabledBadgeParkedInPandD::float, 0.0) * carPCU

        ;

	RAISE NOTICE '*****--- demand is %. (NrCars = %) ...', NEW."Demand", NrCars;

    /***
    NEW."Demand_Standard" = COALESCE(NrCars::float, 0.0) +
        COALESCE(NrLGVs::float, 0.0) +
        COALESCE(NrMCLs::float, 0.0)*0.33 +
        (COALESCE(NrOGVs::float, 0.0) + COALESCE(NrMiniBuses::float, 0.0) + COALESCE(NrBuses::float, 0.0))*1.5 +
        COALESCE(NrTaxis::float, 0.0);

    NEW."DemandInSuspendedAreas" = COALESCE(NrCars_Suspended::float, 0.0) +
        COALESCE(NrLGVs_Suspended::float, 0.0) +
        COALESCE(NrMCLs_Suspended::float, 0.0)*0.33 +
        (COALESCE(NrOGVs_Suspended::float, 0) + COALESCE(NrMiniBuses_Suspended::float, 0) + COALESCE(NrBuses_Suspended::float, 0))*1.5 +
        COALESCE(NrTaxis_Suspended::float, 0);
    ***/

    /* What to do about suspensions */

	RAISE NOTICE '*****--- Checking SYLs ...';

	IF (RestrictionTypeID = 201 OR RestrictionTypeID = 221 OR RestrictionTypeID = 224 OR   -- SYLs
		RestrictionTypeID = 217 OR RestrictionTypeID = 222 OR RestrictionTypeID = 226 OR   -- SRLs
		RestrictionTypeID = 227 OR RestrictionTypeID = 228 OR RestrictionTypeID = 220 OR   -- Unmarked within PPZ
		RestrictionTypeID = 203 OR RestrictionTypeID = 207 OR RestrictionTypeID = 208      -- ZigZags
		) THEN

        -- Need to check whether or not effected by control hours

        RAISE NOTICE '--- checking SYL capacity for (%); survey (%) ', NEW."GeometryID", NEW."SurveyID";

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

	RAISE NOTICE '*****--- Checking dual restrictions ...';

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


	RAISE NOTICE '*****--- Finalising ...';

    Capacity = COALESCE(Supply_Capacity::float, 0.0) - COALESCE(NrBaysSuspended::float, 0.0);
    IF Capacity < 0.0 THEN
        Capacity = 0.0;
    END IF;
    NEW."SupplyCapacity" = Supply_Capacity;
    NEW."CapacityAtTimeOfSurvey" = Capacity;

    IF Capacity <= 0.0 THEN
        IF NEW."Demand" > 0.0 THEN
            NEW."Stress" = 1.0;
        ELSE
            NEW."Stress" = 0.0;
        END IF;
    ELSE
        NEW."Stress" = NEW."Demand"::float / Capacity::float;
    END IF;

	RAISE NOTICE '*****--- Demand: %; Capacity: %; Stress: % ...', NEW."Demand", NEW."CapacityAtTimeOfSurvey", NEW."Stress";

	RETURN NEW;

END;
$$;

-- create trigger

DROP TRIGGER IF EXISTS update_demand ON demand."RestrictionsInSurveys";
CREATE TRIGGER "update_demand" BEFORE INSERT OR UPDATE ON "demand"."RestrictionsInSurveys" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand_counts_ris"();

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";

