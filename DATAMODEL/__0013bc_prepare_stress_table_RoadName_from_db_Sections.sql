/*
To create stress maps, steps are:
1.	Check that demand fields are correct
2. Prepare view with query below
*/



-- Step 1: Add new fields



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
BEGIN

    IF vehicleLength IS NULL OR vehicleWidth IS NULL OR motorcycleWidth IS NULL THEN
        RAISE EXCEPTION 'Capacity parameters not available ...';
        RETURN OLD;
    END IF;

    NEW."Demand_ALL" = COALESCE("NrCars"::float, 0.0) +
        COALESCE("NrLGVs"::float, 0.0) +
        COALESCE("NrMCLs"::float, 0.0)*0.33 +
        (COALESCE("NrOGVs"::float, 0.0) + COALESCE("NrMiniBuses"::float, 0.0) + COALESCE("NrBuses"::float, 0.0))*1.5 +
        COALESCE("NrTaxis"::float, 0.0) +
        -- include suspended vehicles
        COALESCE("NrCars_Suspended"::float, 0.0) +
        COALESCE("NrLGVs_Suspended"::float, 0.0) +
        COALESCE("NrMCLs_Suspended"::float, 0.0)*0.33 +
        (COALESCE("NrOGVs_Suspended"::float, 0) + COALESCE("NrMiniBuses_Suspended"::float, 0) + COALESCE("NrBuses_Suspended"::float, 0))*1.5 +
        COALESCE("NrTaxis_Suspended"::float, 0);


   SUM(COALESCE("NrCars"::float, 0.0) +
	COALESCE("NrLGVs"::float, 0.0) +
    COALESCE("NrMCLs"::float, 0.0)*0.33 +
    (COALESCE("NrOGVs"::float, 0) + COALESCE("NrMiniBuses"::float, 0) + COALESCE("NrBuses"::float, 0))*1.5 +
    COALESCE("NrTaxis"::float, 0)) As "Demand",
    SUM("NrSpaces") AS "Spaces",
    SUM(COALESCE("NrCars_Suspended"::float, 0.0) +
	COALESCE("NrLGVs_Suspended"::float, 0.0) +
    COALESCE("NrMCLs_Suspended"::float, 0.0)*0.33 +
    (COALESCE("NrOGVs_Suspended"::float, 0) + COALESCE("NrMiniBuses_Suspended"::float, 0) + COALESCE("NrBuses_Suspended"::float, 0))*1.5 +
    COALESCE("NrTaxis_Suspended"::float, 0)) As "Other_Demand",
    SUM(COALESCE("NrCars"::float, 0.0) +
	COALESCE("NrLGVs"::float, 0.0) +
    COALESCE("NrMCLs"::float, 0.0)*0.33 +
    (COALESCE("NrOGVs"::float, 0) + COALESCE("NrMiniBuses"::float, 0) + COALESCE("NrBuses"::float, 0))*1.5 +
    COALESCE("NrTaxis"::float, 0) +
    COALESCE("NrSpaces"::float, 0.0) +
    COALESCE("NrCars_Suspended"::float, 0.0) +
	COALESCE("NrLGVs_Suspended"::float, 0.0) +
    COALESCE("NrMCLs_Suspended"::float, 0.0)*0.33 +
    (COALESCE("NrOGVs_Suspended"::float, 0) + COALESCE("NrMiniBuses_Suspended"::float, 0) + COALESCE("NrBuses_Suspended"::float, 0))*1.5 +
    COALESCE("NrTaxis_Suspended"::float, 0)) As "Total"


    /* What to do about suspensions */

    CASE
        WHEN NEW."CapacityFromDemand" = 0 THEN
            CASE
                WHEN NEW."Demand" > 0.0 THEN NEW."Stress" = 100.0;
                ELSE NEW."Stress" = 0.0;
            END CASE;
        ELSE
            CASE
                WHEN NEW."CapacityFromDemand"::float - COALESCE(NEW."sbays"::float, 0.0) > 0.0 THEN
                    NEW."Stress" = NEW."Demand" / (NEW."CapacityFromDemand"::float - COALESCE(NEW."sbays"::float, 0.0)) * 100.0;
                ELSE
                    CASE
                        WHEN NEW."Demand" > 0.0 THEN NEW."Stress" = 100.0;
                        ELSE NEW."Stress" = 0.0;
                    END CASE;
            END CASE;
    END CASE;

	RETURN NEW;

END;
$$;

-- create trigger

DROP TRIGGER IF EXISTS update_demand ON demand."Counts";
CREATE TRIGGER "update_demand" BEFORE INSERT OR UPDATE ON "demand"."Counts" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand_sections"();

-- trigger trigger

UPDATE "demand"."Counts" SET "ReasonForSuspension" = "ReasonForSuspension";

-- Step 3: output demand

SELECT
d."SurveyID", s."SurveyDay" As "Survey Day", s."BeatStartTime" || '-' || s."BeatEndTime" As "Survey Time", d."GeometryID",
       (COALESCE("ncars"::float, 0)+COALESCE("ntaxis"::float, 0)) As "Nr Cars", COALESCE("nlgvs"::float, 0) As "Nr LGVs",
       COALESCE("nmcls"::float, 0) AS "Nr MCLs", COALESCE("nogvs"::float, 0) AS "Nr OGVs", COALESCE("nbuses"::float, 0) AS "Nr Buses",
       COALESCE("nspaces"::float, 0) AS "Nr Spaces",
       COALESCE(d."sbays"::integer, 0) AS "Bays Suspended", d."snotes" AS "Suspension Notes", "Demand" As "Demand",
             d."nnotes" AS "Surveyor Notes",
        su."RestrictionTypeID", su."Capacity"

FROM --"SYL_AllowableTimePeriods" syls,
      demand."Demand_Merged" d, demand."Surveys" s, mhtc_operations."Supply" su  -- include Supply to ensure that only current supply elements are included
WHERE s."SurveyID" = d."SurveyID"
AND d."GeometryID" = su."GeometryID"
ORDER BY  "GeometryID", d."SurveyID"




-- Now prepare stress

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults";

CREATE MATERIALIZED VIEW demand."StressResults"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    --s."name1" AS "RoadName",
    s."roadName1_Name" AS "RoadName",
    s.geom,
    d."SurveyID", d."Stress" AS "Stress", "Demand", "Capacity"
	FROM highways_network."roadlink" s,
	(
	SELECT "SurveyID", "RoadName", "Demand", "Capacity",
        CASE
            WHEN "Capacity" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Capacity"::float > 0.0 THEN
                        "Demand" / ("Capacity"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", SUM(s."CapacityFromDemand") AS "Capacity", SUM(d."Demand") AS "Demand"
    FROM mhtc_operations."Supply" s, demand."Counts" d
    WHERE s."GeometryID" = d."GeometryID"
    AND s."RestrictionTypeID" NOT IN (117, 118)  -- Motorcycle bays
    AND s."SurveyArea" IS NOT NULL
	AND LENGTH("RoadName") > 0
    GROUP BY d."SurveyID", s."RoadName"
    ORDER BY s."RoadName", d."SurveyID" ) a
    ) d
	--WHERE s."name1" = d."RoadName"
	WHERE s."roadName1_Name" = d."RoadName"
WITH DATA;

ALTER TABLE demand."StressResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_sid"
    ON demand."StressResults" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults";


--
SELECT "SurveyID", "RoadName", "Capacity", "Demand",
        CASE
            WHEN "Capacity" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Capacity"::float > 0.0 THEN
                        "Demand" / ("Capacity"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", SUM(s."Capacity") AS "Capacity", SUM(d."Demand") AS "Demand"
    FROM mhtc_operations."Supply" s, demand."Demand_Merged" d
    WHERE s."GeometryID" = d."GeometryID"
    AND s."RestrictionTypeID" NOT IN (117, 118)  -- Motorcycle bays
    GROUP BY d."SurveyID", s."RoadName"
    ORDER BY s."RoadName", d."SurveyID" ) a


-- Stress from vrms_final

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults";

CREATE MATERIALIZED VIEW demand."StressResults"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    s."name1" AS "RoadName", s.geom,
    d."SurveyID", d."Stress" AS "Stress"
	FROM highways_network."roadlink" s,
	(
	SELECT "SurveyID", "RoadName",
        CASE
            WHEN "Capacity" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Capacity"::float > 0.0 THEN
                        "Demand" / ("Capacity"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", SUM(s."Capacity") AS "Capacity", SUM(demand."Demand") AS "Demand"
    FROM mhtc_operations."Supply" s, (
        SELECT a."SurveyID", a."GeometryID", SUM("VehicleTypes"."PCU") AS "Demand"
        FROM (demand."VRMs_Final" AS a
        LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
        GROUP BY a."SurveyID", a."GeometryID"
    ) demand
    WHERE s."GeometryID" = demand."GeometryID"
    AND s."RestrictionTypeID" NOT IN (117, 118)  -- Motorcycle bays
    GROUP BY demand."SurveyID", s."RoadName"
    ORDER BY s."RoadName", demand."SurveyID" ) a
    ) d
	WHERE s."name1" = d."RoadName"
WITH DATA;

ALTER TABLE demand."StressResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_sid"
    ON demand."StressResults" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults";
