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
  "SectionID" integer,
  "GeometryID" character varying(12),
  "PositionID" integer,
  "VRM" character varying(12),
  "VehicleTypeID" integer,
  "RestrictionTypeID" integer,
  "PermitTypeID" integer,
  "Notes" character varying(255),
  CONSTRAINT "VRMs_Final_pkey" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE demand."VRMs_Final"
  OWNER TO postgres;

COPY demand."VRMs_Final"("SurveyID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "PermitTypeID", "Notes")
FROM 'C:\Users\Public\Documents\PC2209_All_VRMs.csv'
DELIMITER ','
CSV HEADER;


--

UPDATE demand."VRMs_Final"
SET "VehicleTypeID" = 1
WHERE "VehicleTypeID" = 0;
