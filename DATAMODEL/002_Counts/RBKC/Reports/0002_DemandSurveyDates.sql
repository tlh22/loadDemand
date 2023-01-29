-- Dates for demand by street

SELECT RiS."SurveyID", su."BeatTitle", s."RoadName",TO_CHAR( MIN(RiS."DemandSurveyDateTime"), 'dd/mm/yyyy')
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY RiS."SurveyID", su."BeatTitle", s."RoadName"
ORDER BY s."RoadName", RiS."SurveyID"


-- can we do this as a crosstab query?

CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM crosstab('...')
    AS ct(row_name text, extra text, cat1 text, cat2 text, cat3 text, cat4 text);