-- Remove "Done" flag and clear any details

UPDATE demand."RestrictionsInSurveys_FPB" AS ris
SET "DemandSurveyDateTime" = NULL, "Enumerator" = NULL, "Done" = NULL, "SuspensionReference" = NULL, "SuspensionReason" = NULL,
"SuspensionLength" = NULL, "NrBaysSuspended" = NULL, "SuspensionNotes" = NULL, "Photos_01" = NULL, "Photos_02" = NULL, "Photos_03" = NULL

-- actually this is not needed ...

FROM demand."Surveys" su, mhtc_operations."Supply_MASTER_210318" s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND s."CPZ" = 'FPC'
 AND substring(su."BeatTitle" from '\((.+)\)') LIKE 'FPC'


-- reset VRMs


SELECT v.*
FROM demand."VRMs" v, mhtc_operations."Supply_MASTER_210318" su
	 	, demand."Surveys" s
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = su."GeometryID"
AND su."CPZ" = 'FPB'
ORDER BY "GeometryID", "VRM", "SurveyID"



SELECT v."ID", v."SurveyID", s."BeatTitle", v."GeometryID", su."RoadName",
		v."PositionID", v."VRM", v."VehicleTypeID", v."VehicleType Description",
        v."RestrictionTypeID", v."RestrictionType Description",
        v."PermitTypeID", v."PermitType Description",
        v."Notes"

FROM
(SELECT "ID", "SurveyID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description",
        "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        "Notes"

FROM
     (((demand."VRMs" AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")

ORDER BY "GeometryID", "VRM") As v,
	 	mhtc_operations."Supply_MASTER_210318" su
	 	, demand."Surveys" s
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = su."GeometryID"
AND su."CPZ" = 'FP'
ORDER BY "GeometryID", "VRM", "SurveyID"

