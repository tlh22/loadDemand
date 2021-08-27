/**
Check the number of VRMs collected within each pass
**/

SELECT v."SurveyID", s."BeatTitle", COUNT(v."ID")
FROM demand."VRMs" v, demand."Surveys" s
WHERE v."SurveyID" = s."SurveyID"
GROUP BY v."SurveyID", s."BeatTitle"
ORDER BY v."SurveyID";


-- Use this to get break down by area - and then create a pivot table in Excel

SELECT s."SurveyID", a.name, COUNT(v."ID")
FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = r."GeometryID"
AND r."SurveyArea"::int = a.id
GROUP BY s."SurveyID", a.name
ORDER BY s."SurveyID", a.name
