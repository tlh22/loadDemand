
SELECT "SurveyID", concat("BeatStartTime", '-', "BeatEndTime") AS "TimePeriod", "SurveyDay", "SurveyDate", "BeatTitle"
	FROM demand."Surveys"
	WHERE "SurveyID" > 0
    ORDER BY "SurveyID";