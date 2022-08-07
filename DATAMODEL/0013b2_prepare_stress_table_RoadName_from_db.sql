

-- Now prepare stress

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
	
    SELECT "SurveyID", "RoadName", 
	SUM("Capacity") AS "Capacity", 
	SUM("Demand") AS "Demand"
    FROM (
	    SELECT d."SurveyID", su."RoadName", 
		CASE WHEN ("RestrictionTypeID" < 200 OR
			"RestrictionTypeID" = 201 OR
			"RestrictionTypeID" = 216 OR
			"RestrictionTypeID" = 217 OR
			"RestrictionTypeID" = 227) THEN
			su."Capacity" - COALESCE(RiS."NrBaysSuspended", 0.0)
		ELSE
			su."Capacity"
		END AS "Capacity",
		RiS."Demand"
		FROM mhtc_operations."Supply" su, demand."Counts" d, demand."RestrictionsInSurveys" RiS
		WHERE su."GeometryID" = d."GeometryID"
		AND d."GeometryID" = RiS."GeometryID"
		AND d."SurveyID" = RiS."SurveyID"
		AND su."RestrictionTypeID" NOT IN (117, 118)  -- Motorcycle bays
		) b
    GROUP BY "SurveyID", "RoadName"
    ORDER BY "RoadName", "SurveyID" ) a

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
    FROM mhtc_operations."Supply" s, demand."Counts" d
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