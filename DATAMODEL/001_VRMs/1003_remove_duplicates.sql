/**

--Remove records that are the same, i.e., same VRM within same GeometryID within same beat

SELECT v1.*
FROM demand."VRMs" v1, demand."VRMs" v2
WHERE v1."VRM" = v2."VRM"
AND v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" = v2."SurveyID"
AND v1."ID" < v2."ID";

**/

DELETE FROM demand."VRMs" AS v1
 USING demand."VRMs" v2, mhtc_operations."Supply" s
WHERE v1."VRM" = v2."VRM"
AND v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" = v2."SurveyID"
AND v1."ID" < v2."ID"
AND v1."GeometryID" = s."GeometryID"
--AND s."CPZ" IN ('P', 'F', 'Y')
;

-- Remove blanks

DELETE FROM demand."VRMs" AS v
USING mhtc_operations."Supply" s
WHERE ("VRM" = '-' OR "VRM" IS NULL)
AND ("VehicleTypeID" IS NULL OR "VehicleTypeID" = 0)
AND ("PermitTypeID" IS NULL OR "PermitTypeID" = 0)
AND ("InternationalCodeID" IS NULL OR "InternationalCodeID" = 0)
AND (v."Notes" IS NULL OR LENGTH(TRIM(v."Notes")) = 0)
AND v."GeometryID" = s."GeometryID"
--AND s."CPZ" IN ('P', 'F', 'Y')
;

