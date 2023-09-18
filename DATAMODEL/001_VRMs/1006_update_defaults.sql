-- Need to be selective ...

UPDATE demand."VRMs"
SET "PermitTypeID" = 17  -- MCL
WHERE "VehicleTypeID" = 3;

UPDATE demand."VRMs"
SET "PermitTypeID" = 9
WHERE "PermitTypeID" = 0 OR "PermitTypeID" IS NULL;

--
UPDATE demand."VRMs"
SET "VehicleTypeID" = 1  -- Car
WHERE "VehicleTypeID" = 0;

