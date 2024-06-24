-- Need to be selective ...

UPDATE demand."VRMs"
SET "PermitTypeID" = 17  -- MCL
WHERE "VehicleTypeID" = 3;

UPDATE demand."VRMs"
SET "PermitTypeID" = 9
WHERE "PermitTypeID" = 0 OR "PermitTypeID" IS NULL;

--

UPDATE demand."VRMs"
SET "VehicleTypeID" = 2
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 2
);

UPDATE demand."VRMs"
SET "VehicleTypeID" = 3
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 3
);

UPDATE demand."VRMs"
SET "VehicleTypeID" = 4
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 4
);

UPDATE demand."VRMs"
SET "VehicleTypeID" = 5
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 5
);

-- anything else is car

UPDATE demand."VRMs"
SET "VehicleTypeID" = 1  -- Car
WHERE "VehicleTypeID" = 0;
