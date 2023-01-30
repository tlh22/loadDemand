-- Dates for demand by street

/***
SELECT RiS."SurveyID", su."BeatTitle", s."RoadName",TO_CHAR( MIN(RiS."DemandSurveyDateTime"), 'dd/mm/yyyy')  AS "DemandSurveyDate"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY RiS."SurveyID", su."BeatTitle", s."RoadName"
ORDER BY s."RoadName", RiS."SurveyID"

***/

-- can we do this as a crosstab query?



CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM crosstab('
SELECT s."RoadName"::text, su."BeatTitle"::text, TO_CHAR( MIN(RiS."DemandSurveyDateTime"), ''dd/mm/yyyy'')::text AS "DemandSurveyDate"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY su."BeatTitle", s."RoadName"
ORDER BY s."RoadName", su."BeatTitle"
')
    AS ct("RoadName" text, "Weekday Overnight" text, "Weekday Afternoon" text, "Weekday Evening" text, 
	 "Saturday Afternoon" text, "Sunday Afternoon" text);
