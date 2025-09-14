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
WHERE MOD("SurveyID", 100) = 1;

UPDATE demand."VRMs"
SET "UserTypeID" = 1
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "UserTypeID" = 1
);

-- Commuter
/***
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
***/

UPDATE demand."VRMs"
SET "UserTypeID" = 2
WHERE "UserTypeID" IS NULL
AND "VRM" IN (
	SELECT "VRM" FROM
	(SELECT "VRM", FLOOR("SurveyID"::float/100.0) AS "Day", COUNT(*) AS "Total"
	FROM demand."VRMs"
	WHERE MOD("SurveyID", 100) != 1
	GROUP BY "VRM", "Day"
	HAVING COUNT(*) > 2
	) a
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
		v."GeometryID", v."AnonomisedVRM", 
		v."InternationalCodeID", v."Country",
		v."VehicleTypeID", v."VehicleType Description",
        v."PCU",
        "UserType Description",
        --v."PermitTypeID", v."PermitType Description",
        v."Notes"

FROM
(SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "AnonomisedVRM",
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
AND "SurveyID" > 0
ORDER BY "GeometryID", "AnonomisedVRM", "SurveyID";

