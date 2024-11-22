-- Find obvious errors

-- Check for possible typos
SELECT "Enumerator", "SurveyID", RiS."GeometryID", s."RestrictionTypeID", "Capacity", "CapacityAtTimeOfSurvey", "Demand"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND "Stress" > 1
AND "Demand" > "CapacityAtTimeOfSurvey" + 5
Order By s."RestrictionTypeID", RiS."GeometryID";
