/*

Need to change for each CPZ - and ensure correct Supply details

*/

SELECT d."SurveyID", d."SurveyDay", d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description", d."RoadName", d."SideOfStreet",
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", d."Demand", regexp_replace(v."Notes", '(.*?)(?<=<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">)(.*?)(?=<\/p>)', '\2', 'g')  AS "Notes",
d."SurveyAreaName"
FROM
(SELECT ris."SurveyID", su."SurveyDay", su."BeatStartTime", su."BeatEndTime", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description", s."RoadName", s."SideOfStreet",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", ris."Capacity", ris."Demand", s."SurveyAreaName"
FROM demand."RestrictionsInSurveys_Final" ris, demand."Surveys" su,
((mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

 LEFT JOIN  (SELECT "SurveyID", "GeometryID", "Notes"
   FROM demand."Counts"
   --GROUP BY "SurveyID", "GeometryID"
  ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"

WHERE d."SurveyID" > 0
--AND d."Done" IS true
ORDER BY d."GeometryID", d."SurveyID";


-- check total count for each pass


SELECT d."SurveyID", d."BeatTitle", SUM(d."NrBaysSuspended") AS "NrBaysSuspended", SUM(d."Capacity") AS "Capacity", SUM(v."Demand") As "Demand"
FROM
(SELECT ris."SurveyID", su."BeatTitle", s."GeometryID", ris."NrBaysSuspended", s."Capacity"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, mhtc_operations."Supply" s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

 LEFT JOIN  (SELECT "SurveyID", "GeometryID",
   SUM(CASE WHEN "VehicleTypeID" = 1 or "VehicleTypeID" = 2 or "VehicleTypeID" = 7 THEN 1.0  -- Car, LGV or Taxi
            WHEN "VehicleTypeID" = 3 THEN 0.4  -- MCL
            WHEN "VehicleTypeID" = 4 THEN 1.5  -- OGV
            WHEN "VehicleTypeID" = 5 THEN 2.0  -- Bus
            ELSE 1.0  -- Other or Null
      END) AS "Demand"
   FROM demand."VRMs"
   GROUP BY "SurveyID", "GeometryID"
  ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"
WHERE d."SurveyID" > 0
GROUP BY d."SurveyID", d."BeatTitle"
ORDER BY d."SurveyID";




SELECT "GeometryID", regexp_replace("Notes", '(.*?)(?<=0px;\">)(.*?)(?=</p)', '\3'), "Notes"

SELECT "GeometryID", regexp_replace("Notes", '(.*?)(?<=<p)(.*?)>(.*?)', '\2'), "Notes"

SELECT "GeometryID", "Notes", regexp_replace("Notes", '[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">
<html><head><meta name="qrichtext" content="1" /><style type="text/css">
p, li { white-space: pre-wrap; }
</style></head><body style=" font-family:''MS Shell Dlg 2''; font-size:11pt; font-weight:400; font-style:normal;">
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">w</p></body></html>](.*)', '\1')
FROM demand."Counts"
WHERE "Notes" IS NOT NULL;


UPDATE mhtc_operations."Supply"
SET "NrBays" = -2
FROM demand."Counts" c
WHERE c."Notes" IS NOT NULL
AND c."Notes" LIKE '%perp%';


--- Broxbourne schools

SELECT d."SurveyID", d."SurveyDay", d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description", d."RoadName", d."SideOfStreet",
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", d."Demand", regexp_replace(v."Notes", '(.*?)(?<=<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">)(.*?)(?=<\/p>)', '\2', 'g')  AS "Notes",
d."SurveyAreaName", d.school
FROM
(SELECT ris."SurveyID", su."SurveyDay", su."BeatStartTime", su."BeatEndTime", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description", s."RoadName", s."SideOfStreet",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", ris."Capacity", ris."Demand", s."SurveyAreaName", s.school
FROM demand."RestrictionsInSurveys_Final" ris, demand."Surveys" su,
(SELECT a."GeometryID", a."RestrictionTypeID", "BayLineTypes"."Description", a."RoadName", a."SideOfStreet", "SurveyAreas"."SurveyAreaName", sc.school, a.geom
  FROM (((mhtc_operations."Supply" AS a
		 RIGHT JOIN local_authority."PC2206_Schools" AS sc ON ST_DWithin(a.geom, sc.geom, 200.0))
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") ) AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"

	 --AND ST_DWithin(s.geom, sc.geom, 200.0)
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

 LEFT JOIN  (SELECT "SurveyID", "GeometryID", "Notes"
   FROM demand."Counts"
   --GROUP BY "SurveyID", "GeometryID"
  ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"

WHERE d."SurveyID" > 0
--AND d."Done" IS true
ORDER BY d."GeometryID", d."SurveyID"