-- Find obvious errors

-- Check for possible typos
SELECT "Enumerator", "SurveyID", RiS."GeometryID", s."RestrictionTypeID", l."Description", "Capacity", "CapacityAtTimeOfSurvey", "Demand"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, toms_lookups."BayLineTypes" l
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND "Stress" > 1
AND "Demand" > "CapacityAtTimeOfSurvey" + 5
Order By s."RestrictionTypeID", RiS."GeometryID";
