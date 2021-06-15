SELECT "SurveyID", concat("BeatStartTime", '-', "BeatEndTime") AS "TimePeriod", "SurveyDay"
	FROM demand."Surveys";