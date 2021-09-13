/***
Add column to keep original details
***/

ALTER TABLE demand."VRMs"
    ADD COLUMN "VRM_Orig" character varying(12);

UPDATE demand."VRMs"
SET "VRM_Orig" = "VRM";