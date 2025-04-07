/***
Create table with groups of restrictions
***/

DROP TABLE IF EXISTS mhtc_operations.restriction_groups CASCADE;

CREATE TABLE mhtc_operations.restriction_groups
(
    id SERIAL,
	"group_id" INTEGER NOT NULL,
	"RestrictionTypeID" INTEGER NOT NULL,
    CONSTRAINT "restriction_groups_pkey" PRIMARY KEY (id)
)
TABLESPACE pg_default;

ALTER TABLE mhtc_operations.restriction_groups
    OWNER to postgres;

DROP TABLE IF EXISTS mhtc_operations.restriction_group_names CASCADE;

CREATE TABLE mhtc_operations.restriction_group_names
(
    id SERIAL,
	"group_name" character varying(254) COLLATE pg_catalog."default",
    CONSTRAINT "restriction_group_names_pkey" PRIMARY KEY (id)
)
TABLESPACE pg_default;

INSERT INTO mhtc_operations.restriction_group_names(id, "group_name")
VALUES (1, 'Other bays');

INSERT INTO mhtc_operations.restriction_groups("group_id", "RestrictionTypeID")
SELECT 1, "RestrictionTypeID"
FROM (
VALUES (108), (110), (111), (112), (113), (114), (120), (121), (124), (165), (166), (167)
) AS tmp("RestrictionTypeID")

-- Car Club Bays, Diplomat Only Bays, Disabled Blue Badge Bays, Electric Vehicle Charging Bays, Loading Bays, Doctor Bays, Police Bays, Taxi Ranks, Accessible Permit Holder Bays and Estate Permit Holder Bays. 


