/***
 * Incude a new restriction into RiS
 ***/

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM demand."Surveys",
(SELECT "GeometryID", geom
FROM mhtc_operations."Supply"
WHERE "GeometryID" NOT IN (SELECT DISTINCT "GeometryID"
                           FROM demand."RestrictionsInSurveys")) AS r

INSERT INTO "demand"."Counts" ("SurveyID", "GeometryID")
SELECT "SurveyID", "GeometryID"
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "GeometryID" NOT IN (SELECT DISTINCT "GeometryID"
                           FROM demand."Counts")
