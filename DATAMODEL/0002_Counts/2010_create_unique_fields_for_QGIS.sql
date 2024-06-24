/***
 * Create unique GeometryID/SurveyID field so that join can be made in QGIS
 ***/

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "GeometryID_SurveyID" character varying(100) COLLATE pg_catalog."default";

ALTER TABLE demand."Counts"
    ADD COLUMN "GeometryID_SurveyID" character varying(100) COLLATE pg_catalog."default";

-- Populate

UPDATE demand."RestrictionsInSurveys"
SET "GeometryID_SurveyID" = CONCAT("GeometryID", '_', "SurveyID"::text);

UPDATE demand."Counts"
SET "GeometryID_SurveyID" = CONCAT("GeometryID", '_', "SurveyID"::text);

-- Set up indexes

CREATE UNIQUE INDEX geometryid_surveyid_idx ON demand."RestrictionsInSurveys" ("GeometryID_SurveyID");

CREATE UNIQUE INDEX geometryid_surveyid_idx ON demand."Counts" ("GeometryID_SurveyID");