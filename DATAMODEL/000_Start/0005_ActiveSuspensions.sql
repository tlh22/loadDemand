/***
Setup details for demand
***/

DROP TABLE IF EXISTS demand."ActiveSuspensions" CASCADE;

CREATE TABLE demand."ActiveSuspensions"
(
    gid INT GENERATED ALWAYS AS IDENTITY,
    "SurveyID" integer NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom geometry(LineString,27700),
    UNIQUE ("SurveyID", "GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE demand."ActiveSuspensions"
    OWNER to postgres;

ALTER TABLE demand."ActiveSuspensions"
ADD UNIQUE ("SurveyID", "GeometryID");

/***

INSERT INTO demand."ActiveSuspensions" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", gid::text AS "GeometryID", r.geom As geom
FROM mhtc_operations."RC_Sections_merged" r, demand."Surveys";
***/

-- OR

INSERT INTO demand."ActiveSuspensions" ("SurveyID", "GeometryID")
SELECT "SurveyID", "GeometryID"
FROM mhtc_operations."Supply" r, demand."Surveys";

--

ALTER TABLE demand."ActiveSuspensions"
    ADD COLUMN IF NOT EXISTS "RestrictionTypeID" integer;

ALTER TABLE demand."ActiveSuspensions"
    ADD COLUMN IF NOT EXISTS "GeomShapeID" integer;
    
ALTER TABLE demand."ActiveSuspensions"
    ADD COLUMN IF NOT EXISTS "AzimuthToRoadCentreLine" double precision;
    
UPDATE demand."ActiveSuspensions" AS a
SET "RestrictionTypeID" = s."RestrictionTypeID",
	"GeomShapeID" = s."GeomShapeID",
	"AzimuthToRoadCentreLine" = s."AzimuthToRoadCentreLine"
FROM mhtc_operations."Supply" s
WHERE a."GeometryID" = s."GeometryID";

