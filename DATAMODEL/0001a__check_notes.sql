/***
Check for changes to supply and other notes recorded during the demand surveys
***/

SELECT c."SurveyID", s."GeometryID", s."RoadName", c."Notes" AS "Info"
FROM demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s, demand."Counts" c
WHERE ris."GeometryID" = s."GeometryID"
AND ris."GeometryID" = c."GeometryID"
AND ris."SurveyID" = c."SurveyID"
AND LENGTH(c."Notes") > 0

UNION

SELECT ris."SurveyID", s."GeometryID", s."RoadName", CONCAT("SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes") AS "Info"
FROM demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
WHERE ris."GeometryID" = s."GeometryID"
AND 
(
   LENGTH("SuspensionReference") > 0
OR LENGTH("SuspensionReason") > 0
OR "SuspensionLength" > 0
OR "NrBaysSuspended" > 0
OR LENGTH("SuspensionNotes") > 0
)
