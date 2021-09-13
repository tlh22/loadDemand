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
               lead("SurveyID", 1) over( partition by "VRM" order by "SurveyID", "GeometryID", "VRM"),
               lag("SurveyID", 1) over(partition by "VRM" order by "SurveyID", "GeometryID", "VRM")
        FROM demand."VRMs"
        ORDER BY "VRM", "SurveyID"

     ) AS t

ORDER BY "VRM", "SurveyID";

-- add fields to "VRMs"

ALTER TABLE demand."VRMs"
    ADD COLUMN "isLast" boolean;
ALTER TABLE demand."VRMs"
    ADD COLUMN "isFirst" boolean;
ALTER TABLE demand."VRMs"
    ADD COLUMN "orphan" boolean;

UPDATE demand."VRMs" AS v
SET "isLast" = (lead <> t."SurveyID" + 1 or lead is null),
    "isFirst" = (lag <> t."SurveyID" - 1 or lag is null),
    "orphan" = (lead <> t."SurveyID" + 1 or lead is null) and (lag <> t."SurveyID" - 1 or lag is null)
FROM
    (

        SELECT "VRM", "SurveyID", "GeometryID",
               lead("SurveyID", 1) over( partition by "VRM" order by "SurveyID", "GeometryID", "VRM"),
               lag("SurveyID", 1) over(partition by "VRM" order by "SurveyID", "GeometryID", "VRM")
        FROM demand."VRMs"
        ORDER BY "VRM", "SurveyID"

     ) AS t
WHERE v."VRM" = t."VRM"
AND v."SurveyID" = t."SurveyID"
AND v."GeometryID" = t."GeometryID";

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
        from demand."VRMs" as last
        where "isLast" = true
        -- need this since isfirst=true, islast=true on an orphan sequence
        --and last."orphan" = false
        and first."SurveyID" <= last."SurveyID" --- amended
        and first."VRM" = last."VRM"
        and first."GeometryID" = last."GeometryID"
    ) as last
    from
        (select * from demand."VRMs" where "isFirst" = true) as first
) as t
;
