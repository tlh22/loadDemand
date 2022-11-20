/***
 * Reload amended VRMs
 ***/

-- Load data into new table
-- Load data into new table
DROP TABLE IF EXISTS demand."VRMs_Final" CASCADE;
CREATE TABLE demand."VRMs_Final"
(
  "ID" SERIAL,
  "SurveyID" integer,
  "GeometryID" character varying(12),
  "PositionID" integer,
  "VRM" character varying(12),
  "InternationalCodeID" integer,
  "VehicleTypeID" integer,
  "PermitTypeID" integer,
  "ParkingActivityTypeID" integer,
  "ParkingMannerTypeID" integer,
  "Notes" character varying(255),
  CONSTRAINT "VRMs_Final_pkey" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE demand."VRMs_Final"
  OWNER TO postgres;

COPY demand."VRMs_Final"("SurveyID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "PermitTypeID", "Notes")
FROM 'C:\Users\Public\Documents\PC2209_WGR_All_VRMs_local_2.csv'
DELIMITER ','
CSV HEADER;


--

UPDATE demand."VRMs_Final"
SET "VehicleTypeID" = 1
WHERE "VehicleTypeID" = 0;


/***

INSERT INTO demand."VRMs_Final"(
	"SurveyID", "GeometryID", "PositionID", "VRM", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "ParkingActivityTypeID", "ParkingMannerTypeID", "Notes")
SELECT "SurveyID", "GeometryID", "PositionID", "VRM", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "ParkingActivityTypeID", "ParkingMannerTypeID", "Notes"
	FROM demand."VRMs";

***/