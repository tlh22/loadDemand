/***

E-scooters

***/


SELECT ris."GeometryID", ris."SurveyID", su."BeatTitle", s."RoadName", s."Description" AS "RestrictionType Description",
	   ris."NrEScooters",
	   CASE WHEN (s."RestrictionTypeID" = 101) THEN 'Residents'' bays'
	        WHEN (s."RestrictionTypeID" = 103) THEN 'Pay-by-Phone bays'
			WHEN (s."RestrictionTypeID" IN (108, 110, 111, 112, 113, 114, 120, 121, 124, 165, 166, 167)) THEN 'Other bays'
			WHEN (s."RestrictionTypeID" IN (201, 221, 224)) THEN 'Single Yellow Line'
			WHEN (s."RestrictionTypeID" = 202) THEN 'Double Yellow Line'
			WHEN (s."RestrictionTypeID" IN (117, 118)) THEN 'Motorcycle bay'
			WHEN (s."RestrictionTypeID" = 119) THEN 'On-carriageway Bicycle Bay'
			WHEN (s."RestrictionTypeID" = 168) THEN 'E-scooter and Dockless Bicycle Bay'
			WHEN (s."RestrictionTypeID" = 169) THEN 'Shared Use Bicycle and Motorcycle Permit Holders Bay'
            ELSE 'Other'
            END  AS "Group"
FROM demand."RestrictionsInSurveys" ris, ( mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") s, 
 demand."Surveys" su
WHERE ris."GeometryID" = s."GeometryID"
AND COALESCE("NrEScooters", 0) > 0
-- AND s."RestrictionTypeID" < 200
AND ris."SurveyID" = su."SurveyID"
ORDER BY s."RoadName";


/***

Dockless bikes

***/


SELECT ris."GeometryID", ris."SurveyID", su."BeatTitle", s."RoadName", s."Description" AS "RestrictionType Description",
	   ris."NrDocklessPCLs",
	   CASE WHEN (s."RestrictionTypeID" = 101) THEN 'Residents'' bays'
	        WHEN (s."RestrictionTypeID" = 103) THEN 'Pay-by-Phone bays'
			WHEN (s."RestrictionTypeID" IN (108, 110, 111, 112, 113, 114, 120, 121, 124, 165, 166, 167)) THEN 'Other bays'
			WHEN (s."RestrictionTypeID" IN (201, 221, 224)) THEN 'Single Yellow Line'
			WHEN (s."RestrictionTypeID" = 202) THEN 'Double Yellow Line'
			WHEN (s."RestrictionTypeID" IN (117, 118)) THEN 'Motorcycle bay'
			WHEN (s."RestrictionTypeID" = 119) THEN 'On-carriageway Bicycle Bay'
			WHEN (s."RestrictionTypeID" = 168) THEN 'E-scooter and Dockless Bicycle Bay'
			WHEN (s."RestrictionTypeID" = 169) THEN 'Shared Use Bicycle and Motorcycle Permit Holders Bay'
            ELSE 'Other'
            END  AS "Group"
FROM demand."RestrictionsInSurveys" ris, ( mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") s, 
 demand."Surveys" su
WHERE ris."GeometryID" = s."GeometryID"
AND COALESCE("NrDocklessPCLs", 0) > 0
-- AND s."RestrictionTypeID" < 200
AND ris."SurveyID" = su."SurveyID"
ORDER BY s."RoadName";