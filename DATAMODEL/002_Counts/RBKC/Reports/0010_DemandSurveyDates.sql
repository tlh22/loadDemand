-- Dates for demand by street

/***
SELECT RiS."SurveyID", su."BeatTitle", s."RoadName",TO_CHAR( MIN(RiS."DemandSurveyDateTime"), 'dd/mm/yyyy')  AS "DemandSurveyDate"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY RiS."SurveyID", su."BeatTitle", s."RoadName"
ORDER BY s."RoadName", RiS."SurveyID"

***/

-- can we do this as a crosstab query?



CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM crosstab('
SELECT d1."RoadName"::text, d1."BeatTitle"::text, 
CASE WHEN "DemandSurveyDate_Road" >= ''2022-09-20''::date OR "DemandSurveyDate_Road" <= ''2022-11-14''::date THEN
         TO_CHAR("DemandSurveyDate_Road", ''dd/mm/yyyy'')::text
     ELSE
         TO_CHAR("DemandSurveyDate_Area", ''dd/mm/yyyy'')::text
	 END
FROM

(SELECT s."RoadName"::text, s."SurveyAreaID", su."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Road"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY su."BeatTitle", s."SurveyAreaID", s."RoadName"
ORDER BY s."SurveyAreaID", s."RoadName", su."BeatTitle") d1,

(SELECT a."SurveyAreaID", a."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Area"
FROM (SELECT "SurveyID", "GeometryID", "RoadName", "SurveyAreaID", "BeatTitle"
      FROM mhtc_operations."Supply" s, demand."Surveys" su) a LEFT JOIN demand."RestrictionsInSurveys" RiS ON a."GeometryID" = RiS."GeometryID" AND a."SurveyID" = RiS."SurveyID"
WHERE RiS."SurveyID" > 0
AND RiS."DemandSurveyDateTime" >= ''2022-09-20''::date
AND RiS."DemandSurveyDateTime" <= ''2022-11-14''::date
GROUP BY a."BeatTitle",  a."SurveyAreaID"
ORDER BY  a."SurveyAreaID", a."BeatTitle") d2
	 
WHERE d1."BeatTitle" = d2."BeatTitle"
AND d1."SurveyAreaID" = d2."SurveyAreaID"
					   ORDER BY d1."RoadName", d1."BeatTitle"
')
    AS ct("RoadName" text, "Saturday Afternoon" text, "Sunday Afternoon" text, 
		  "Weekday Afternoon" text, "Weekday Evening" text, "Weekday Overnight" text);


-- Standalone query ...

SELECT d1."RoadName"::text, d1."BeatTitle"::text, 
CASE WHEN "DemandSurveyDate_Road" >= '2022-09-20'::date OR "DemandSurveyDate_Road" <= '2022-11-14'::date THEN
         TO_CHAR("DemandSurveyDate_Road", 'dd/mm/yyyy')::text
     ELSE
         TO_CHAR("DemandSurveyDate_Area", 'dd/mm/yyyy')::text
	 END
FROM

(SELECT s."RoadName"::text, s."SurveyAreaID", su."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Road"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY su."BeatTitle", s."SurveyAreaID", s."RoadName"
ORDER BY s."SurveyAreaID", s."RoadName", su."BeatTitle") d1,

(SELECT a."SurveyAreaID", a."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Area"
FROM (SELECT "SurveyID", "GeometryID", "RoadName", "SurveyAreaID", "BeatTitle"
      FROM mhtc_operations."Supply" s, demand."Surveys" su) a LEFT JOIN demand."RestrictionsInSurveys" RiS ON a."GeometryID" = RiS."GeometryID" AND a."SurveyID" = RiS."SurveyID"
WHERE RiS."SurveyID" > 0
AND RiS."DemandSurveyDateTime" >= '2022-09-20'::date
AND RiS."DemandSurveyDateTime" <= '2022-11-14'::date
GROUP BY a."BeatTitle",  a."SurveyAreaID"
ORDER BY  a."SurveyAreaID", a."BeatTitle") d2
	 
WHERE d1."BeatTitle" = d2."BeatTitle"
AND d1."SurveyAreaID" = d2."SurveyAreaID"
ORDER BY d1."RoadName", d1."BeatTitle"


-- Orig

SELECT s."RoadName"::text, su."BeatTitle"::text, TO_CHAR( MIN(RiS."DemandSurveyDateTime"), 'dd/mm/yyyy')::text AS "DemandSurveyDate"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY su."BeatTitle", s."RoadName"
ORDER BY s."RoadName", su."BeatTitle"

-- ** Check for any records outside survey dates

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."DemandSurveyDateTime", "Demand"
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND NOT (RiS."DemandSurveyDateTime" >= '2022-09-20'::date
AND RiS."DemandSurveyDateTime" <= '2022-11-14'::date)
ORDER BY "DemandSurveyDateTime"

--**** CHECKS

-- ***** Check for time differences on overnights

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 101
--AND TRIM(TO_CHAR(RiS."DemandSurveyDateTime", 'Day')) NOT IN ('Tuesday', 'Wednesday', 'Thursday')
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') NOT IN ('22/09/2022', '27/09/2022', '28/09/2022', '29/09/2022', '04/10/2022', '05/10/2022', '06/10/2022', '12/10/2022', '13/10/2022')
AND NOT ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 0
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT > 6)
ORDER BY "DemandSurveyDateTime"

-- Updates for overnight

-- Add an hour ...
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '1 hour'
WHERE "SurveyID" = 101
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT > 22
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('21/09/2022', '26/09/2022', '11/10/2022')
;

-- Add two hour ...
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '2 hour'
WHERE "SurveyID" = 101
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 22
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('12/10/2022')
;

-- Add six hours ... (not sure what happened here - showing done between 19 and 20)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '6 hour'
WHERE "SurveyID" = 101
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('21/09/2022')
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT < 22
--AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT > 6
;

-- Add six hours ... (not sure what happened here - showing done after 22)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '3 hour'
WHERE "SurveyID" = 101
AND TRIM(TO_CHAR(RiS."DemandSurveyDateTime", 'Day')) IN ('Tuesday', 'Wednesday', 'Thursday')
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT = 22;


-- ***** Check for time differences on afternoons

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 102
--AND TRIM(TO_CHAR(RiS."DemandSurveyDateTime", 'Day')) NOT IN ('Tuesday', 'Wednesday', 'Thursday')
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') NOT IN ('21/09/2022', '22/09/2022', '27/09/2022', '28/09/2022', '29/09/2022', '04/10/2022', '06/10/2022', '12/10/2022', '18/10/2022')
AND NOT ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 14
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT <= 16)
ORDER BY "DemandSurveyDateTime"

-- Updates

-- Add 21 hours ...
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" - interval '21 hour'
WHERE "SurveyID" = 102
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 18
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('11/10/2022')
;

UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" - interval '21 hour'
WHERE "SurveyID" = 102
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 18
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('24/10/2022')
;

-- ***** Check for time differences on evenings

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 103
--AND TRIM(TO_CHAR(RiS."DemandSurveyDateTime", 'Day')) NOT IN ('Tuesday', 'Wednesday', 'Thursday')
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') NOT IN ('21/09/2022', '22/09/2022', '27/09/2022', '28/09/2022', '29/09/2022', '04/10/2022', '12/10/2022')
AND NOT ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 20
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT <= 22)
ORDER BY "DemandSurveyDateTime"

-- Updates

-- Add 25 hours ...
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" - interval '25 hour'
WHERE "SurveyID" = 103
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 18
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('11/10/2022', '24/10/2022')
;


-- ***** Check for time differences on Saturday afternoon

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 104
--AND TRIM(TO_CHAR(RiS."DemandSurveyDateTime", 'Day')) NOT IN ('Saturday')
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') NOT IN ('24/09/2022', '01/10/2022', '15/10/2022', '12/11/2022')
AND NOT ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 14
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT <= 17)
ORDER BY "DemandSurveyDateTime"




-- ***** Check for time differences on Sunday afternoon

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 105
--AND TRIM(TO_CHAR(RiS."DemandSurveyDateTime", 'Day')) NOT IN ('Saturday')
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') NOT IN ('25/09/2022', '09/10/2022', '16/10/2022', '13/11/2022')
AND NOT ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 14
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT <= 17)
ORDER BY "DemandSurveyDateTime"









SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'), RiS."DemandSurveyDateTime" + interval '6 hour'
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 101
AND TRIM(TO_CHAR(RiS."DemandSurveyDateTime", 'Day')) IN ('Tuesday', 'Wednesday', 'Thursday')
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT < 22
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT > 6
--AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT = 22
ORDER BY "DemandSurveyDateTime"