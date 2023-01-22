-- create view with join to demand table

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults_ByGeometryID";

CREATE MATERIALIZED VIEW demand."StressResults_ByGeometryID"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS id,

    RiS."SurveyID", s."GeometryID", s.geom, s."RestrictionTypeID", s."RoadName",
    RiS."SupplyCapacity",  COALESCE(RiS."NrBaysSuspended", 0) AS "NrBaysSuspended",
	RiS."CapacityAtTimeOfSurvey",
	RiS."Demand",
    RiS."Stress",
    RiS."PerceivedCapacityAtTimeOfSurvey",
    RiS."PerceivedStress"
	FROM mhtc_operations."Supply" s, demand."RestrictionsInSurveys" RiS
	WHERE RiS."GeometryID" = s."GeometryID"
    AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
WITH DATA;

ALTER TABLE demand."StressResults_ByGeometryID"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_ByGeometryID_id"
    ON demand."StressResults_ByGeometryID" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults_ByGeometryID";
