
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN "MCL_Notes" character varying(10000);

ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN "Supply_Notes" character varying(10000);

/***
 * Output details of MCL bays with chains / broken anchors
 ***/

SELECT
"GeometryID", "SurveyID", "RestrictionTypeID",
"BayLineTypes"."Description" AS "RestrictionDescription",
"GeomShapeID", COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description",
a."RoadName", COALESCE("SurveyAreas"."SurveyAreaName", '')  AS "SurveyAreaName",
 COALESCE("TimePeriods1"."Description", '')  AS "DetailsOfControl",
"RestrictionLength" AS "KerblineLength", "Capacity" AS "TheoreticalBays",
"Notes", "Photos_01"

FROM
     (((((
     --(
     (SELECT s."GeometryID", ris."SurveyID", s."RestrictionTypeID", s."GeomShapeID", s."TimePeriodID", s."RoadName", s."RestrictionLength",
	        s."NrBays", s."Capacity", s."CPZ", s."SurveyAreaID", ris."Photos_01", c."Notes"
        FROM mhtc_operations."Supply" s, demand."RestrictionsInSurveys" ris, demand."Counts" c
        WHERE s."RestrictionTypeID" IN (117, 118)
		 AND s."GeometryID" = ris."GeometryID"
		 AND ris."GeometryID" = c."GeometryID"
		 AND ris."SurveyID" = c."SurveyID"
	 AND (
		upper(c."Notes") LIKE '%CHA%' OR  upper(c."Notes") LIKE '%ANC%' OR  upper(c."Notes") LIKE '%BRO%')
	  )
	 ) AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
	 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")

ORDER BY  "GeometryID", "SurveyID", "RestrictionTypeID"

-- Would be good to output photos with labels??