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

COPY demand."VRMs_Final"("SurveyID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "Notes")
FROM 'C:\Users\Public\Documents\STH2211_All_VRMs.csv'
DELIMITER ','
CSV HEADER;


--

UPDATE demand."VRMs_Final"
SET "VehicleTypeID" = 1
WHERE "VehicleTypeID" = 0;


-- RiS

DROP TABLE IF EXISTS demand."RestrictionsInSurveys_Final";

CREATE TABLE IF NOT EXISTS demand."RestrictionsInSurveys_Final"
(
    "SurveyID" integer NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    "DemandSurveyDateTime" timestamp without time zone,
    "Enumerator" character varying(100) COLLATE pg_catalog."default",
    "Done" boolean,
    "SuspensionReference" character varying(100) COLLATE pg_catalog."default",
    "SuspensionReason" character varying(255) COLLATE pg_catalog."default",
    "SuspensionLength" double precision,
    "NrBaysSuspended" integer,
    "SuspensionNotes" character varying(255) COLLATE pg_catalog."default",
    "Photos_01" character varying(255) COLLATE pg_catalog."default",
    "Photos_02" character varying(255) COLLATE pg_catalog."default",
    "Photos_03" character varying(255) COLLATE pg_catalog."default",
    --geom geometry(LineString,27700) NOT NULL,
    CONSTRAINT "RestrictionsInSurveys_Final_pkey" PRIMARY KEY ("SurveyID", "GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys_Final"
    OWNER to postgres;
-- Index: RiS_unique_idx

DROP INDEX IF EXISTS demand."RiS_Final_unique_idx";

CREATE UNIQUE INDEX IF NOT EXISTS "RiS_Final_unique_idx"
    ON demand."RestrictionsInSurveys_Final" USING btree
    ("SurveyID" ASC NULLS LAST, "GeometryID" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

COPY demand."RestrictionsInSurveys_Final"("SurveyID", "GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference",
"SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", "Photos_01", "Photos_02", "Photos_03")
FROM 'C:\Users\Public\Documents\SYS2201_RiS_Final.csv'
DELIMITER ','
CSV HEADER;

-- Insert records that were not Done

INSERT INTO demand."RestrictionsInSurveys_Final"("SurveyID", "GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference",
"SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", "Photos_01", "Photos_02", "Photos_03")
SELECT "SurveyID", RiS."GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference",
"SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND "Done" IS NULL OR "Done" IS false;

/***
UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "geom" = s."geom"
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";
***/

-- Update capacity and demand

ALTER TABLE demand."RestrictionsInSurveys_Final"
    ADD COLUMN "Capacity" INTEGER;

UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "Capacity" =
     CASE WHEN (s."Capacity" - COALESCE(RiS."NrBaysSuspended", 0)) > 0 THEN (s."Capacity" - COALESCE(RiS."NrBaysSuspended", 0))
         ELSE 0
         END
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";

-- Demand

ALTER TABLE demand."RestrictionsInSurveys_Final"
    ADD COLUMN "Demand" FLOAT;

UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "Demand" = v."Demand"
FROM
(SELECT a."SurveyID", a."GeometryID", SUM("VehicleTypes"."PCU") AS "Demand"
        FROM (demand."VRMs_Final" AS a
        LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
        GROUP BY a."SurveyID", a."GeometryID"
  ) AS v
WHERE RiS."GeometryID" = v."GeometryID"
AND RiS."SurveyID" = v."SurveyID";

-- Stress

ALTER TABLE demand."RestrictionsInSurveys_Final"
    ADD COLUMN "Stress" FLOAT;

UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "Stress" =
    CASE
        WHEN "Capacity" = 0 THEN
            CASE
                WHEN COALESCE("Demand", 0) > 0.0 THEN 100.0
                ELSE 0.0
            END
        ELSE
            COALESCE("Demand", 0) / "Capacity"::float * 100.0
    END;