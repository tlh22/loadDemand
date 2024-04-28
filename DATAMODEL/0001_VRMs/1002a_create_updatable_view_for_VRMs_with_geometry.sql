-- create an updatable view for VRMs - with geometry attached.

CREATE OR REPLACE VIEW demand."VRMs_View"
AS
 SELECT v.*, s.geom
   FROM demand."VRMs" v,
    mhtc_operations."Supply" s
  WHERE s."GeometryID" = v."GeometryID"
;

--

CREATE OR REPLACE FUNCTION demand."VRMs_View_upd_trig_fn" ()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF tg_op = 'UPDATE' THEN
        IF NEW."VRM" <> OLD."VRM" OR
		   NEW."InternationalCodeID" <> OLD."InternationalCodeID" OR
		   NEW."VehicleTypeID" <> OLD."VehicleTypeID" OR
		   NEW."PermitTypeID" <> OLD."PermitTypeID" OR
		   NEW."ParkingActivityTypeID" <> OLD."ParkingActivityTypeID" OR
		   NEW."ParkingMannerTypeID" <> OLD."ParkingMannerTypeID" OR
		   NEW."Notes" <> OLD."Notes"
		THEN
            RAISE NOTICE 'update VRM';
            UPDATE demand."VRMs"
            SET "VRM" = NEW."VRM"
			, "InternationalCodeID" = NEW."InternationalCodeID"
			, "VehicleTypeID" = NEW."VehicleTypeID"
			, "PermitTypeID" = NEW."PermitTypeID"
			, "ParkingActivityTypeID" = NEW."ParkingActivityTypeID"
			, "ParkingMannerTypeID" = NEW."ParkingMannerTypeID"
			, "Notes" = NEW."Notes"
            WHERE "ID" = OLD."ID";
			RETURN new;
        END IF;
    END IF;
	
    RAISE NOTICE 'new.VRM_View:%', new;
    RAISE NOTICE 'old.VRM_View:%', old;
	
    RETURN NULL;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER "VRMs_View_upd_trig"
    INSTEAD OF UPDATE ON demand."VRMs_View"
    FOR EACH ROW EXECUTE PROCEDURE demand."VRMs_View_upd_trig_fn"();

--
	
CREATE OR REPLACE FUNCTION demand."VRMs_View_delete_trigger_fn" ()
    RETURNS TRIGGER
    AS $$
BEGIN
	IF tg_op = 'DELETE' THEN
	    RAISE NOTICE 'delete VRM';
        DELETE FROM demand."VRMs"
        WHERE "ID" = OLD."ID";
        RETURN old;
    END IF;
	
    RAISE NOTICE 'old.VRM_View:%', old;
	
    RETURN NULL;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER "VRMs_View_delete_trigger"
    INSTEAD OF DELETE ON demand."VRMs_View"
    FOR EACH ROW EXECUTE PROCEDURE demand."VRMs_View_delete_trigger_fn"();