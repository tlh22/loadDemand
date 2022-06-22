/*

Need to change for each CPZ - and ensure correct Supply details

*/

SELECT d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description", d."RoadName",
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", v."Demand in Bays", v."Demand on YLs"
FROM
(SELECT ris."SurveyID", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description", s."RoadName",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", s."Capacity"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su,
(mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

 LEFT JOIN  (SELECT "SurveyID", "GeometryID",
   SUM(COALESCE("NrCars"::float, 0.0) +
	COALESCE("NrLGVs"::float, 0.0) +
    COALESCE("NrMCLs"::float, 0.0)*0.33 +
    (COALESCE("NrOGVs"::float, 0.0) + COALESCE("NrMiniBuses"::float, 0.0) + COALESCE("NrBuses"::float, 0.0))*1.5 +
    COALESCE("NrTaxis"::float, 0.0)) AS "Demand in Bays",
    SUM("NrSpaces") AS "Spaces",
    SUM(COALESCE("NrCars_Suspended"::float, 0.0) +
	COALESCE("NrLGVs_Suspended"::float, 0.0) +
    COALESCE("NrMCLs_Suspended"::float, 0.0)*0.33 +
    (COALESCE("NrOGVs_Suspended"::float, 0) + COALESCE("NrMiniBuses_Suspended"::float, 0) + COALESCE("NrBuses_Suspended"::float, 0))*1.5 +
    COALESCE("NrTaxis_Suspended"::float, 0)) As "Demand on YLs"
   FROM demand."Counts"
   GROUP BY "SurveyID", "GeometryID"
  ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"
ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID";


-- check total count for each pass


SELECT d."SurveyID", d."BeatTitle", SUM(d."NrBaysSuspended") AS "NrBaysSuspended", SUM(d."Capacity") AS "Capacity", SUM(v."Demand in Bays") As "Demand in Bays", SUM(v."Demand on YLs") As "Demand on YLs"
FROM
(SELECT ris."SurveyID", su."BeatTitle", s."GeometryID", ris."NrBaysSuspended", s."Capacity"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, mhtc_operations."Supply" s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

 LEFT JOIN  (SELECT "SurveyID", "GeometryID",
   SUM(COALESCE("NrCars"::float, 0.0) +
	COALESCE("NrLGVs"::float, 0.0) +
    COALESCE("NrMCLs"::float, 0.0)*0.33 +
    (COALESCE("NrOGVs"::float, 0.0) + COALESCE("NrMiniBuses"::float, 0.0) + COALESCE("NrBuses"::float, 0.0))*1.5 +
    COALESCE("NrTaxis"::float, 0.0)) AS "Demand in Bays",
    SUM("NrSpaces") AS "Spaces",
    SUM(COALESCE("NrCars_Suspended"::float, 0.0) +
	COALESCE("NrLGVs_Suspended"::float, 0.0) +
    COALESCE("NrMCLs_Suspended"::float, 0.0)*0.33 +
    (COALESCE("NrOGVs_Suspended"::float, 0) + COALESCE("NrMiniBuses_Suspended"::float, 0) + COALESCE("NrBuses_Suspended"::float, 0))*1.5 +
    COALESCE("NrTaxis_Suspended"::float, 0)) As "Demand on YLs"
   FROM demand."Counts"
   GROUP BY "SurveyID", "GeometryID"
  ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"
  GROUP BY d."SurveyID", d."BeatTitle"
ORDER BY d."SurveyID";


