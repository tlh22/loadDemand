/**
Check the number of VRMs collected within each pass
**/

SELECT v."SurveyID", s."BeatTitle", COUNT(v."ID")
FROM demand."VRMs" v, demand."Surveys" s
WHERE v."SurveyID" = s."SurveyID"
GROUP BY v."SurveyID", s."BeatTitle"
ORDER BY v."SurveyID";


-- Use this to get break down by area - and then create a pivot table in Excel

SELECT s."SurveyID", p."SurveyAreaName", COUNT(p."ID")
FROM "demand"."Surveys" s LEFT JOIN
(SELECT a."SurveyAreaName", v."SurveyID", v."ID"
 FROM "demand"."RestrictionsInSurveys" RiS, "demand"."VRMs" v, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
 WHERE v."SurveyID" = RiS."SurveyID"
 AND v."GeometryID" = r."GeometryID"
 AND v."GeometryID" = RiS."GeometryID"
 AND RiS."Done" = 'true'
 AND r."SurveyAreaID" = a."Code"
 --AND a.name = '7S-WGR'
 ) AS p ON p."SurveyID" = s."SurveyID"
WHERE s."SurveyID" > 0
GROUP BY s."SurveyID", p."SurveyAreaName"
ORDER BY s."SurveyID", p."SurveyAreaName"

-- including road, GeometryID

SELECT s."SurveyID", a.name, r."RoadName", r."GeometryID", COUNT(v."ID")
FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = r."GeometryID"
AND r."SurveyArea"::int = a.id
GROUP BY s."SurveyID", a.name, r."RoadName", r."GeometryID"
ORDER BY s."SurveyID", a.name, r."RoadName", r."GeometryID"