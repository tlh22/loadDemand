/*

All demand details are held on RiS. Output gpkg

*/

DROP MATERIALIZED VIEW IF EXISTS demand."RBKC2401_CountByRestriction" CASCADE;

CREATE MATERIALIZED VIEW demand."RBKC2401_CountByRestriction"
TABLESPACE pg_default

AS

SELECT su."SurveyID", su."SurveyDay"  AS "BeatTItle", ris."GeometryID", item_refs, s."RestrictionTypeID", s."RestrictionType Description", 

s."UnacceptableType Description", s."RestrictionLength", s."RoadName",
s."Capacity" AS "SupplyCapacity", ris."CapacityAtTimeOfSurvey",
ris."Demand", ris."Stress" AS "Occupancy",
ris."PerceivedCapacityAtTimeOfSurvey", ris."PerceivedStress" AS "PerceivedOccupancy",
ris."Demand_Waiting", ris."Demand_Idling", ris."DemandInSuspendedAreas", ris."Demand_ParkedIncorrectly",
ris."PerceivedAvailableSpaces",

    c."NrCars", c."NrLGVs", c."NrMCLs", c."NrTaxis", c."NrPCLs", c."NrEScooters", c."NrDocklessPCLs", c."NrOGVs", c."NrMiniBuses", c."NrBuses", c."NrSpaces",

    c."NrCarsIdling", c."NrLGVsIdling", c."NrMCLsIdling",
    c."NrTaxisIdling", c."NrOGVsIdling", c."NrMiniBusesIdling",
    c."NrBusesIdling"

    , c."NrCarsParkedIncorrectly", c."NrLGVsParkedIncorrectly", c."NrMCLsParkedIncorrectly",
    c."NrTaxisParkedIncorrectly", c."NrOGVsParkedIncorrectly", c."NrMiniBusesParkedIncorrectly",
    c."NrBusesParkedIncorrectly",

    c."NrCarsWithDisabledBadgeParkedInPandD",

    ris."SuspensionReference", ris."SuspensionReason", ris."SuspensionLength", ris."NrBaysSuspended", ris."SuspensionNotes",
    c."Notes", c."DoubleParkingDetails", "MCL_Notes",
    --d."CPZ",
    s."WardName", s."ParkingTariffZoneName", s."HospitalZonesBlueBadgeHoldersName",
	CASE WHEN su."SurveyID" IN (101) THEN to_char(ris."DemandSurveyDateTime" + interval '1' hour, 'Dy DD Mon HH24:MI')
     ELSE to_char(ris."DemandSurveyDateTime" + interval '0' hour, 'Dy DD Mon HH24:MI') 
	 END As "SurveyDateTime",
	 s."SupplyGeom" as geom

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
 --AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
 --AND RiS."Done" IS True
  -- AND s."RoadName" LIKE 'Lower Addison Gardens%'

ORDER BY s."RestrictionTypeID", ris."GeometryID", su."SurveyID";

alter table demand."RBKC2401_CountByRestriction"
    OWNER TO postgres;

create UNIQUE INDEX "idx_RBKC2401_CountByRestriction_id"
    ON demand."RBKC2401_CountByRestriction" USING btree
    ("SurveyID", "GeometryID")
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."RBKC2401_CountByRestriction";