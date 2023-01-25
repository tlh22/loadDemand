-- Now prepare stress

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults_ByRoadName";

CREATE MATERIALIZED VIEW demand."StressResults_ByRoadName"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    r."roadname1_name" AS "RoadName", r.geom,
    d."SurveyID", d."Capacity", d."CapacityAtTimeOfSurvey", d."Demand", d."Stress" AS "Stress",
    e."Capacity" AS "Capacity_2018", e."CapacityAtTimeOfSurvey" AS "CapacityAtTimeOfSurvey_2018", e."Demand" AS "Demand_2018", e."Stress" AS "Stress_2018"
	FROM highways_network."roadlink" r,
	(
	SELECT "SurveyID", "RoadName", "Capacity", "CapacityAtTimeOfSurvey", "Demand",
        CASE
            WHEN "CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Demand" / ("CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", SUM(s."Capacity") AS "Capacity", SUM(RiS."CapacityAtTimeOfSurvey") AS "CapacityAtTimeOfSurvey",
	SUM(RiS."Demand") AS "Demand"
    FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
    WHERE s."GeometryID" = RiS."GeometryID"
    AND s."RestrictionTypeID" NOT IN (107, 116, 117, 118, 119, 122, 144, 146, 147, 149, 150, 151, 168, 169)  -- MCL, PCL, Scooters, etc
    AND RiS."SurveyID" > 0
    GROUP BY RiS."SurveyID", s."RoadName"
    ORDER BY s."RoadName", RiS."SurveyID" ) a
    ) d,
    	(
	SELECT "SurveyID", "RoadName", "Capacity", "CapacityAtTimeOfSurvey", "Demand",
        CASE
            WHEN "CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Demand" / ("CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress"
    FROM (
    SELECT "SurveyID", "RoadName", SUM("ParkingAvailableDuringSurveyHours") AS "Capacity", SUM("AvailableSpacesForParking") AS "CapacityAtTimeOfSurvey",
	SUM("AllVehiclesParked_Weighted") AS "Demand"
    FROM mhtc_operations."2018_Demand_ALL"
    WHERE "RestrictionGroup" NOT IN ('Bus Stop',  'Bus Stop (Red Route)',  'Bus Stand' ,  'Bus Stand (Red Route)' ,
    'Cycle Hire bay' ,  'Motorcycle Permit Holders bay' ,  'On-Carriageway Bicycle Bay' ,  'Solo Motorcycle bay (Visitors)' )  -- MCL, PCL, Scooters, etc
    GROUP BY "SurveyID", "RoadName"
    ORDER BY "RoadName", "SurveyID" ) a
    ) e
	WHERE r."roadname1_name" = d."RoadName"
	AND d."SurveyID" = e."SurveyID"
	AND d."RoadName" = e."RoadName"
WITH DATA;

ALTER TABLE demand."StressResults_ByRoadName"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_ByRoadName_sid"
    ON demand."StressResults_ByRoadName" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults_ByRoadName";

-- Output
SELECT DISTINCT "RoadName", "SurveyID", "Capacity", "CapacityAtTimeOfSurvey", "Demand", "Stress", "Capacity_2018", "CapacityAtTimeOfSurvey_2018", "Demand_2018", "Stress_2018"
	FROM demand."StressResults_ByRoadName"
	ORDER BY "RoadName", "SurveyID";