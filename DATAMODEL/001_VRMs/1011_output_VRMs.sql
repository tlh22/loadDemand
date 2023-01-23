--
"
SELECT v."ID", v."SurveyID", s."SurveyDay", s."BeatStartTime" || '-' || s."BeatEndTime" AS "SurveyTime",
        v."GeometryID", v."RestrictionTypeID", v."RestrictionType Description",
        v."RoadName", v."SideOfStreet",
		v."PositionID", v."VRM", v."VRM_Orig",
		v."InternationalCodeID", v."Country",
		v."VehicleTypeID", v."VehicleType Description", v."PCU",
        v."PermitTypeID", v."PermitType Description",
		v."ParkingActivityTypeID", v."ParkingActivityTypes Description",
		v."ParkingMannerTypeID", v."ParkingMannerTypes Description",
        v."Notes", "Enumerator", "DemandSurveyDateTime",
        CONCAT( COALESCE("SuspensionReference" || '; ', ''), COALESCE("SuspensionReason" || '; ', ''),
                 COALESCE("SuspensionLength" || '; ', ''), COALESCE("SuspensionNotes" || '; ', '') ) AS "SuspensionNotes",
        --"UserType Description" AS "UserType",
        '' AS "UserType"


FROM
(SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "VRM", "VRM_Orig",
		"InternationalCodeID", "InternationalCodes"."Description" As "Country",
		"VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description", "VehicleTypes"."PCU" AS "PCU",
		"ParkingActivityTypeID", "ParkingActivityTypes"."Description" AS "ParkingActivityTypes Description",
		"ParkingMannerTypeID", "ParkingMannerTypes"."Description" AS "ParkingMannerTypes Description",
       su."RestrictionTypeID",
		"BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        --"UserTypes"."Description" AS "UserType Description",
        a."Notes", "RoadName", "SideOfStreet"
        , "CPZ"

FROM
     ((((((
     --(
     (demand."VRMs" AS a
	 LEFT JOIN mhtc_operations."Supply" AS su ON a."GeometryID" = su."GeometryID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON su."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."InternationalCodes" AS "InternationalCodes" ON a."InternationalCodeID" is not distinct from "InternationalCodes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")
	 LEFT JOIN "demand_lookups"."ParkingActivityTypes" AS "ParkingActivityTypes" ON a."ParkingActivityTypeID" is not distinct from "ParkingActivityTypes"."Code")
	 --LEFT JOIN "demand_lookups"."UserTypes" AS "UserTypes" ON a."UserTypeID" is not distinct from "UserTypes"."Code")
	 LEFT JOIN "demand_lookups"."ParkingMannerTypes" AS "ParkingMannerTypes" ON a."ParkingMannerTypeID" is not distinct from "ParkingMannerTypes"."Code")
ORDER BY "GeometryID", "VRM") As v
	 	, demand."Surveys" s
		, demand."RestrictionsInSurveys" r
WHERE v."SurveyID" = s."SurveyID"
AND r."SurveyID" = s."SurveyID"
AND r."GeometryID" = v."GeometryID"
AND s."SurveyID" > 0
--AND su."CPZ" = 'HS'
--AND s."SurveyID" > 20 and s."SurveyID" < 30
--AND "CPZ" IN ('P', 'F', 'Y')
ORDER BY "GeometryID", "VRM", "SurveyID""

