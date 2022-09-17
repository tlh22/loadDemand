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

--

SELECT v."ID", v."SurveyID", s."BeatTitle", v."GeometryID", v."RoadName",
		v."PositionID", v."VRM", v."VRM_Orig", v."VehicleTypeID", v."VehicleType Description",
        v."RestrictionTypeID", v."RestrictionType Description",
        v."PermitTypeID", v."PermitType Description",
        v."Notes", "Enumerator", "DemandSurveyDateTime"

FROM
(SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "VRM", "VRM_Orig",
"VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description",
       su."RestrictionTypeID",
		"BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        a."Notes", "RoadName"

FROM
     ((((demand."VRMs" AS a
	 LEFT JOIN mhtc_operations."Supply" AS su ON a."GeometryID" = su."GeometryID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON su."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")
ORDER BY "GeometryID", "VRM") As v
	 	, demand."Surveys" s
		, demand."RestrictionsInSurveys" r
WHERE v."SurveyID" = s."SurveyID"
AND r."SurveyID" = s."SurveyID"
AND r."GeometryID" = v."GeometryID"
AND s."SurveyID" > 0
--AND su."CPZ" = 'HS'
--AND s."SurveyID" > 20 and s."SurveyID" < 30
ORDER BY "GeometryID", "VRM", "SurveyID"


--
SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "VRM",
"VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description",
       su."RestrictionTypeID",
		"BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        a."Notes"

FROM
     ((((demand."VRMs" AS a
	 LEFT JOIN mhtc_operations."Supply" AS su ON a."GeometryID" = su."GeometryID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON su."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")

	 WHERE "SurveyID" > 20 and "SurveyID" < 30