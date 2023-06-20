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
AND curr."Demand"::real - (before."Demand"::real + after."Demand"::real) / 2.0 > 5.0
--AND curr."SurveyID" = 113