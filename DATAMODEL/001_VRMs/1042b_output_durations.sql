/***
 * Using RoadName
 ***/

SELECT "VRM", "GeometryID", "RestrictionTypeID", "RoadName", "SurveyDay", first, last, last-first+1 As span, "UserTypeID"

FROM (
SELECT DISTINCT ON ("VRM", "RoadName", "SurveyDay", first) 
        first."VRM", first."GeometryID", first."RestrictionTypeID", first."RoadName", first."SurveyDay", first."SurveyID" As first, last."SurveyID" AS last, first."UserTypeID"
FROM
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay", v."UserTypeID"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."isFirst" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	AND su."RoadName" NOT LIKE '%Car Park%'
	) AS first,
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."isLast" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	AND su."RoadName" NOT LIKE '%Car Park%'
	) AS last
WHERE first."VRM" = last."VRM"
AND first."RoadName" = last."RoadName"
--AND first."SurveyDay" = last."SurveyDay"
AND first."SurveyID" < last."SurveyID"
AND first."VRM" IN ('AJ63-DCZ', 'SN15-ZBZ', 'PF20-EJN')
ORDER BY "VRM", "RoadName", "SurveyDay", first, last
) y

UNION

SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", s."SurveyDay", v."SurveyID" As first, v."SurveyID" AS last, 1 AS span, v."UserTypeID"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."orphan" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	AND su."RoadName" NOT LIKE '%Car Park%'

ORDER BY "VRM", "GeometryID", "SurveyDay", first



SELECT "VRM", "GeometryID", "RestrictionTypeID", "RoadName", "SurveyDay", first, last, last-first+1 As span, "UserTypeID"

FROM (
SELECT DISTINCT ON ("VRM", "RoadName", "SurveyDay", first) 
        first."VRM", first."GeometryID", first."RestrictionTypeID", first."RoadName", first."SurveyDay", first."SurveyID" As first, last."SurveyID" AS last, first."UserTypeID"
FROM
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay", v."UserTypeID"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."isFirst" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	AND su."RoadName" NOT LIKE '%Car Park%'
	) AS first,
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."isLast" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	AND su."RoadName" NOT LIKE '%Car Park%'
	) AS last
WHERE first."VRM" = last."VRM"
AND first."RoadName" = last."RoadName"
--AND first."SurveyDay" = last."SurveyDay"
AND first."SurveyID" < last."SurveyID"
-- AND first."VRM" IN ('AJ63-DCZ', 'SN15-ZBZ', 'PF20-EJN')
ORDER BY "VRM", "RoadName", "SurveyDay", first, last
) y

UNION

SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", s."SurveyDay", v."SurveyID" As first, v."SurveyID" AS last, 1 AS span, v."UserTypeID"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."orphan" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	AND su."RoadName" NOT LIKE '%Car Park%'

ORDER BY "VRM", "GeometryID", "SurveyDay", first