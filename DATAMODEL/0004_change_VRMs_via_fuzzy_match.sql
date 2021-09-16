/**
Check for close matches within same GeometryID - and make changes (if not for same SurveyID)
**/

CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch" WITH SCHEMA "public";

/**
SELECT DISTINCT v1."GeometryID", v1."VRM", v2."VRM"
FROM (SELECT v."SurveyID", s."SurveyDay", v."GeometryID", v."ID", v."VRM"
	  FROM demand."VRMs" v INNER JOIN demand."Surveys" s ON v."SurveyID" = s."SurveyID") AS v1,
     (SELECT v."SurveyID", s."SurveyDay", v."GeometryID", v."ID", v."VRM"
	  FROM demand."VRMs" v INNER JOIN demand."Surveys" s ON v."SurveyID" = s."SurveyID") AS v2
WHERE v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" != v2."SurveyID"
AND v1."VRM" != v2."VRM"
AND v1."ID" > v2."ID"
AND levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 2
AND v1."SurveyID" > 30
AND v1."SurveyDay" = v2."SurveyDay"
AND v1."VRM" NOT IN (
    SELECT DISTINCT v11."VRM"
    FROM demand."VRMs" v11, demand."VRMs" v12
    WHERE v11."GeometryID" = v12."GeometryID"
    AND v11."SurveyID" = v12."SurveyID"
    AND v11."VRM" != v12."VRM"
    AND v11."ID" > v12."ID"
    AND levenshtein(v11."VRM"::text, v12."VRM"::text, 10, 10, 1) <= 2
)
ORDER BY v1."VRM";
**/

-- Change details

UPDATE demand."VRMs" AS v1
SET "VRM" = v2."VRM"
FROM demand."VRMs" v2
WHERE v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" != v2."SurveyID"
AND v1."VRM" != v2."VRM"
AND v1."ID" < v2."ID"
AND levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 2
AND (v1."SurveyID" < 30 AND v1."SurveyID" > 20)   -- need to ensure that v1 and v2 have the same "SurveyDay"
AND (v2."SurveyID" < 30 AND v2."SurveyID" > 20)
AND v1."VRM" NOT IN (
    SELECT DISTINCT v11."VRM"
    FROM demand."VRMs" v11, demand."VRMs" v12
    WHERE v11."GeometryID" = v12."GeometryID"
    AND v11."SurveyID" = v12."SurveyID"
    AND v11."VRM" != v12."VRM"
    AND v11."ID" < v12."ID"
    AND levenshtein(v11."VRM"::text, v12."VRM"::text, 10, 10, 1) <= 2
)
;

-- Very occassionally there is an incorrect change, e.g., when there is already a series with the candidate