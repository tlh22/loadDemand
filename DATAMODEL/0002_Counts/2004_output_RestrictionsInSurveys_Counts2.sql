/*
    ** Ensure that SurveyAreas table is created (even if not populated) 
*/

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";

---

SELECT d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", 
CASE WHEN d."RestrictionTypeID" IN (220, 221, 222) THEN CONCAT(d."RestrictionType Description", ' - ', d."UnacceptableType Description")
     ELSE d."RestrictionType Description"
     END AS "RestrictionType Description",
d."RoadName",
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."Notes",
d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03", d."SupplyCapacity", d."CapacityAtTimeOfSurvey",
ROUND(d."Demand"::numeric, 2) AS "Demand", ROUND(d."Stress"::numeric, 2) AS "Stress",
COALESCE("SurveyAreaName", '') AS "SurveyAreaName", 
d."CPZ"
, d."PerceivedAvailableSpaces", d."PerceivedCapacityAtTimeOfSurvey", ROUND(d."PerceivedStress"::numeric, 2) AS "PerceivedStress"
--    d."NrCars", d."NrLGVs", d."NrMCLs", d."NrTaxis", d."NrPCLs", d."NrEScooters", d."NrDocklessPCLs", 
--    d."NrOGVs", d."NrMiniBuses", d."NrBuses", d."NrSpaces", d."Notes"

FROM
(SELECT ris."SurveyID", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."RestrictionType Description",
s."UnacceptableType Description",  
 s."RoadName", s."CPZ", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength",
 "NrBaysSuspended", "SuspensionNotes",
 ris."Photos_01", ris."Photos_02", ris."Photos_03", "SupplyCapacity", ris."CapacityAtTimeOfSurvey", ris."Demand",
 ris."Stress", "SurveyAreaName", c."Notes",
 ris."PerceivedAvailableSpaces", ris."PerceivedCapacityAtTimeOfSurvey", ris."PerceivedStress" 
--     ris."NrCars", ris."NrLGVs", ris."NrMCLs", ris."NrTaxis", ris."NrPCLs", ris."NrEScooters", ris."NrDocklessPCLs", 
--     ris."NrOGVs", ris."NrMiniBuses", ris."NrBuses", ris."NrSpaces", ris."Notes"

FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, demand."Counts" c,
(
SELECT a."GeometryID", a."RestrictionTypeID", a."RestrictionLength", a."Capacity" AS "SupplyCapacity",
"UnacceptableTypes"."Description" AS "UnacceptableType Description", 
"BayLineTypes"."Description" AS "RestrictionType Description",
a."RoadName", a."SideOfStreet", a."CPZ", "SurveyAreas"."SurveyAreaName", 
 a.geom AS "SupplyGeom"
 FROM
(((  mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
 ) AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND ris."SurveyID" = c."SurveyID"
 AND ris."GeometryID" = c."GeometryID"
 AND su."SurveyID" > 0
 AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
 -- AND s."RestrictionTypeID" IN (117, 118, 119, 144,168, 169)  -- MCL, PCL, Scooters, etc  ** Use when selecting MCL/PCL bays

 ) as d
 
 ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID";