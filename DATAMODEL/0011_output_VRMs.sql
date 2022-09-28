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

