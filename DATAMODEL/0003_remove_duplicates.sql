/**

--Remove records that are the same, i.e., same VRM within same GeometryID within same beat

SELECT v1.*
FROM demand."VRMs" v1, demand."VRMs" v2
WHERE v1."VRM" = v2."VRM"
AND v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" = v2."SurveyID"
AND v1."ID" < v2."ID";

**/

DELETE FROM demand."VRMs" AS v1
 USING demand."VRMs" v2
WHERE v1."VRM" = v2."VRM"
AND v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" = v2."SurveyID"
AND v1."ID" < v2."ID";
