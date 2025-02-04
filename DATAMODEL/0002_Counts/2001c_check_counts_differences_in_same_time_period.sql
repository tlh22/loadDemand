-- Find obvious errors

-- Find differences within the same time periods for the same GeometryID - good check - possibly typo, possible miss
SELECT RiS1."GeometryID", s."RestrictionTypeID", RiS1."SurveyID", RiS1."Demand", RiS1."Enumerator", RiS2."SurveyID", RiS2."Demand", RiS2."Enumerator"
FROM demand."RestrictionsInSurveys" RiS1, demand."RestrictionsInSurveys" RiS2, mhtc_operations."Supply" s
WHERE  RiS1."GeometryID" = s."GeometryID"
AND RiS1."GeometryID" = RiS2."GeometryID"
AND RiS1."SurveyID" < RiS2."SurveyID"
AND ABS(RiS1."SurveyID" - RiS2."SurveyID") = 100
AND ABS(RiS1."Demand" - RiS2."Demand") >= 5
ORDER BY RiS1."GeometryID", RiS1."SurveyID";

