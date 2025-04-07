/***

Output details by road

***/

SELECT 

su."BeatTitle", s."roadName", 
SUM(s."Capacity") AS "Capacity_All_2024", SUM(RiS."CapacityAtTimeOfSurvey") AS "CapacityAtTimeOfSurvey_All_2024", SUM(RiS."Demand_ALL") AS "Demand_All_2024",

SUM(CASE WHEN (s."RestrictionTypeID" = 101) THEN s."Capacity" END) AS "Capacity_ResidentBays_2024",
SUM(CASE WHEN (s."RestrictionTypeID" = 101) THEN RiS."CapacityAtTimeOfSurvey" END) AS "CapacityAtTimeOfSurvey_ResidentBays_2024" ,
SUM(CASE WHEN (s."RestrictionTypeID" = 101) THEN RiS."Demand_ALL" END) AS "Demand_ResidentBays_2024" ,

SUM(CASE WHEN (s."RestrictionTypeID" = 103) THEN s."Capacity" END) AS "Capacity_PayByPhone_2024",
SUM(CASE WHEN (s."RestrictionTypeID" = 103) THEN RiS."CapacityAtTimeOfSurvey" END) AS "CapacityAtTimeOfSurvey_PayByPhone_2024" ,
SUM(CASE WHEN (s."RestrictionTypeID" = 103) THEN RiS."Demand_ALL" END) AS "Demand_PayByPhone_2024"

FROM  
     (highways_network."RoadLink" r LEFT JOIN mhtc_operations."Supply" sy ON r."roadName" = sy."RoadName") AS s
	 LEFT JOIN demand."RestrictionsInSurveys" RiS ON RiS."GeometryID" = s."GeometryID"
	 LEFT JOIN demand."Surveys" su ON RiS."SurveyID" = su."SurveyID"
WHERE RiS."SurveyID" > 0
GROUP BY su."BeatTitle", s."roadName"
ORDER BY s."roadName", su."BeatTitle"



SELECT "GeometryID", "roadName"
FROM  (highways_network."RoadLink" r LEFT JOIN mhtc_operations."Supply" sy ON r."roadName" = sy."RoadName") AS s
WHERE "roadName" LIKE '%Albert%'
ORdER BY "roadName"


SELECT 

t."SurveyID", r."roadName", t."RoadName"

FROM  
     highways_network."RoadLink" r 
	 LEFT JOIN (mhtc_operations."Supply" sy 
	            LEFT JOIN demand."RestrictionsInSurveys" RiS ON RiS."GeometryID" = sy."GeometryID") AS t
				ON r."roadName" is not distinct from t."RoadName"
WHERE t."SurveyID" > 0
GROUP BY t."SurveyID", r."roadName"
ORDER BY r."roadName", t."SurveyID"


--

SELECT DISTINCT r."roadName"
FROM  
     highways_network."RoadLink" r 
	 
ORDER BY r."roadName"

--

SELECT 

r."roadName", sy."RoadName"

FROM  
     (SELECT DISTINCT "roadName" FROM highways_network."RoadLink") r 
	 LEFT JOIN mhtc_operations."Supply" sy ON r."roadName" = sy."RoadName"

GROUP BY r."roadName", sy."RoadName"
ORDER BY r."roadName"

--

SELECT 

r."roadName", t."RoadName"

FROM  
     (SELECT DISTINCT "roadName" FROM highways_network."RoadLink") r 
	 LEFT JOIN (mhtc_operations."Supply" sy LEFT JOIN demand."RestrictionsInSurveys" RiS ON RiS."GeometryID" = sy."GeometryID") t
	 ON r."roadName" = t."RoadName"

GROUP BY r."roadName", t."RoadName"
ORDER BY r."roadName"

--

SELECT 

r."roadName", p."RoadName"

FROM  
     (SELECT DISTINCT "roadName" FROM highways_network."RoadLink") r 
	 LEFT JOIN ((mhtc_operations."Supply" sy INNER JOIN demand."RestrictionsInSurveys" RiS ON RiS."GeometryID" = sy."GeometryID") t
	     INNER JOIN demand."Surveys" su ON t."SurveyID" = su."SurveyID") p
	 ON r."roadName" = p."RoadName"

GROUP BY r."roadName", p."RoadName"
ORDER BY r."roadName"

--

SELECT 

p."BeatTitle", r."roadName"

FROM  
     (SELECT DISTINCT "roadName" FROM highways_network."RoadLink") r 
	 LEFT JOIN ((mhtc_operations."Supply" sy INNER JOIN demand."RestrictionsInSurveys" RiS ON RiS."GeometryID" = sy."GeometryID") t
	     INNER JOIN demand."Surveys" su ON t."SurveyID" = su."SurveyID") p
	 ON r."roadName" = p."RoadName"

GROUP BY p."BeatTitle", r."roadName"
ORDER BY r."roadName"

--

SELECT 

su."SurveyID", r."roadName"

FROM  
     demand."Surveys" su, (SELECT DISTINCT "roadName" FROM highways_network."RoadLink") r
	 
WHERE su."SurveyID" > 0
ORDER BY r."roadName", su."SurveyID"

--
SELECT 
d."BeatTitle", d."roadName",

SUM(t."Capacity") AS "Capacity_All_2024", SUM(t."CapacityAtTimeOfSurvey") AS "CapacityAtTimeOfSurvey_All_2024", SUM(t."Demand_ALL") AS "Demand_All_2024",

SUM(CASE WHEN (t."RestrictionTypeID" = 101) THEN t."Capacity" END) AS "Capacity_ResidentBays_2024",
SUM(CASE WHEN (t."RestrictionTypeID" = 101) THEN t."CapacityAtTimeOfSurvey" END) AS "CapacityAtTimeOfSurvey_ResidentBays_2024" ,
SUM(CASE WHEN (t."RestrictionTypeID" = 101) THEN t."Demand_ALL" END) AS "Demand_ResidentBays_2024" ,

SUM(CASE WHEN (t."RestrictionTypeID" = 103) THEN t."Capacity" END) AS "Capacity_PayByPhone_2024",
SUM(CASE WHEN (t."RestrictionTypeID" = 103) THEN t."CapacityAtTimeOfSurvey" END) AS "CapacityAtTimeOfSurvey_PayByPhone_2024" ,
SUM(CASE WHEN (t."RestrictionTypeID" = 103) THEN t."Demand_ALL" END) AS "Demand_PayByPhone_2024"

FROM
(SELECT su."SurveyID", su."BeatTitle", r."roadName"
FROM  demand."Surveys" su, (SELECT DISTINCT "roadName" FROM highways_network."RoadLink") r
WHERE su."SurveyID" > 0) d LEFT JOIN
(SELECT sy."GeometryID", sy."RestrictionTypeID", sy."RoadName", sy."Capacity", RiS."SurveyID", RiS."CapacityAtTimeOfSurvey", RiS."Demand_ALL"
FROM mhtc_operations."Supply" sy INNER JOIN demand."RestrictionsInSurveys" RiS ON RiS."GeometryID" = sy."GeometryID") t
ON d."SurveyID" = t."SurveyID" AND d."roadName" = t."RoadName"

GROUP BY d."roadName", d."BeatTitle"
ORDER BY d."roadName", d."BeatTitle"
