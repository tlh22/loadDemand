/***
Add column to keep original details
***/

ALTER TABLE demand."VRMs"
    ADD COLUMN "VRM_Orig" character varying(12);

UPDATE demand."VRMs" AS v
SET "VRM_Orig" = v."VRM"
FROM mhtc_operations."Supply" s
WHERE "VRM_Orig" IS NULL
AND v."GeometryID" = s."GeometryID"
--AND s."CPZ" IN ('P', 'F', 'Y')
;