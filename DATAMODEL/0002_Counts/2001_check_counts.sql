	-- Find obvious errors

SELECT "Enumerator", "SurveyID", "GeometryID", "SupplyCapacity", "CapacityAtTimeOfSurvey", "Demand"
FROM demand."RestrictionsInSurveys"
WHERE "Stress" > 1
AND "Demand" > "CapacityAtTimeOfSurvey" + 5;


SELECT curr."Enumerator", curr."SurveyID", curr."GeometryID", curr."SupplyCapacity", curr."CapacityAtTimeOfSurvey", curr."Demand" As "Demand - Current", 
before."Demand" As "Demand - Before", after."Demand" As "Demand - After"
FROM demand."RestrictionsInSurveys" curr, demand."RestrictionsInSurveys" before, demand."RestrictionsInSurveys" after
WHERE curr."GeometryID" = before."GeometryID"
AND before."GeometryID" = after."GeometryID"
AND before."SurveyID" = curr."SurveyID" - 1
AND after."SurveyID" = curr."SurveyID" + 1
AND ABS(curr."Demand"::real - (before."Demand"::real + after."Demand"::real) / 2.0) > 5.0
--AND curr."SurveyID" = 113

-- Find differences within the same time periods for the same GeometryID

SELECT RiS1."GeometryID", RiS1."SurveyID", RiS1."Demand", RiS1."Enumerator", RiS2."SurveyID", RiS2."Demand", RiS2."Enumerator"
FROM demand."RestrictionsInSurveys" RiS1, demand."RestrictionsInSurveys" RiS2
WHERE RiS1."GeometryID" = RiS2."GeometryID"
AND RiS1."SurveyID" < RiS2."SurveyID"
AND ABS(RiS1."SurveyID" - RiS2."SurveyID") = 100
AND ABS(RiS1."Demand" - RiS2."Demand") >= 5
ORDER BY RiS1."GeometryID", RiS1."SurveyID";