/***
 *  Initially created for Camden - sections
 ***/

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "Demand" double precision;
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "Demand_Standard" double precision; -- This is the count of all vehicles in the main count tab
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "Demand_Other" double precision;  -- This is the count fo all vehicles in the suspensions tab
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "Stress" double precision;

-- reset NrBaysSuspended values

UPDATE demand."Demand_Merged"
SET ncars = NULL
WHERE ncars = '';

-- Step 2: calculate demand values using trigger

-- set up trigger for demand and stress

CREATE OR REPLACE FUNCTION "demand"."update_demand_sections"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
	 vehicleLength real := 0.0;
	 vehicleWidth real := 0.0;
	 motorcycleWidth real := 0.0;
	 restrictionLength real := 0.0;
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
    Supply_Capacity INTEGER := 0;
    Capacity INTEGER := 0;
BEGIN

    IF vehicleLength IS NULL OR vehicleWidth IS NULL OR motorcycleWidth IS NULL THEN
        RAISE EXCEPTION 'Capacity parameters not available ...';
        RETURN OLD;
    END IF;

    SELECT "NrCars", "NrLGVs", "NrMCLs", "NrTaxis", "NrPCLs", "NrEScooters", "NrDocklessPCLs", "NrOGVs", "NrMiniBuses", "NrBuses", "NrSpaces",
        "Notes", "DoubleParkingDetails",
        "NrCars_Suspended", "NrLGVs_Suspended", "NrMCLs_Suspended", "NrTaxis_Suspended", "NrPCLs_Suspended", "NrEScooters_Suspended",
        "NrDocklessPCLs_Suspended", "NrOGVs_Suspended", "NrMiniBuses_Suspended", "NrBuses_Suspended"
    INTO
        NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, NrSpaces,
        Notes, DoubleParkingDetails,
        NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended,
        NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended
	FROM demand."Counts"
	WHERE "GeometryID" = NEW."GeometryID"
	AND "SurveyID" = NEW."SurveyID";

	SELECT "CapacityFromDemand"
    INTO Supply_Capacity
	FROM mhtc_operations."Supply"
	WHERE "GeometryID" = NEW."GeometryID";

    NEW."Demand" = COALESCE(NrCars::float, 0.0) +
        COALESCE(NrLGVs::float, 0.0) +
        COALESCE(NrMCLs::float, 0.0)*0.33 +
        (COALESCE(NrOGVs::float, 0.0) + COALESCE(NrMiniBuses::float, 0.0) + COALESCE(NrBuses::float, 0.0))*1.5 +
        COALESCE(NrTaxis::float, 0.0) +
        -- include suspended vehicles
        COALESCE(NrCars_Suspended::float, 0.0) +
        COALESCE(NrLGVs_Suspended::float, 0.0) +
        COALESCE(NrMCLs_Suspended::float, 0.0)*0.33 +
        (COALESCE(NrOGVs_Suspended::float, 0) + COALESCE(NrMiniBuses_Suspended::float, 0) + COALESCE(NrBuses_Suspended::float, 0))*1.5 +
        COALESCE(NrTaxis_Suspended::float, 0);

    NEW."Demand_Standard" = COALESCE(NrCars::float, 0.0) +
        COALESCE(NrLGVs::float, 0.0) +
        COALESCE(NrMCLs::float, 0.0)*0.33 +
        (COALESCE(NrOGVs::float, 0.0) + COALESCE(NrMiniBuses::float, 0.0) + COALESCE(NrBuses::float, 0.0))*1.5 +
        COALESCE(NrTaxis::float, 0.0);

    NEW."Demand_Other" = COALESCE(NrCars_Suspended::float, 0.0) +
        COALESCE(NrLGVs_Suspended::float, 0.0) +
        COALESCE(NrMCLs_Suspended::float, 0.0)*0.33 +
        (COALESCE(NrOGVs_Suspended::float, 0) + COALESCE(NrMiniBuses_Suspended::float, 0) + COALESCE(NrBuses_Suspended::float, 0))*1.5 +
        COALESCE(NrTaxis_Suspended::float, 0);

    /* What to do about suspensions */

    Capacity = Supply_Capacity -  COALESCE(NEW."NrBaysSuspended", 0.0);

    IF Capacity <= 0.0 THEN
        IF NEW."Demand" > 0.0 THEN
            NEW."Stress" = 1.0;
        ELSE
            NEW."Stress" = 0.0;
        END IF;
    ELSE
        NEW."Stress" = NEW."Demand"::float / Capacity::float;
    END IF;

	RETURN NEW;

END;
$$;

-- create trigger

DROP TRIGGER IF EXISTS update_demand ON demand."RestrictionsInSurveys";
CREATE TRIGGER "update_demand" BEFORE INSERT OR UPDATE ON "demand"."RestrictionsInSurveys" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand_sections"();

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";


