/***
 * For situations where the supply is changed during a demand survey, add the new restrictions into "RestrictionsInSurveys"
 ***/

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "GeometryID" NOT IN
(SELECT "GeometryID"
FROM demand."RestrictionsInSurveys");

-- for count type surveys

INSERT INTO demand."Counts" ("SurveyID", "GeometryID")
SELECT "SurveyID", "GeometryID"
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "GeometryID" NOT IN
(SELECT "GeometryID"
FROM demand."Counts");

-- Update geom
						   
UPDATE demand."RestrictionsInSurveys" AS RiS
SET geom = s.geom
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";

-- remove RiS entries for which there is no supply ...

DELETE FROM demand."RestrictionsInSurveys"
WHERE "GeometryID" NOT IN (SELECT "GeometryID"
					       FROM mhtc_operations."Supply");


-- Add extra Surveys
INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "SurveyID" NOT IN
(SELECT "SurveyID"
FROM demand."RestrictionsInSurveys");