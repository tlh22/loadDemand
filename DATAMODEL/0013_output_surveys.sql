
SELECT "SurveyID", "SurveyDate", "SurveyDay", concat("BeatStartTime", '-', "BeatEndTime") AS "TimePeriod", "BeatTitle"
	FROM demand."Surveys"
	WHERE "SurveyID" > 0
    ORDER BY "SurveyID";