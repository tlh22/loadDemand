--

SELECT "ID", "SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "RoadName", "SubID", "GeometryID", "PositionID",
       "VRM", "VehType", "VehicleTypes"."Description" AS "VehicleType Description"
       --, "VRMs"."PermitType", "PermitTypes"."PermitType" AS "ParkingType Description", "BRType", "BRTypes"."PermitType" AS "BusRes Description"
       , "Notes"
FROM "demand"."VRMs_Watford_Tuesday",
	(SELECT "Code", "Description"
      FROM dblink('hostaddr=127.0.0.1 port=5432 dbname=MasterLookups user=postgres password=OS!2postgres options=-csearch_path=',
		'SELECT "Code", "Description" FROM public."VehicleTypes"') AS "VehicleTypes"("Code" int, "Description" text)) AS "VehicleTypes"
	--,(SELECT cast("Code" as int), "PermitType" FROM "PC1911_Permits") AS "PermitTypes",
	--(SELECT cast("Code" as int), "PermitType" FROM "PC1911_BusRes_Permits") AS "BRTypes"
WHERE "VRM" IS NOT NULL
--AND "VRM" <> '-'
--AND "VRM" <> '_'
--AND "VRM" <> ''
--AND "SurveyDay" = 'Sunday'
AND "VehicleTypes"."Code" is not distinct from cast("VehType" as int)
--AND "PermitTypes"."Code" is not distinct from "VRMs"."PermitType"
--AND "BRTypes"."Code" is not distinct from "BRType"
ORDER BY "VRM", "SurveyID"


