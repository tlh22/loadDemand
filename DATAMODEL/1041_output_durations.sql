/***
Taken from
-- https://dba.stackexchange.com/questions/17045/efficiently-select-beginning-and-end-of-multiple-contiguous-ranges-in-postgresql

fields added to VRMs
Final query amended ...

***/

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

/**
UPDATE demand."VRMs_Final"
SET "isLast" = NULL;
UPDATE demand."VRMs_Final"
SET "isFirst" = NULL;
UPDATE demand."VRMs_Final"
SET "orphan" = NULL;
**/

-- In this case, considering by road name (could also consider by GeometryID)

UPDATE demand."VRMs_Final" AS v
SET "isLast" = (lead <> t."SurveyID" + 1 or lead is null),
    "isFirst" = (lag <> t."SurveyID" - 1 or lag is null),
    "orphan" = (lead <> t."SurveyID" + 1 or lead is null) and (lag <> t."SurveyID" - 1 or lag is null)
FROM
    (
        SELECT v."ID", v."VRM", v."SurveyID", su."RoadName",
               lead(v."SurveyID", 1) over( partition by "VRM", "SurveyDay" order by v."SurveyID", su."RoadName", v."VRM"),
               lag(v."SurveyID", 1) over(partition by "VRM", "SurveyDay" order by v."SurveyID", su."RoadName", v."VRM")
        FROM demand."VRMs_Final" v, demand."Surveys" s, mhtc_operations."Supply" su
        WHERE s."SurveyID" = v."SurveyID"
		AND v."GeometryID" = su."GeometryID"
        ORDER BY "VRM", "SurveyID"
     ) AS t
WHERE v."ID" = t."ID"
;

DROP TYPE possible_spans CASCADE;
CREATE TYPE possible_spans AS ("VRM" VARCHAR(12), "GeometryID" VARCHAR(12), "RestrictionTypeID" INTEGER, "RoadName" VARCHAR(254),
                               "SurveyDay" VARCHAR(50), "firstSurveyID" INTEGER, "lastSurveyID" INTEGER,
                               span INTEGER);

--DROP FUNCTION get_all_durations();

CREATE OR REPLACE FUNCTION get_all_durations() RETURNS SETOF possible_spans AS
$BODY$
--DO
--$do$
DECLARE
    row RECORD;
    possible_spans RECORD;
    currentVRM TEXT;
    lastVRM TEXT;
    currentStartSurveyID INTEGER;
    lastStartSurveyID INTEGER;
    skip BOOLEAN;
BEGIN

    FOR row IN SELECT "SurveyDay", min("SurveyID") as first, max("SurveyID") as last
                    FROM demand."Surveys" s
                    GROUP BY "SurveyDay"
                    ORDER BY min("SurveyID")
    LOOP

        RAISE NOTICE '***** Considering (%) [%-%]', row."SurveyDay", row.first, row.last;

        FOR possible_spans IN
            SELECT "VRM", "GeometryID", "RestrictionTypeID", "RoadName", "SurveyDay", "firstSurveyID", "lastSurveyID", "lastSurveyID"-"firstSurveyID"+1 As span
            FROM (
                SELECT
                    first."VRM", first."GeometryID", first."RestrictionTypeID", first."RoadName", first."SurveyDay", first."SurveyID" As "firstSurveyID",
                    MIN(last."SurveyID") OVER (PARTITION BY last."SurveyID") As "lastSurveyID"
                FROM
                    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
                    FROM demand."VRMs_Final" v, demand."Surveys" s, mhtc_operations."Supply" su
                    WHERE v."isFirst" = true
                    AND v."GeometryID" = su."GeometryID"
                    AND v."SurveyID" = s."SurveyID"
                    AND s."SurveyDay" = row."SurveyDay"
                    AND s."SurveyID" != row.first) AS first,
                    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
                    FROM demand."VRMs_Final" v, demand."Surveys" s, mhtc_operations."Supply" su
                    WHERE v."isLast" = true
                    AND v."GeometryID" = su."GeometryID"
                    AND v."SurveyID" = s."SurveyID"
                    AND s."SurveyDay" = row."SurveyDay"
                    AND s."SurveyID" != row.last) AS last
                WHERE first."VRM" = last."VRM"
                AND first."RoadName" = last."RoadName"
                AND first."SurveyDay" = last."SurveyDay"
                AND first."SurveyID" < last."SurveyID"
                ) AS y
                --ORDER BY "VRM", "firstSurveyID", "lastSurveyID"
            UNION
                SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", s."SurveyDay", v."SurveyID" As "firstSurveyID", v."SurveyID" AS "lastSurveyID", 1 AS span
                FROM demand."VRMs_Final" v, demand."Surveys" s, mhtc_operations."Supply" su
                WHERE v."orphan" = true
                AND v."GeometryID" = su."GeometryID"
                AND v."SurveyID" = s."SurveyID"
                AND s."SurveyDay" = row."SurveyDay"
                AND (s."SurveyID" != row.first
                AND s."SurveyID" != row.last)
             ORDER BY "VRM", "firstSurveyID", "lastSurveyID"
        LOOP

            skip = false;
            currentVRM = possible_spans."VRM";
            currentStartSurveyID = possible_spans."firstSurveyID";

            RAISE NOTICE '*****--- Considering (%) starting at survey id %', currentVRM, currentStartSurveyID;

            IF currentVRM = lastVRM THEN
                IF currentStartSurveyID = lastStartSurveyID THEN
                    -- Skip
                    --skip = true;
                    CONTINUE;
                END IF;
            END IF;

            RETURN NEXT possible_spans;

            lastVRM = currentVRM;
            lastStartSurveyID = currentStartSurveyID;

        END LOOP;

    END LOOP;

END;
--$do$;
$BODY$
LANGUAGE plpgsql;

-- Check
SELECT v."SurveyID", s."SurveyDay", su."RoadName", v."GeometryID", su."RestrictionTypeID", v."VRM", "isFirst", "isLast", "orphan"
FROM demand."VRMs_Final" v, demand."Surveys" s, mhtc_operations."Supply" su
WHERE v."GeometryID" = su."GeometryID"
AND v."SurveyID" = s."SurveyID"
--AND v."VRM" IN ('PX16-XCD', 'CA64-RDS')
AND su."RoadName" IN ('The Mint')
ORDER BY "SurveyID", "VRM"




DO
$do$
DECLARE
   row RECORD;
BEGIN
    FOR row IN SELECT "SurveyDay", min("SurveyID") as first, max("SurveyID") as last
                FROM demand."Surveys" s
                GROUP BY "SurveyDay"
                ORDER BY min("SurveyID")
    LOOP

        RAISE NOTICE '***** Considering (%)', row."SurveyDay";

        SELECT * FROM get_all_durations()
        WHERE "SurveyDay" = row."SurveyDay"
        AND ("firstSurveyID" = row.first
        OR "lastSurveyID" = row.last)

    END LOOP;
END
$do$;