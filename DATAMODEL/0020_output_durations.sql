/***
Taken from
-- https://dba.stackexchange.com/questions/17045/efficiently-select-beginning-and-end-of-multiple-contiguous-ranges-in-postgresql

fields added to VRMs
Final query amended ...

***/

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

COPY demand."VRMs_Final"("ID", "SurveyID", "GeometryID", "VRM", "VehicleTypeID")
FROM 'C:\Users\Public\Documents\PC2113_All_VRMs.csv'
DELIMITER ','
CSV HEADER;

-- Basic approach
SELECT
        "VRM",
        "SurveyID",
		"GeometryID",
        (lead <> "SurveyID" + 1 or lead is null) as islast,
        (lag <> "SurveyID" - 1 or lag is null) as isfirst,
        (lead <> "SurveyID" + 1 or lead is null) and (lag <> "SurveyID" - 1 or lag is null) as orphan
FROM
    (

        SELECT "VRM", "SurveyID", "GeometryID",
               lead("SurveyID", 1) over( partition by "VRM", "SurveyDay" order by "SurveyID", "GeometryID", "VRM"),
               lag("SurveyID", 1) over(partition by "VRM", "SurveyDay" order by "SurveyID", "GeometryID", "VRM")
        FROM demand."VRMs_Final" v, "Surveys" s
        WHERE v."SurveyID" = s."SurveyID"
        ORDER BY "VRM", "SurveyID"

     ) AS t

ORDER BY "VRM", "SurveyID";

-- add fields to "VRMs_Final"

ALTER TABLE demand."VRMs_Final"
    ADD COLUMN "isLast" boolean;
ALTER TABLE demand."VRMs_Final"
    ADD COLUMN "isFirst" boolean;
ALTER TABLE demand."VRMs_Final"
    ADD COLUMN "orphan" boolean;

UPDATE demand."VRMs_Final" AS v
SET "isLast" = (lead <> t."SurveyID" + 1 or lead is null),
    "isFirst" = (lag <> t."SurveyID" - 1 or lag is null),
    "orphan" = (lead <> t."SurveyID" + 1 or lead is null) and (lag <> t."SurveyID" - 1 or lag is null)
FROM
    (

        SELECT "VRM", v."SurveyID", "GeometryID",
               lead(v."SurveyID", 1) over( partition by "VRM", "SurveyDay" order by v."SurveyID", "GeometryID", "VRM"),
               lag(v."SurveyID", 1) over(partition by "VRM", "SurveyDay" order by v."SurveyID", "GeometryID", "VRM")
        FROM demand."VRMs_Final" v, demand."Surveys" s
        WHERE s."SurveyID" = v."SurveyID"
        ORDER BY "VRM", "SurveyID"

     ) AS t
WHERE v."VRM" = t."VRM"
AND v."SurveyID" = t."SurveyID"
AND v."GeometryID" = t."GeometryID";

-- Now close at the end of the day

UPDATE demand."VRMs_Final" AS v
SET "isLast" = true
WHERE "SurveyID" IN (103, 110, 208, 308)
AND "isLast" = false
    "isFirst" = (lag <> t."SurveyID" - 1 or lag is null),

-- ?? do we need to open at start of day??

-- Select ...

select
    "VRM", "SurveyID", "GeometryID",
    first,
    coalesce (last, first) as last,
    coalesce (last - first + 1, 1) as span
from
(
    select
    "VRM", "SurveyID", "GeometryID",
    "SurveyID" as first,
    -- this will not be excellent perf. since were calling the view
    -- for each row sequence found. Changing view into temp table
    -- will probably help with lots of values.
    (
        select min("SurveyID")
        from demand."VRMs_Final" as last
        where "isLast" = true
        -- need this since isfirst=true, islast=true on an orphan sequence
        --and last."orphan" = false
        and first."SurveyID" <= last."SurveyID" --- amended
        and first."VRM" = last."VRM"
        and first."GeometryID" = last."GeometryID"
    ) as last
    from
        (select * from demand."VRMs_Final" where "isFirst" = true) as first
) as t
;

----  Issue if vehicle changes GeometryID within day (but stays)

select
    --t."VRM",
	su."SurveyID", --t."GeometryID",
	y."RoadName",
    y.first,
    --coalesce (last, first) as last,
	y.last,
    y.span,
	y.NrInSpan
from
demand."Surveys" su LEFT JOIN
(
    select
        --t."VRM",
        t."SurveyID", --t."GeometryID",
        s."RoadName",
        t.first,
        coalesce (last, first) as last,
        coalesce (t.last - t.first + 1, 1) As span,
        COUNT (t."VRM") AS NrInSpan
    from
    (
        select
        "VRM", "SurveyID", "GeometryID",
        "SurveyID" as first,
        -- this will not be excellent perf. since were calling the view
        -- for each row sequence found. Changing view into temp table
        -- will probably help with lots of values.
        (
            select min(last."SurveyID")
            from demand."VRMs_Final" as last, demand."Surveys" s
            where "isLast" = true
            -- need this since isfirst=true, islast=true on an orphan sequence
            --and last."orphan" = false
            and first."SurveyID" <= last."SurveyID" --- amended
            and first."VRM" = last."VRM"
            and first."GeometryID" = last."GeometryID"
            AND last."SurveyID" = s."SurveyID"
            AND s."SurveyDay" = first."SurveyDay"
        ) as last
        from
            (select v.*, s."SurveyDay" from demand."VRMs_Final" v, demand."Surveys" s
             where "isFirst" = true
             AND v."SurveyID" = s."SurveyID") as first
    ) as t, mhtc_operations."Supply" s
    WHERE t."GeometryID" = s."GeometryID"
    AND s."RestrictionTypeID" = 103
    GROUP BY --t."VRM",
             t."SurveyID",
             --t."GeometryID",
             s."RoadName",
             t.first,
	         t.last,
             span

) y ON su."SurveyID" = y."SurveyID"
;


--- ******* OK now ...

SELECT "VRM", "GeometryID", "RestrictionTypeID", "RoadName", "SurveyDay", first, last, last-first+1 As span
FROM (
SELECT
        first."VRM", first."GeometryID", first."RestrictionTypeID", first."RoadName", first."SurveyDay", first."SurveyID" As first, MIN(last."SurveyID") OVER (PARTITION BY last."SurveyID") As last
FROM
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
    FROM demand."VRMs_Final" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."isFirst" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID") AS first,
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
    FROM demand."VRMs_Final" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."isLast" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID") AS last
WHERE first."VRM" = last."VRM"
AND first."RoadName" = last."RoadName"
AND first."SurveyDay" = last."SurveyDay"
AND first."SurveyID" < last."SurveyID"
--AND first."VRM" IN ('PX16-XCD', 'CA64-RDS')
) As y
UNION
SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", s."SurveyDay", v."SurveyID" As first, v."SurveyID" AS last, 1 AS span
    FROM demand."VRMs_Final" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."orphan" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID";


-- Check
SELECT v."SurveyID", s."SurveyDay", su."RoadName", v."GeometryID", su."RestrictionTypeID", v."VRM", "isFirst", "isLast", "orphan"
FROM demand."VRMs_Final" v, demand."Surveys" s, mhtc_operations."Supply" su
WHERE v."GeometryID" = su."GeometryID"
AND v."SurveyID" = s."SurveyID"
--AND v."VRM" IN ('PX16-XCD', 'CA64-RDS')
AND su."RoadName" IN ('The Mint')
ORDER BY "SurveyID", "VRM"

