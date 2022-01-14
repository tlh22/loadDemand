SELECT "SurveyID", '' AS "Date", "SurveyDay", concat("BeatStartTime", '-', "BeatEndTime") AS "TimePeriod"
	FROM demand."Surveys"
    ORDER BY "SurveyID";