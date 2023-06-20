/*

Need to change for each CPZ - and ensure correct Supply details

    ** Ensure that SurveyAreas table is created (even if not populated) 
*/

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";

SELECT d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description", d."RoadName",
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."Notes",
-- regexp_replace(v."Notes", '(.*?)(?<=<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">)(.*?)(?=<\/p>)', '\2', 'g')  AS "Notes",
d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03", d."SupplyCapacity", d."CapacityAtTimeOfSurvey", d."Demand", d."Stress", 
COALESCE("SurveyAreaName", '') AS "SurveyAreaName", 
d."CPZ"

FROM
(SELECT ris."SurveyID", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description", s."RoadName", s."CPZ",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", ris."SupplyCapacity", ris."CapacityAtTimeOfSurvey", ris."Demand", ris."Stress", "SurveyAreaName", c."Notes"

FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, demand."Counts" c,
(( --(
  mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND ris."SurveyID" = c."SurveyID"
 AND ris."GeometryID" = c."GeometryID"
 AND su."SurveyID" > 0
 AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d
ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID";
