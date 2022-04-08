
SELECT "SurveyID", "SurveyDate", "SurveyDay", concat("BeatStartTime", '-', "BeatEndTime") AS "TimePeriod"
	FROM demand."Surveys"
    ORDER BY "SurveyID";