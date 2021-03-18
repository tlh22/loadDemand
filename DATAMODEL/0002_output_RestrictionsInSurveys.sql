--
SELECT d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description",
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", v."Demand"
FROM
(SELECT ris."SurveyID", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", s."Capacity"
FROM demand."RestrictionsInSurveys_FP" ris, demand."Surveys" su,
(mhtc_operations."Supply_210312_FP_HS" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND s."CPZ" = 'FP'
 AND substring(su."BeatTitle" from '\((.+)\)') LIKE 'FP/%'
 ) as d

 LEFT JOIN  (SELECT "SurveyID", "GeometryID",
   SUM(CASE WHEN "VehicleTypeID" = 1 or "VehicleTypeID" = 2 or "VehicleTypeID" = 7 THEN 1.0  -- Car, LGV or Taxi
            WHEN "VehicleTypeID" = 3 THEN 0.4  -- MCL
            WHEN "VehicleTypeID" = 4 THEN 1.5  -- OGV
            WHEN "VehicleTypeID" = 5 THEN 2.0  -- Bus
            ELSE 1.0  -- Other or Null
      END) AS "Demand"
   FROM demand."VRMs"
   GROUP BY "SurveyID", "GeometryID"
  ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"
ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID";
