-- Now prepare stress

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults_ByRoadName";

CREATE MATERIALIZED VIEW demand."StressResults_ByRoadName"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    r."roadname1_name" AS "RoadName", r.geom,
    d."SurveyID", d."BeatTitle", d."Capacity", d."CapacityAtTimeOfSurvey", d."Demand", d."Stress" AS "Stress",
    d."Residents Bay Capacity", d."Residents Bay CapacityAtTimeOfSurvey", d."Residents Bay Demand", d."Residents Bay Stress",
    d."Residents Bay PerceivedCapacityAtTimeOfSurvey", d."Residents Bay PerceivedStress",
    d."PayByPhone Bay Capacity", d."PayByPhone Bay CapacityAtTimeOfSurvey", d."PayByPhone Bay Demand", d."PayByPhone Bay Stress",
    e."Capacity" AS "Capacity_2018", e."CapacityAtTimeOfSurvey" AS "CapacityAtTimeOfSurvey_2018", e."Demand" AS "Demand_2018", e."Stress" AS "Stress_2018"
	FROM highways_network."roadlink" r,
	(
	SELECT a."SurveyID", su."BeatTitle", "RoadName", "Capacity", "CapacityAtTimeOfSurvey", "Demand",
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
        END "Stress",
        "Residents Bay Capacity", "Residents Bay CapacityAtTimeOfSurvey", "Residents Bay Demand",
        CASE
            WHEN "Residents Bay CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Residents Bay CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Residents Bay Demand" / ("Residents Bay CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Residents Bay Stress",

--
        "Residents Bay PerceivedCapacityAtTimeOfSurvey", 
        CASE
            WHEN "Residents Bay PerceivedCapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Residents Bay PerceivedCapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Residents Bay Demand" / ("Residents Bay PerceivedCapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Residents Bay PerceivedStress",

--

        "PayByPhone Bay Capacity", "PayByPhone Bay CapacityAtTimeOfSurvey", "PayByPhone Bay Demand",
        CASE
            WHEN "PayByPhone Bay CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "PayByPhone Bay Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "PayByPhone Bay CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "PayByPhone Bay Demand" / ("PayByPhone Bay CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "PayByPhone Bay Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "PayByPhone Bay Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", SUM(s."Capacity") AS "Capacity", SUM(RiS."CapacityAtTimeOfSurvey") AS "CapacityAtTimeOfSurvey",
	SUM(RiS."Demand") AS "Demand",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE s."Capacity" END) AS "Residents Bay Capacity",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."CapacityAtTimeOfSurvey" END) AS "Residents Bay CapacityAtTimeOfSurvey",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."PerceivedCapacityAtTimeOfSurvey" END) AS "Residents Bay PerceivedCapacityAtTimeOfSurvey",	
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."Demand" END) AS "Residents Bay Demand",
	SUM (CASE WHEN "RestrictionTypeID" != 103 THEN 0 ELSE s."Capacity" END) AS "PayByPhone Bay Capacity",
	SUM (CASE WHEN "RestrictionTypeID" != 103 THEN 0 ELSE RiS."CapacityAtTimeOfSurvey" END) AS "PayByPhone Bay CapacityAtTimeOfSurvey",
	SUM (CASE WHEN "RestrictionTypeID" != 103 THEN 0 ELSE RiS."Demand" END) AS "PayByPhone Bay Demand"
    FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
    WHERE s."GeometryID" = RiS."GeometryID"
    AND s."RestrictionTypeID" NOT IN (107, 116, 117, 118, 119, 122, 144, 146, 147, 149, 150, 151, 168, 169)  -- MCL, PCL, Scooters, etc
    AND RiS."SurveyID" > 0
    GROUP BY RiS."SurveyID", s."RoadName"
    ORDER BY s."RoadName", RiS."SurveyID" ) a, demand."Surveys" su
	WHERE a."SurveyID" = su."SurveyID"
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
SELECT DISTINCT "RoadName", "SurveyID", "BeatTitle", "Capacity" AS "Capacity_2022", "CapacityAtTimeOfSurvey" AS "CapacityAtTimeOfSurvey_2022", 
	"Demand" AS "Demand_2022", "Stress" AS "Occupancy_2022", "Capacity_2018", "CapacityAtTimeOfSurvey_2018", "Demand_2018", "Occupancy_2018"
	FROM demand."StressResults_ByRoadName"
	ORDER BY "RoadName", "SurveyID";