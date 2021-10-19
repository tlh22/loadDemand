
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
