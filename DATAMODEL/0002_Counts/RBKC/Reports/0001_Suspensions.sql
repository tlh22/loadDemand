/***

Queries:
 - Number of restrictions affected by a suspension
 - Details of all suspensions

***/

--- Totals

SELECT DISTINCT (ris."GeometryID")
FROM demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
WHERE ris."GeometryID" = s."GeometryID"
AND COALESCE("NrBaysSuspended", 0) > 0
AND s."RestrictionTypeID" < 200

-- Total by time period

SELECT p."SurveyID", su."BeatTitle", p."NrBaysSuspended"
FROM demand."Surveys" su,
(SELECT ris."SurveyID", SUM("NrBaysSuspended") AS "NrBaysSuspended"
FROM demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
WHERE ris."GeometryID" = s."GeometryID"
AND COALESCE("NrBaysSuspended", 0) > 0
AND s."RestrictionTypeID" < 200
GROUP BY ris."SurveyID") p
WHERE su."SurveyID" = p."SurveyID"
ORDER BY su."SurveyID"

-- Details

SELECT ris."GeometryID", ris."SurveyID", su."BeatTitle", s."RoadName", s."Description" AS "RestrictionType Description",
	   ris."SuspensionReference", ris."SuspensionReason", ris."SuspensionLength", ris."NrBaysSuspended", ris."SuspensionNotes"
FROM demand."RestrictionsInSurveys" ris, ( mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") s, 
 demand."Surveys" su
WHERE ris."GeometryID" = s."GeometryID"
AND COALESCE("NrBaysSuspended", 0) > 0
AND s."RestrictionTypeID" < 200
AND ris."SurveyID" = su."SurveyID"
ORDER BY s."RoadName", ris."NrBaysSuspended"

--

SELECT ris."GeometryID", su."SurveyID", su."SurveyDay" AS "BeatTItle", s."RoadName", s."RestrictionType Description", 
    ris."SuspensionReference", ris."SuspensionReason", '' AS "Revised Suspension Reason", ris."NrBaysSuspended", ris."SuspensionNotes"

FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, demand."Counts" c,
(
SELECT a."GeometryID", a."RestrictionTypeID", a."RestrictionLength", a."Capacity", "UnacceptableTypes"."Description" AS "UnacceptableType Description", "BayLineTypes"."Description" AS "RestrictionType Description",
a."RoadName", a."CPZ", "SurveyAreas"."SurveyAreaName", "Wards"."Name" AS "WardName", "ParkingTariffZones"."tariff_cat" AS "ParkingTariffZoneName",
'' AS "HospitalZonesBlueBadgeHoldersName", l.item_refs,
 a.geom AS "SupplyGeom"
 FROM
((((((  mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "local_authority"."Wards_2022" AS "Wards" ON a."WardID" is not distinct from "Wards"."id")
 LEFT JOIN "local_authority"."PayByPhoneTariffZones" AS "ParkingTariffZones" ON a."ParkingTariffZoneID" is not distinct from "ParkingTariffZones"."id")
 -- LEFT JOIN "local_authority"."HospitalZonesBlueBadgeHolders_2022" AS "HospitalZonesBlueBadgeHolders" ON a."HospitalZonesBlueBadgeHoldersID" is not distinct from "HospitalZonesBlueBadgeHolders"."id")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
 LEFT JOIN (SELECT "GeometryID" AS "GeometryID_Links", ARRAY_AGG ("item_ref") AS item_refs
											 FROM mhtc_operations."RBKC_item_ref_links_2024"
											 GROUP BY "GeometryID" ) AS l ON a."GeometryID" = l."GeometryID_Links")
 ) AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND ris."SurveyID" = c."SurveyID"
 AND ris."GeometryID" = c."GeometryID"
 AND su."SurveyID" > 0
 AND COALESCE(ris."NrBaysSuspended", 0) > 0
 --AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
 --AND RiS."Done" IS True
  -- AND s."RoadName" LIKE 'Lower Addison Gardens%'

ORDER BY s."RoadName", ris."NrBaysSuspended";
