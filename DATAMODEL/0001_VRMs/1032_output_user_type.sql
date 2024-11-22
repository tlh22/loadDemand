/***
 * Use both VRMs and RiS
 ***/

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";
 
--- RiS

SELECT d."SurveyID", d."BeatTitle", d."SurveyDay", d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime", d."GeometryID",
d."RestrictionTypeID", d."RestrictionType Description",
d."UnacceptableType Description", 
d."RestrictionLength", d."RoadName", d."CPZ",
d."SupplyCapacity", d."CapacityAtTimeOfSurvey", ROUND(d."Demand"::numeric, 2) AS "Demand",
 d."Demand_Residents", d."Demand_Commuters", d."Demand_Visitors"
FROM
(
SELECT ris."SurveyID", su."SurveyDay", su."BeatStartTime", su."BeatEndTime", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."RestrictionType Description", 
s."UnacceptableType Description", s."RestrictionLength", 
 s."RoadName", s."SideOfStreet", s."SurveyAreaName", s."CPZ",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", ris."SupplyCapacity", ris."CapacityAtTimeOfSurvey", ris."Demand",
ris."Demand_Residents", ris."Demand_Commuters", ris."Demand_Visitors"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su,
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
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

WHERE d."SurveyID" > 0
--AND d."Done" IS true
ORDER BY d."SurveyID", d."GeometryID";


-- VRMs

SELECT v."ID", v."SurveyID", s."SurveyDay", CONCAT(s."BeatStartTime", '-', "BeatEndTime") As "SurveyTime",
        v."CPZ", v."RoadName", v."RestrictionType Description", v."SideOfStreet",
		v."GeometryID", v."VRM", 
		v."InternationalCodeID", v."Country",
		v."VehicleTypeID", v."VehicleType Description",
        v."PCU",
        "UserType Description",
        --v."PermitTypeID", v."PermitType Description",
        v."Notes"

SELECT d."SurveyID", LPAD(d."SurveyID"::text, 3, '0') || ' - ' || to_char(d."SurveyDate", 'Dy') || ' - ' || d."BeatStartTime" || ' - ' || d."BeatEndTime" AS "BeatTitle",
d."SurveyDay", d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime", d."GeometryID", d."RestrictionTypeID", 
d."RestrictionType Description", "UnacceptabilityReason", 
d."RestrictionLength",
d."RoadName", --d."SideOfStreet",
d."CPZ", d."SupplyCapacity", d."CapacityAtTimeOfSurvey", ROUND(d."Demand"::numeric, 2) AS "Demand"

FROM
(SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "VRM",
"InternationalCodeID", "InternationalCodes"."Description" As "Country",
"VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description",
       su."RestrictionTypeID",
		"BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        a."Notes", su."CPZ", su."RoadName", su."SideOfStreet", "UserTypes"."Description" AS "UserType Description", "VehicleTypes"."PCU"

FROM
     ((((((demand."VRMs" AS a
	 LEFT JOIN mhtc_operations."Supply" AS su ON a."GeometryID" = su."GeometryID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON su."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."InternationalCodes" AS "InternationalCodes" ON a."InternationalCodeID" is not distinct from "InternationalCodes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")
     LEFT JOIN "demand_lookups"."UserTypes" AS "UserTypes" ON a."UserTypeID" is not distinct from "UserTypes"."Code")
ORDER BY "GeometryID", "VRM") As v
	 	, demand."Surveys" s
		, demand."RestrictionsInSurveys" r
WHERE v."SurveyID" = s."SurveyID"
AND r."SurveyID" = s."SurveyID"
AND r."GeometryID" = v."GeometryID"
--AND su."CPZ" = 'HS'
--AND s."SurveyID" > 20 and s."SurveyID" < 30
ORDER BY "GeometryID", "VRM", "SurveyID";