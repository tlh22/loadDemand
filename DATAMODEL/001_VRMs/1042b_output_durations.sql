/***
 * Using RoadName
 ***/

SELECT "AnonomisedVRM", "GeometryID", "RestrictionTypeID", "RestrictionDescription", "RoadName", "SurveyAreaName", "SurveyDay", first, last, span, "UserTypeID", c."Description" AS "DurationCategory"

FROM (

SELECT "AnonomisedVRM", "GeometryID", "RestrictionTypeID", "RestrictionDescription", "RoadName", "SurveyAreaName", "SurveyDay", first, last, last-first+1 As span, "UserTypeID"

FROM (
SELECT DISTINCT ON ("AnonomisedVRM", "RoadName", "SurveyDay", first) 
        first."AnonomisedVRM", first."GeometryID", first."RestrictionTypeID", first."Description" As "RestrictionDescription", first."RoadName", first."SurveyAreaName", first."SurveyDay", first."SurveyID" As first, last."SurveyID" AS last, first."UserTypeID"
FROM
    (SELECT v."AnonomisedVRM", v."GeometryID", su."RestrictionTypeID", su."Description", su."RoadName", su."SurveyAreaName", v."SurveyID", s."SurveyDay", v."UserTypeID"
    FROM demand."VRMs" v, demand."Surveys" s, 
	(SELECT s."GeometryID", s."RestrictionTypeID", l."Description", s."RoadName", "SurveyAreas"."SurveyAreaName"
	FROM ((mhtc_operations."Supply" s 
		LEFT JOIN toms_lookups."BayLineTypes" l ON s."RestrictionTypeID" = l."Code") 
		LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code")) su
    WHERE v."isFirst" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	AND su."RoadName" NOT LIKE '%Car Park%'
	) AS first,
    (SELECT v."AnonomisedVRM", v."GeometryID", su."RestrictionTypeID", su."Description", su."RoadName", su."SurveyAreaName", v."SurveyID", s."SurveyDay"
    FROM demand."VRMs" v, demand."Surveys" s, 
	(SELECT s."GeometryID", s."RestrictionTypeID", l."Description", s."RoadName", "SurveyAreas"."SurveyAreaName"
	FROM ((mhtc_operations."Supply" s 
		LEFT JOIN toms_lookups."BayLineTypes" l ON s."RestrictionTypeID" = l."Code") 
		LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code")) su
    WHERE v."isLast" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	AND su."RoadName" NOT LIKE '%Car Park%'
	) AS last
WHERE first."AnonomisedVRM" = last."AnonomisedVRM"
AND first."RoadName" = last."RoadName"
--AND first."SurveyDay" = last."SurveyDay"
AND first."SurveyID" < last."SurveyID"
-- AND first."VRM" IN ('AJ63-DCZ', 'SN15-ZBZ', 'PF20-EJN')
ORDER BY "AnonomisedVRM", "RoadName", "SurveyDay", first, last
) y

UNION

SELECT v."AnonomisedVRM", v."GeometryID", su."RestrictionTypeID", su."Description", su."RoadName", su."SurveyAreaName", s."SurveyDay", v."SurveyID" As first, v."SurveyID" AS last, 1 AS span, v."UserTypeID"
    FROM demand."VRMs" v, demand."Surveys" s, 
	(SELECT s."GeometryID", s."RestrictionTypeID", l."Description", s."RoadName", "SurveyAreas"."SurveyAreaName"
	 FROM ((mhtc_operations."Supply" s 
		LEFT JOIN toms_lookups."BayLineTypes" l ON s."RestrictionTypeID" = l."Code") 
		LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code")) su
    WHERE v."orphan" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	AND su."RoadName" NOT LIKE '%Car Park%'
	
	) b, demand_lookups."DurationCategories" c
	WHERE b.span = c."Code"

ORDER BY "AnonomisedVRM", "GeometryID", "SurveyDay", first