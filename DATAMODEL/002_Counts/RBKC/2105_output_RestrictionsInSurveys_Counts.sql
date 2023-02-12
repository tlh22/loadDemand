/*

All demand details are held on RiS

*/

-- Ensure that details are updated
UPDATE "mhtc_operations"."Supply"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";

SELECT d."SurveyID", d."BeatTitle", d."GeometryID", item_refs, d."RestrictionTypeID", d."RestrictionType Description", 
d."UnacceptableType Description", d."RestrictionLength", d."RoadName",
d."SupplyCapacity", d."CapacityAtTimeOfSurvey",
d."Demand", d."Stress" AS "Occupancy",
d."PerceivedCapacityAtTimeOfSurvey", d."PerceivedStress" AS "PerceivedOccupancy",
d."Demand_Waiting", d."Demand_Idling", d."Demand_Suspended",
d."PerceivedAvailableSpaces",

    d."NrCars", d."NrLGVs", d."NrMCLs", d."NrTaxis", d."NrPCLs", d."NrEScooters", d."NrDocklessPCLs", d."NrOGVs", d."NrMiniBuses", d."NrBuses", d."NrSpaces",

    d."NrCarsIdling", d."NrLGVsIdling", d."NrMCLsIdling",
    d."NrTaxisIdling", d."NrOGVsIdling", d."NrMiniBusesIdling",
    d."NrBusesIdling"

    , d."NrCarsParkedIncorrectly", d."NrLGVsParkedIncorrectly", d."NrMCLsParkedIncorrectly",
    d."NrTaxisParkedIncorrectly", d."NrOGVsParkedIncorrectly", d."NrMiniBusesParkedIncorrectly",
    d."NrBusesParkedIncorrectly",

    d."NrCarsWithDisabledBadgeParkedInPandD",

    d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
    d."Notes", d."DoubleParkingDetails", "MCL_Notes",
    --d."CPZ",
    d."WardName", d."ParkingTariffZoneName", d."HospitalZonesBlueBadgeHoldersName",
    d."DemandSurveyDateTime"
    --, d."Enumerator", d."Done"
    --, d."Photos_01", d."Photos_02", d."Photos_03",  d."SurveyAreaName"
    --, d."SupplyGeom" as geom

FROM
(SELECT ris.*,
 su."BeatTitle", s."RestrictionTypeID", s."RestrictionLength", s."RestrictionType Description", 
 s."UnacceptableType Description", s."RoadName", s."CPZ",
 "SurveyAreaName", s."WardName", s."ParkingTariffZoneName", s."HospitalZonesBlueBadgeHoldersName", s.item_refs,
 s."SupplyGeom"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su,
(
SELECT a."GeometryID", a."RestrictionTypeID", a."RestrictionLength", "UnacceptableTypes"."Description" AS "UnacceptableType Description", "BayLineTypes"."Description" AS "RestrictionType Description",
a."RoadName", a."CPZ", "SurveyAreas"."SurveyAreaName", "Wards"."Name" AS "WardName", "ParkingTariffZones"."ParkingTariffZoneName",
"HospitalZonesBlueBadgeHolders"."HospitalZonesBlueBadgeHoldersName", l.item_refs,
 a.geom AS "SupplyGeom"
 FROM
(((((((  mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "local_authority"."Wards_2022" AS "Wards" ON a."WardID" is not distinct from "Wards"."id")
 LEFT JOIN "local_authority"."ParkingTariffZones_2022" AS "ParkingTariffZones" ON a."ParkingTariffZoneID" is not distinct from "ParkingTariffZones"."id")
 LEFT JOIN "local_authority"."HospitalZonesBlueBadgeHolders_2022" AS "HospitalZonesBlueBadgeHolders" ON a."HospitalZonesBlueBadgeHoldersID" is not distinct from "HospitalZonesBlueBadgeHolders"."id")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
 LEFT JOIN (SELECT "GeometryID" AS "GeometryID_Links", ARRAY_AGG ("item_ref") AS item_refs
											 FROM mhtc_operations."RBKC_item_ref_links"
											 GROUP BY "GeometryID" ) AS l ON a."GeometryID" = l."GeometryID_Links")
 ) AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND su."SurveyID" > 0
 --AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
 --AND RiS."Done" IS True
  -- AND s."RoadName" LIKE 'Lower Addison Gardens%'
 ) as d
ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID";

-- Using fields from 2018

SELECT d."GeometryID", d."SurveyID", d."BeatTitle" AS "SurveyDescription", '' AS "OrderType", item_refs, 
d."RestrictionType Description" AS "RestrictionGroup",  
'' AS "RestrictionGroup2", '' AS "RestrictionGroup3",
'' AS "MHTC_Area", '' AS "MHTC_Section",
'' AS "USRN", d."RoadName",
    --d."CPZ",
    d."WardName" AS "Ward", d."ParkingTariffZoneName" AS "PTZName", d."HospitalZonesBlueBadgeHoldersName",

d."RestrictionLength" AS "KerblineLength", 
'' AS "MarkedBays",
'' AS "TheoreticalBays", 
d."UnacceptableType Description" AS "AcceptableParkingFlag",
d."DetailsOfControl",
'' AS "ParkingAvailableAfterRemovingUnacceptableSYL",
'' AS "UnacceptableSYL",
d."SupplyCapacity" AS "ParkingAvailableDuringControlledHours",

    d."DemandSurveyDateTime" AS "SurveyDate",


    d."NrCars", d."NrLGVs", d."NrMCLs", d."NrTaxis", d."NrPCLs", d."NrEScooters", d."NrDocklessPCLs", d."NrOGVs", d."NrMiniBuses", d."NrBuses", d."NrSpaces",

    d."NrCarsIdling", d."NrLGVsIdling", d."NrMCLsIdling",
    d."NrTaxisIdling", d."NrOGVsIdling", d."NrMiniBusesIdling",
    d."NrBusesIdling"

    , d."NrCarsParkedIncorrectly", d."NrLGVsParkedIncorrectly", d."NrMCLsParkedIncorrectly",
    d."NrTaxisParkedIncorrectly", d."NrOGVsParkedIncorrectly", d."NrMiniBusesParkedIncorrectly",
    d."NrBusesParkedIncorrectly",

    d."NrCarsWithDisabledBadgeParkedInPandD",

'' AS "NrMCLsUsingGroundAnchors",
'' AS "NrMCLsUsingOtherStreetFurniture",
'' AS "NrMCLsUsingLockOnWheel", 
'' AS "NrMCLsLockOnHandlebar",
'' AS "NrMCLsWithNoLock",

d."NrBaysSuspended", '' AS "NrBaysSuspendedIncludingMCLPCL", 
    TRIM (CONCAT (d."SuspensionReference", ' ', d."SuspensionReason", ' ', d."SuspensionNotes")) AS "SuspensionDetails", 

    d."Notes", d."DoubleParkingDetails", "MCL_Notes",

'' AS "AllVehiclesParked",
d."Demand" AS "AllVehiclesParkedWeighted", 
d."CapacityAtTimeOfSurvey" AS "AvailableSpacesForParking",
d."Stress" AS "Occupancy",
d."PerceivedCapacityAtTimeOfSurvey" AS "PerceivedSpaces", d."PerceivedStress" AS "PerceivedOccupancy",
d."Demand_Waiting" AS "NrVehiclesWaiting_Weighted", 
d."Demand_Idling" AS "NrVehiclesIdlinging_Weighted", 
d."Demand_Suspended" AS "NrVehiclesInSuspension_Weighted"


    --, d."Enumerator", d."Done"
    --, d."Photos_01", d."Photos_02", d."Photos_03",  d."SurveyAreaName"
    --, d."SupplyGeom" as geom

FROM
(SELECT ris.*,
 su."BeatTitle", s."RestrictionTypeID", s."RestrictionLength", s."RestrictionType Description", 
 s."UnacceptableType Description", s."DetailsOfControl", s."RoadName", s."CPZ",
 "SurveyAreaName", s."WardName", s."ParkingTariffZoneName", s."HospitalZonesBlueBadgeHoldersName", s.item_refs,
 s."SupplyGeom"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su,
(
SELECT a."GeometryID", a."RestrictionTypeID", a."RestrictionLength", 
"UnacceptableTypes"."Description" AS "UnacceptableType Description", 
"BayLineTypes"."Description" AS "RestrictionType Description",
       CASE WHEN ("RestrictionTypeID" < 200 OR "RestrictionTypeID" IN (227, 228, 229, 231)) THEN COALESCE("TimePeriods1"."Description", '')
            ELSE COALESCE("TimePeriods2"."Description", '')
            END  AS "DetailsOfControl",
a."RoadName", a."CPZ", "SurveyAreas"."SurveyAreaName", "Wards"."Name" AS "WardName", "ParkingTariffZones"."ParkingTariffZoneName",
"HospitalZonesBlueBadgeHolders"."HospitalZonesBlueBadgeHoldersName", l.item_refs,
 a.geom AS "SupplyGeom"
 FROM
(((((((((  mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
 LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoWaitingTimeID" is not distinct from "TimePeriods2"."Code")
 LEFT JOIN "local_authority"."Wards_2022" AS "Wards" ON a."WardID" is not distinct from "Wards"."id")
 LEFT JOIN "local_authority"."ParkingTariffZones_2022" AS "ParkingTariffZones" ON a."ParkingTariffZoneID" is not distinct from "ParkingTariffZones"."id")
 LEFT JOIN "local_authority"."HospitalZonesBlueBadgeHolders_2022" AS "HospitalZonesBlueBadgeHolders" ON a."HospitalZonesBlueBadgeHoldersID" is not distinct from "HospitalZonesBlueBadgeHolders"."id")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
 LEFT JOIN (SELECT "GeometryID" AS "GeometryID_Links", ARRAY_AGG ("item_ref") AS item_refs
											 FROM mhtc_operations."RBKC_item_ref_links"
											 GROUP BY "GeometryID" ) AS l ON a."GeometryID" = l."GeometryID_Links")
 ) AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND su."SurveyID" > 0
 --AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
 --AND RiS."Done" IS True
  -- AND s."RoadName" LIKE 'Lower Addison Gardens%'
 ) as d
ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID";