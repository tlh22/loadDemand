/**
Check the number of VRMs collected within each pass
**/

SELECT v."SurveyID", s."BeatTitle", COUNT(v."ID")
FROM demand."VRMs" v, demand."Surveys" s
WHERE v."SurveyID" = s."SurveyID"
GROUP BY v."SurveyID", s."BeatTitle"
ORDER BY v."SurveyID";


-- Use this to get break down by area - and then create a pivot table in Excel

SELECT s."SurveyID", a.name, COUNT(v."ID")
FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = r."GeometryID"
AND r."SurveyArea"::int = a.id
GROUP BY s."SurveyID", a.name
ORDER BY s."SurveyID", a.name

-- including road, GeometryID

SELECT s."SurveyID", a.name, r."RoadName", r."GeometryID", COUNT(v."ID")
FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = r."GeometryID"
AND r."SurveyArea"::int = a.id
GROUP BY s."SurveyID", a.name, r."RoadName", r."GeometryID"
ORDER BY s."SurveyID", a.name, r."RoadName", r."GeometryID"


**********
-- Check
SELECT "SurveyID",
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
FROM demand."Counts"
GROUP BY "SurveyID"
ORDER BY "SurveyID";


-- Step 1: Add new fields

ALTER TABLE demand."Demand_Merged"
    ADD COLUMN "Demand" double precision;
ALTER TABLE demand."Demand_Merged"
    ADD COLUMN "Stress" double precision;

-- Step 2: calculate demand values using trigger

-- set up trigger for demand and stress

CREATE OR REPLACE FUNCTION "demand"."update_demand"() RETURNS "trigger"
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

    NEW."Demand" = COALESCE(NEW."ncars"::float, 0.0) + COALESCE(NEW."nlgvs"::float, 0.0)
                    + COALESCE(NEW."nmcls"::float, 0.0)*0.33
                    + (COALESCE(NEW."nogvs"::float, 0) + COALESCE(NEW."nogvs2"::float, 0) + COALESCE(NEW."nminib"::float, 0) + COALESCE(NEW."nbuses"::float, 0))*1.5
                    + COALESCE(NEW."ntaxis"::float, 0);

    /* What to do about suspensions */

    CASE
        WHEN NEW."Capacity" = 0 THEN
            CASE
                WHEN NEW."Demand" > 0.0 THEN NEW."Stress" = 100.0;
                ELSE NEW."Stress" = 0.0;
            END CASE;
        ELSE
            CASE
                WHEN NEW."Capacity"::float - COALESCE(NEW."sbays"::float, 0.0) > 0.0 THEN
                    NEW."Stress" = NEW."Demand" / (NEW."Capacity"::float - COALESCE(NEW."sbays"::float, 0.0)) * 100.0;
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
