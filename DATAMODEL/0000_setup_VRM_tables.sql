
--SET location = 'Watford';
--SET surveyDay = 'Wednesday';

---

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
-- SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE SCHEMA IF NOT EXISTS "demand";
ALTER SCHEMA "demand" OWNER TO "postgres";

DROP SEQUENCE IF EXISTS "demand"."VRMs_Watford_Wednesday_ID_seq" CASCADE;
CREATE SEQUENCE "demand"."VRMs_Watford_Wednesday_ID_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE "demand"."VRMs_Watford_Wednesday_ID_seq"
    OWNER TO postgres;

--DROP TABLE IF EXISTS "demand"."VRMs_Watford_Wednesday";
CREATE TABLE "demand"."VRMs_Watford_Wednesday"
(
    "ID" integer NOT NULL DEFAULT nextval('"demand"."VRMs_Watford_Wednesday_ID_seq"'::regclass),
    "SurveyDay" character varying(254) COLLATE pg_catalog."default",
    "SurveyID" integer,
    "SurveyTime" character varying(150), 
    "SurveyDate" character varying(150),
    "SubID" character varying(254) COLLATE pg_catalog."default",
    "SurveyArea" character varying(150) COLLATE pg_catalog."default",
    "RoadName" character varying(100) COLLATE pg_catalog."default",
    "GeometryID" character varying(254) COLLATE pg_catalog."default",
    "PositionID" integer,
    "VRM" character varying(254) COLLATE pg_catalog."default",
    "VehType" character varying(254) COLLATE pg_catalog."default",
    "PerType" character varying(254) COLLATE pg_catalog."default",
    "Notes" character varying(254) COLLATE pg_catalog."default",
    CONSTRAINT "VRMs_Watford_Wednesday_pkey" PRIMARY KEY ("ID")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE "demand"."VRMs_Watford_Wednesday"
    OWNER to postgres;

--- TODO: Somehow need to create dynamic script for loading
-- perhaps use VRMs table as base for a defined number of loops ...
-- ** maybe good to have VehType as int

INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 01 , upper("VRM_1"), cast ("VehType_1" as int), "Notes_1" FROM demand."Demand_Merged_Wed" WHERE "VRM_1" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 02 , upper("VRM_2"), cast ("VehType_2" as int), "Notes_2" FROM demand."Demand_Merged_Wed" WHERE "VRM_2" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 03 , upper("VRM_3"), cast ("VehType_3" as int), "Notes_3" FROM demand."Demand_Merged_Wed" WHERE "VRM_3" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 04 , upper("VRM_4"), cast ("VehType_4" as int), "Notes_4" FROM demand."Demand_Merged_Wed" WHERE "VRM_4" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 05 , upper("VRM_5"), cast ("VehType_5" as int), "Notes_5" FROM demand."Demand_Merged_Wed" WHERE "VRM_5" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 06 , upper("VRM_6"), cast ("VehType_6" as int), "Notes_6" FROM demand."Demand_Merged_Wed" WHERE "VRM_6" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 07 , upper("VRM_7"), cast ("VehType_7" as int), "Notes_7" FROM demand."Demand_Merged_Wed" WHERE "VRM_7" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 08 , upper("VRM_8"), cast ("VehType_8" as int), "Notes_8" FROM demand."Demand_Merged_Wed" WHERE "VRM_8" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 09 , upper("VRM_9"), cast ("VehType_9" as int), "Notes_9" FROM demand."Demand_Merged_Wed" WHERE "VRM_9" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 10 , upper("VRM_10"), cast ("VehType_10" as int), "Notes_10" FROM demand."Demand_Merged_Wed" WHERE "VRM_10" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 11 , upper("VRM_11"), cast ("VehType_11" as int), "Notes_11" FROM demand."Demand_Merged_Wed" WHERE "VRM_11" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 12 , upper("VRM_12"), cast ("VehType_12" as int), "Notes_12" FROM demand."Demand_Merged_Wed" WHERE "VRM_12" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 13 , upper("VRM_13"), cast ("VehType_13" as int), "Notes_13" FROM demand."Demand_Merged_Wed" WHERE "VRM_13" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 14 , upper("VRM_14"), cast ("VehType_14" as int), "Notes_14" FROM demand."Demand_Merged_Wed" WHERE "VRM_14" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 15 , upper("VRM_15"), cast ("VehType_15" as int), "Notes_15" FROM demand."Demand_Merged_Wed" WHERE "VRM_15" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 16 , upper("VRM_16"), cast ("VehType_16" as int), "Notes_16" FROM demand."Demand_Merged_Wed" WHERE "VRM_16" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 17 , upper("VRM_17"), cast ("VehType_17" as int), "Notes_17" FROM demand."Demand_Merged_Wed" WHERE "VRM_17" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 18 , upper("VRM_18"), cast ("VehType_18" as int), "Notes_18" FROM demand."Demand_Merged_Wed" WHERE "VRM_18" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 19 , upper("VRM_19"), cast ("VehType_19" as int), "Notes_19" FROM demand."Demand_Merged_Wed" WHERE "VRM_19" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 20 , upper("VRM_20"), cast ("VehType_20" as int), "Notes_20" FROM demand."Demand_Merged_Wed" WHERE "VRM_20" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 21 , upper("VRM_21"), cast ("VehType_21" as int), "Notes_21" FROM demand."Demand_Merged_Wed" WHERE "VRM_21" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 22 , upper("VRM_22"), cast ("VehType_22" as int), "Notes_22" FROM demand."Demand_Merged_Wed" WHERE "VRM_22" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 23 , upper("VRM_23"), cast ("VehType_23" as int), "Notes_23" FROM demand."Demand_Merged_Wed" WHERE "VRM_23" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 24 , upper("VRM_24"), cast ("VehType_24" as int), "Notes_24" FROM demand."Demand_Merged_Wed" WHERE "VRM_24" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 25 , upper("VRM_25"), cast ("VehType_25" as int), "Notes_25" FROM demand."Demand_Merged_Wed" WHERE "VRM_25" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 26 , upper("VRM_26"), cast ("VehType_26" as int), "Notes_26" FROM demand."Demand_Merged_Wed" WHERE "VRM_26" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 27 , upper("VRM_27"), cast ("VehType_27" as int), "Notes_27" FROM demand."Demand_Merged_Wed" WHERE "VRM_27" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 28 , upper("VRM_28"), cast ("VehType_28" as int), "Notes_28" FROM demand."Demand_Merged_Wed" WHERE "VRM_28" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 29 , upper("VRM_29"), cast ("VehType_29" as int), "Notes_29" FROM demand."Demand_Merged_Wed" WHERE "VRM_29" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 30 , upper("VRM_30"), cast ("VehType_30" as int), "Notes_30" FROM demand."Demand_Merged_Wed" WHERE "VRM_30" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 31 , upper("VRM_31"), cast ("VehType_31" as int), "Notes_31" FROM demand."Demand_Merged_Wed" WHERE "VRM_31" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 32 , upper("VRM_32"), cast ("VehType_32" as int), "Notes_32" FROM demand."Demand_Merged_Wed" WHERE "VRM_32" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 33 , upper("VRM_33"), cast ("VehType_33" as int), "Notes_33" FROM demand."Demand_Merged_Wed" WHERE "VRM_33" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 34 , upper("VRM_34"), cast ("VehType_34" as int), "Notes_34" FROM demand."Demand_Merged_Wed" WHERE "VRM_34" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 35 , upper("VRM_35"), cast ("VehType_35" as int), "Notes_35" FROM demand."Demand_Merged_Wed" WHERE "VRM_35" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 36 , upper("VRM_36"), cast ("VehType_36" as int), "Notes_36" FROM demand."Demand_Merged_Wed" WHERE "VRM_36" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 37 , upper("VRM_37"), cast ("VehType_37" as int), "Notes_37" FROM demand."Demand_Merged_Wed" WHERE "VRM_37" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 38 , upper("VRM_38"), cast ("VehType_38" as int), "Notes_38" FROM demand."Demand_Merged_Wed" WHERE "VRM_38" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 39 , upper("VRM_39"), cast ("VehType_39" as int), "Notes_39" FROM demand."Demand_Merged_Wed" WHERE "VRM_39" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 40 , upper("VRM_40"), cast ("VehType_40" as int), "Notes_40" FROM demand."Demand_Merged_Wed" WHERE "VRM_40" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 41 , upper("VRM_41"), cast ("VehType_41" as int), "Notes_41" FROM demand."Demand_Merged_Wed" WHERE "VRM_41" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 42 , upper("VRM_42"), cast ("VehType_42" as int), "Notes_42" FROM demand."Demand_Merged_Wed" WHERE "VRM_42" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 43 , upper("VRM_43"), cast ("VehType_43" as int), "Notes_43" FROM demand."Demand_Merged_Wed" WHERE "VRM_43" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 44 , upper("VRM_44"), cast ("VehType_44" as int), "Notes_44" FROM demand."Demand_Merged_Wed" WHERE "VRM_44" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 45 , upper("VRM_45"), cast ("VehType_45" as int), "Notes_45" FROM demand."Demand_Merged_Wed" WHERE "VRM_45" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 46 , upper("VRM_46"), cast ("VehType_46" as int), "Notes_46" FROM demand."Demand_Merged_Wed" WHERE "VRM_46" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 47 , upper("VRM_47"), cast ("VehType_47" as int), "Notes_47" FROM demand."Demand_Merged_Wed" WHERE "VRM_47" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 48 , upper("VRM_48"), cast ("VehType_48" as int), "Notes_48" FROM demand."Demand_Merged_Wed" WHERE "VRM_48" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 49 , upper("VRM_49"), cast ("VehType_49" as int), "Notes_49" FROM demand."Demand_Merged_Wed" WHERE "VRM_49" IS NOT NULL;
INSERT INTO "demand"."VRMs_Watford_Wednesday" ("SurveyDay", "SurveyID", "SurveyTime", "SurveyDate", "SubID", "RoadName", "GeometryID", "PositionID" , "VRM", "VehType", "Notes")
 SELECT "SurveyDay", cast ("SurveyID" as int), "SurveyTime", "SurveyDate", "SectionID", "RoadName", "GeometryID", 50 , upper("VRM_50"), cast ("VehType_50" as int), "Notes_50" FROM demand."Demand_Merged_Wed" WHERE "VRM_50" IS NOT NULL;
