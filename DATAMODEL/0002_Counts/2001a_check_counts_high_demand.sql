-- Find obvious errors

-- Check for possible typos
SELECT "Enumerator", "SurveyID", "GeometryID", "SupplyCapacity", "CapacityAtTimeOfSurvey", "Demand"
FROM demand."RestrictionsInSurveys"
WHERE "Stress" > 1
AND "Demand" > "CapacityAtTimeOfSurvey" + 5;
