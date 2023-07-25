/***
 *  identify different user types within amended VRMs

    There are three types of user category:
     - Resident: VRM observed overnight
     - Commuter: VRM observed in morning and afternoon beat
     - Visitor: VRM observed in either morning or afternoon beat

 ***/

ALTER TABLE demand."VRMs"
    ADD COLUMN IF NOT EXISTS "UserTypeID" INTEGER;

UPDATE demand."VRMs"
SET "UserTypeID" = NULL;

-- Residents
UPDATE demand."VRMs" v
SET "UserTypeID" = 1
FROM demand."Surveys" s
WHERE s."SurveyID" = v."SurveyID"
AND s."BeatStartTime" = '0000';

UPDATE demand."VRMs"
SET "UserTypeID" = 1
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "UserTypeID" = 1
);

-- Commuter
UPDATE demand."VRMs"
SET "UserTypeID" = 2
WHERE "UserTypeID" IS NULL
AND "VRM" IN (
    SELECT v1."VRM"
    FROM demand."VRMs" v1, demand."VRMs" v2
    WHERE v1."VRM" = v2."VRM"
    AND v1."ID" < v2."ID"
    AND (
            (v1."SurveyID" = 102 AND v2."SurveyID" = 103)
            OR (v1."SurveyID" = 202 AND v2."SurveyID" = 203)
            OR (v1."SurveyID" = 302 AND v2."SurveyID" = 303)
        )
);

-- Visitor
UPDATE demand."VRMs"
SET "UserTypeID" = 3
WHERE "UserTypeID" IS NULL;

-- Now add details to RiS

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Residents" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Commuters" double precision;
    
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Visitors" double precision;

DO
$do$
DECLARE
   row RECORD;
   demand_residents real :=0;
   demand_commuters real :=0;
   demand_visitors real :=0;
BEGIN

	ALTER TABLE demand."RestrictionsInSurveys"
	    DISABLE TRIGGER update_demand;

    FOR row IN SELECT "SurveyID", "GeometryID"
                FROM demand."RestrictionsInSurveys"
    LOOP

         RAISE NOTICE '***** Considering (%) for %', row."GeometryID", row."SurveyID";

	    SELECT 
	    SUM(CASE WHEN v."UserTypeID" = 1 THEN b."PCU" ELSE 0 END) AS demand_residents,
	    SUM(CASE WHEN v."UserTypeID" = 2 THEN b."PCU" ELSE 0 END) AS demand_commuters,
	    SUM(CASE WHEN v."UserTypeID" = 3 THEN b."PCU" ELSE 0 END) AS demand_visitors	    
	    INTO demand_residents, demand_commuters, demand_visitors
	    FROM demand."VRMs" v, "demand_lookups"."VehicleTypes" b
	    WHERE v."VehicleTypeID" = b."Code"
	    AND v."SurveyID" = row."SurveyID"
	    AND v."GeometryID" = row."GeometryID"
	    GROUP BY v."SurveyID", v."GeometryID"
	    ;
   
		UPDATE demand."RestrictionsInSurveys" AS RiS
		SET "Demand_Residents" = demand_residents,
		    "Demand_Commuters" = demand_commuters,
		    "Demand_Visitors" = demand_visitors
		WHERE RiS."SurveyID" = row."SurveyID"
	    AND RiS."GeometryID" = row."GeometryID";
	    	    
    END LOOP;
    
    ALTER TABLE demand."RestrictionsInSurveys"
	    ENABLE TRIGGER update_demand;
END
$do$;

    
-- final output

SELECT v."ID", v."SurveyID", s."SurveyDay", CONCAT(s."BeatStartTime", '-', "BeatEndTime") As "SurveyTime",
        v."RoadName", v."RestrictionType Description", v."SideOfStreet",
		v."GeometryID", v."VRM", 
		v."InternationalCodeID", v."Country",
		v."VehicleTypeID", v."VehicleType Description",
        v."PCU",
        "UserType Description",
        --v."PermitTypeID", v."PermitType Description",
        v."Notes"

FROM
(SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "VRM",
"InternationalCodeID", "InternationalCodes"."Description" As "Country",
"VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description",
       su."RestrictionTypeID",
		"BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        a."Notes", su."RoadName", su."SideOfStreet", "UserTypes"."Description" AS "UserType Description", "VehicleTypes"."PCU"

FROM
     ((((((demand."VRMs" AS a
	 LEFT JOIN mhtc_operations."Supply" AS su ON a."GeometryID" = su."GeometryID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON su."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."InternationalCodes" AS "InternationalCodes" ON a."InternationalCodeID" is not distinct from "InternationalCodes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")
     LEFT JOIN "demand_lookups"."UserTypes" AS "UserTypes" ON a."UserTypeID" is not distinct from "UserTypes"."Code")
ORDER BY "GeometryID", "VRM") As v
	 	, demand."Surveys" s
		, demand."RestrictionsInSurveys" r
WHERE v."SurveyID" = s."SurveyID"
AND r."SurveyID" = s."SurveyID"
AND r."GeometryID" = v."GeometryID"
--AND su."CPZ" = 'HS'
--AND s."SurveyID" > 20 and s."SurveyID" < 30
ORDER BY "GeometryID", "VRM", "SurveyID";

--- Where a resident is a vehicle seen in the first and last beats



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

        UPDATE demand."VRMs_Final"
        SET "UserType" = 'Resident'
        WHERE "UserType" IS NULL
        AND "VRM" IN (
            SELECT v1."VRM"
            FROM demand."VRMs_Final" v1, demand."VRMs_Final" v2
            WHERE v1."VRM" = v2."VRM"
            AND v1."ID" < v2."ID"
            AND (
                    (v1."SurveyID" = row.first AND v2."SurveyID" = row.last)
                    OR (v1."SurveyID" = row.last AND v2."SurveyID" = row.first)
                )
        );

    END LOOP;
END
$do$;

UPDATE demand."VRMs_Final"
SET "UserType" = 'Visitor'
WHERE "UserType" IS NULL;

-- Check

SELECT "UserType", COUNT("UserType")
FROM (
SELECT DISTINCT "VRM", "UserType"
FROM demand."VRMs_Final"
	) AS y
GROUP BY "UserType"

-- Cambridge

SELECT "SurveyAreaName", "UserTypeID", COUNT("UserTypeID")
FROM (
SELECT DISTINCT "VRM", "SurveyAreaName", "UserTypeID"
FROM demand."VRMs_Final" v, mhtc_operations."Supply" su LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON su."SurveyAreaID" is not distinct from "SurveyAreas"."Code"

	WHERE v."GeometryID" = su."GeometryID"
	--AND "SurveyAreaName" LIKE 'Romsey East%'

	) AS y
GROUP BY "SurveyAreaName", "UserTypeID"
ORDER BY "SurveyAreaName", "UserTypeID"

-- Output "VRMs_Final"

SELECT v."ID", v."SurveyID", --s."BeatTitle",
        v."GeometryID", --v."RoadName",
		v."VRM", v."VehicleTypeID", --v."VehicleType Description",
        v."RestrictionTypeID", --v."RestrictionType Description",
        --v."PermitTypeID", v."PermitType Description",
        v."Notes"
        --, "Enumerator", "DemandSurveyDateTime"
        , "UserType"
        , "isFirst", "isLast", "orphan"

FROM
(SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "VRM",
"VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description",
       su."RestrictionTypeID",
		"BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        a."Notes", "RoadName"
        , a."UserType"
        , a."isFirst", a."isLast", a."orphan"

FROM
     ((((demand."VRMs_Final" AS a
	 LEFT JOIN mhtc_operations."Supply" AS su ON a."GeometryID" = su."GeometryID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON su."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")
ORDER BY "GeometryID", "VRM") As v
	 	, demand."Surveys" s
		, demand."RestrictionsInSurveys" r
WHERE v."SurveyID" = s."SurveyID"
AND r."SurveyID" = s."SurveyID"
AND r."GeometryID" = v."GeometryID"
--AND su."CPZ" = 'HS'
--AND s."SurveyID" > 20 and s."SurveyID" < 30
ORDER BY "SurveyID", "GeometryID", "VRM"



/***
 * Re-export VRMs
 ***/

SELECT v."ID", v."SurveyID", s."BeatTitle", v."GeometryID", v."RoadName",
		v."PositionID", v."VRM", v."VehicleTypeID", v."VehicleType Description", v."PCU",
        v."RestrictionTypeID", v."RestrictionType Description",
        v."PermitTypeID", v."PermitType Description",
        v."Notes", v."UserType Description"

FROM
(SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "VRM",
"VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description", "VehicleTypes"."PCU" AS "PCU",
       su."RestrictionTypeID",
		"BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        a."Notes", "RoadName", "UserTypes"."Description" AS "UserType Description"

FROM
     (((((demand."VRMs_Final" AS a
	 LEFT JOIN mhtc_operations."Supply" AS su ON a."GeometryID" = su."GeometryID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON su."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")
     LEFT JOIN "demand_lookups"."UserTypes" AS "UserTypes" ON a."UserTypeID" is not distinct from "UserTypes"."Code")
ORDER BY "GeometryID", "VRM") As v
	 	, demand."Surveys" s
		, demand."RestrictionsInSurveys_Final" r
WHERE v."SurveyID" = s."SurveyID"
AND r."SurveyID" = s."SurveyID"
AND r."GeometryID" = v."GeometryID"
AND s."SurveyID" > 0
--AND su."CPZ" = 'HS'
--AND s."SurveyID" > 20 and s."SurveyID" < 30
ORDER BY "GeometryID", "VRM", "SurveyID"


SELECT d."SurveyID", d."SurveyDay", d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description", d."RoadName", d."SideOfStreet",
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", d."Demand"
FROM
(SELECT ris."SurveyID", su."SurveyDay", su."BeatStartTime", su."BeatEndTime", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description", s."RoadName", s."SideOfStreet",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", s."Capacity", v."Demand"
FROM demand."RestrictionsInSurveys_Final" ris, demand."Surveys" su,
(mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

ORDER BY d."SurveyID", d."GeometryID";



-- Cambridge

UPDATE demand."VRMs_Final"
SET "UserTypeID" = NULL;

-- Resident

UPDATE demand."VRMs_Final" v
SET "UserTypeID" = 1
FROM demand."Surveys" s, mhtc_operations."Supply" su LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON su."SurveyAreaID" is not distinct from "SurveyAreas"."Code"
WHERE s."SurveyID" = v."SurveyID"
AND v."GeometryID" = su."GeometryID"
AND s."BeatStartTime" = '0000'
AND "SurveyAreaName" LIKE 'Romsey East%';

UPDATE demand."VRMs_Final" v_f
SET "UserTypeID" = 1
FROM mhtc_operations."Supply" su LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON su."SurveyAreaID" is not distinct from "SurveyAreas"."Code"
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs_Final" v, mhtc_operations."Supply" su LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON su."SurveyAreaID" is not distinct from "SurveyAreas"."Code"
    WHERE "UserTypeID" = 1
	AND v."GeometryID" = su."GeometryID"
	AND "SurveyAreaName" LIKE 'Romsey East%'
)
AND v_f."GeometryID" = su."GeometryID"
AND "SurveyAreaName" LIKE 'Romsey East%';

-- Commuter
UPDATE demand."VRMs_Final" v_f
SET "UserTypeID" = 2
FROM mhtc_operations."Supply" sup LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON sup."SurveyAreaID" is not distinct from "SurveyAreas"."Code"
WHERE "UserTypeID" IS NULL
AND "VRM" IN (
    SELECT v1."VRM"
    FROM
    (demand."VRMs_Final" AS v LEFT JOIN (mhtc_operations."Supply" su LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON su."SurveyAreaID" is not distinct from "SurveyAreas"."Code") as p ON v."GeometryID" = p."GeometryID") AS v1,
    (demand."VRMs_Final" AS v LEFT JOIN (mhtc_operations."Supply" su LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON su."SurveyAreaID" is not distinct from "SurveyAreas"."Code") AS p ON v."GeometryID" = p."GeometryID") AS v2
    WHERE v1."VRM" = v2."VRM"
    AND v1."ID" != v2."ID"
    AND (
            (v1."SurveyID" = 1002 AND v2."SurveyID" = 1003)
            OR (v1."SurveyID" = 2002 AND v2."SurveyID" = 2003)
            OR (v1."SurveyID" = 3002 AND v2."SurveyID" = 3003)
        )

    AND v1."SurveyAreaName" LIKE 'Romsey East%'
    AND v2."SurveyAreaName" LIKE 'Romsey East%'
)
AND v_f."GeometryID" = sup."GeometryID"
AND "SurveyAreaName" LIKE 'Romsey East%';


-- Visitor
UPDATE demand."VRMs_Final" v_f
SET "UserTypeID" = 3
FROM mhtc_operations."Supply" su LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON su."SurveyAreaID" is not distinct from "SurveyAreas"."Code"
WHERE "UserTypeID" IS NULL
AND v_f."GeometryID" = su."GeometryID"
AND "SurveyAreaName" LIKE 'Romsey East%';


--

UPDATE demand."VRMs" v
SET "UserTypeID" = 2
FROM (
SELECT "VRM", "GeometryID", "RestrictionTypeID", "RoadName", "SurveyDay", first, last, last-first+1 As span
FROM (
SELECT
        first."VRM", first."GeometryID", first."RestrictionTypeID", first."RoadName", first."SurveyDay", first."SurveyID" As first, MIN(last."SurveyID") OVER (PARTITION BY last."SurveyID") As last
FROM
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."isFirst" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID") AS first,
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
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
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."orphan" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	) p
	
WHERE p."VRM" = v."VRM"
AND v."UserTypeID" IS NULL
AND p.span > 2



---
-- final output

SELECT "ID", "SurveyID", v."GeometryID", "VRM", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "ParkingActivityTypeID", "ParkingMannerTypeID", v."Notes", "UserTypeID", "isLast", "isFirst", orphan
	FROM demand."VRMs" v, mhtc_operations."Supply" s
	WHERE v."GeometryID" = s."GeometryID"
	AND s."RoadName" LIKE '%Car Park%'