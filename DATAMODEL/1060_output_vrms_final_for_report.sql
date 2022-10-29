

SELECT v."ID", v."SurveyID", s."SurveyDay" AS "Survey Day", s."BeatStartTime" || '-' || s."BeatEndTime" AS "Survey Time"
        , v."GeometryID", v."Restriction Type"
        , v."RoadName" AS "Road Name", v."SideOfStreet" AS "Side of Street"
		, v."VRM"
		, "Country"
		, v."Vehicle Type", v."PCU"
        , v."Permit Type"
        , "ParkingActivityType Description"
		, "ParkingMannerType Description"
		, "UserType Description"
        , v."Notes"
        --, r."NrBaysSuspended"
        --, CONCAT( COALESCE("SuspensionReference" || '; ', ''), COALESCE("SuspensionReason" || '; ', ''),
        --         COALESCE("SuspensionLength" || '; ', ''), COALESCE("SuspensionNotes" || '; ', '') ) AS "Suspension Notes"

FROM
(SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "VRM",
"VehicleTypeID", "VehicleTypes"."Description" AS "Vehicle Type", "VehicleTypes"."PCU" AS "PCU",
       su."RestrictionTypeID",
		"BayLineTypes"."Description" AS "Restriction Type"
		, "InternationalCodes"."Description" As "Country"
        ,"PermitTypeID", "PermitTypes"."Description" AS "Permit Type"
        , "ParkingActivityTypes"."Description" AS "ParkingActivityType Description"
		, "ParkingMannerTypes"."Description" AS "ParkingMannerType Description"
		, "UserTypes"."Description" AS "UserType Description"
        , a."Notes", "RoadName", "SideOfStreet"

FROM
     ((((((((("demand"."VRMs_Final" AS a
	 LEFT JOIN mhtc_operations."Supply" AS su ON a."GeometryID" = su."GeometryID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON su."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."InternationalCodes" AS "InternationalCodes" ON a."InternationalCodeID" is not distinct from "InternationalCodes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")
	 LEFT JOIN "demand_lookups"."ParkingActivityTypes" AS "ParkingActivityTypes" ON a."ParkingActivityTypeID" is not distinct from "ParkingActivityTypes"."Code")
	 LEFT JOIN "demand_lookups"."ParkingMannerTypes" AS "ParkingMannerTypes" ON a."ParkingMannerTypeID" is not distinct from "ParkingMannerTypes"."Code")
	 LEFT JOIN "demand_lookups"."UserTypes" AS "UserTypes" ON a."UserTypeID" is not distinct from "UserTypes"."Code")
     LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON su."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
ORDER BY "GeometryID", "VRM") As v
	 	, "demand"."Surveys" s
		, "demand"."RestrictionsInSurveys_Final" r
WHERE v."SurveyID" = s."SurveyID"
AND r."SurveyID" = s."SurveyID"
AND r."GeometryID" = v."GeometryID"
AND s."SurveyID" > 0
--AND su."CPZ" = 'HS'
--AND s."SurveyID" > 20 and s."SurveyID" < 30
ORDER BY "GeometryID", "VRM", "SurveyID"