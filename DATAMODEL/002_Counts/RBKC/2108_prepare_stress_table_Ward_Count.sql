-- create view with join to demand table

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults_ByWard";

CREATE MATERIALIZED VIEW demand."StressResults_ByWard"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS id,
        w."SurveyID", su."BeatTitle", "WardID", wa."Name", "SupplyCapacity", "NrBaysSuspended", "CapacityAtTimeOfSurvey", "Demand",
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
        "PerceivedCapacityAtTimeOfSurvey",
        CASE
            WHEN "PerceivedCapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "PerceivedCapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Demand" / ("PerceivedCapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "PerceivedStress", wa.geom
    FROM
    (SELECT
    RiS."SurveyID", s."WardID",
    SUM(s."Capacity") AS "SupplyCapacity", SUM(COALESCE(RiS."NrBaysSuspended", 0)) AS "NrBaysSuspended",
    SUM(RiS."CapacityAtTimeOfSurvey") AS "CapacityAtTimeOfSurvey",
	SUM(RiS."Demand") AS "Demand",
	SUM(RiS."PerceivedCapacityAtTimeOfSurvey") AS "PerceivedCapacityAtTimeOfSurvey"
	FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
	WHERE RiS."GeometryID" = s."GeometryID"
    AND RiS."SurveyID" > 0
	GROUP BY RiS."SurveyID", s."WardID") AS w,
	demand."Surveys" su, local_authority."Wards_2022" wa
	WHERE w."SurveyID" = su."SurveyID"
	AND w."WardID" = wa."id"
WITH DATA;

ALTER TABLE demand."StressResults_ByWard"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_ByWard_id"
    ON demand."StressResults_ByWard" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults_ByWard";