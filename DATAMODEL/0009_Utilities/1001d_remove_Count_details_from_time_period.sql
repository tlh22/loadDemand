/***
 * When data is entered into wrong time period, need to remove before reloading correct details
 ***/

DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	curr_survey_id INTEGER := x;
	survey_area_name TEXT := 'y';
BEGIN


    FOR relevant_restriction_in_survey IN
        SELECT DISTINCT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03", RiS."CaptureSource"
		FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
		WHERE RiS."GeometryID" = s."GeometryID"
		AND a."Code" = s."SurveyAreaID"
		AND RiS."SurveyID" = curr_survey_id
		AND a."SurveyAreaName" = survey_area_name
    LOOP

        RAISE NOTICE '*****--- Processing % removing from [%] in (%)', relevant_restriction_in_survey."GeometryID", survey_area_name, curr_survey_id;

		-- Clear RiS
	
		UPDATE demand."RestrictionsInSurveys"
		SET "DemandSurveyDateTime"=NULL, "Enumerator"=NULL, "Done"=NULL, "SuspensionReference"=NULL, "SuspensionReason"=NULL, "SuspensionLength"=NULL, "NrBaysSuspended"=NULL, "SuspensionNotes"=NULL, "Photos_01"=NULL, "Photos_02"=NULL, "Photos_03"=NULL, "CaptureSource"=NULL, 
		    "Demand_ALL"=NULL, "Demand"=NULL, "DemandInSuspendedAreas"=NULL, "Demand_Waiting"=NULL, "Demand_Idling"=NULL, "Demand_ParkedIncorrectly"=NULL, "CapacityAtTimeOfSurvey"=NULL, "Stress"=NULL, "PerceivedAvailableSpaces"=NULL, "PerceivedCapacityAtTimeOfSurvey"=NULL, "PerceivedStress"=NULL, "Supply_Notes"=NULL, "MCL_Notes"=NULL, 
			"TheoreticalCapacityAtTimeOfSurvey"=NULL
		WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
		AND "SurveyID" = curr_survey_id;
	
		IF NOT FOUND THEN
			RAISE EXCEPTION 'RiS record not found';
		END IF;
		
		-- Now clear Counts
		
		UPDATE demand."Counts"
		SET "NrCars"=NULL, "NrLGVs"=NULL, "NrMCLs"=NULL, "NrTaxis"=NULL, "NrPCLs"=NULL, "NrEScooters"=NULL, "NrDocklessPCLs"=NULL, "NrOGVs"=NULL, "NrMiniBuses"=NULL, "NrBuses"=NULL, "NrSpaces"=NULL, 
			"Notes"=NULL, 
			"DoubleParkingDetails"=NULL, 
			"NrCars_Suspended"=NULL, "NrLGVs_Suspended"=NULL, "NrMCLs_Suspended"=NULL, "NrTaxis_Suspended"=NULL, "NrPCLs_Suspended"=NULL, "NrEScooters_Suspended"=NULL, "NrDocklessPCLs_Suspended"=NULL, "NrOGVs_Suspended"=NULL, "NrMiniBuses_Suspended"=NULL, "NrBuses_Suspended"=NULL, 
			"NrCarsWaiting"=NULL, "NrLGVsWaiting"=NULL, "NrMCLsWaiting"=NULL, "NrTaxisWaiting"=NULL, "NrOGVsWaiting"=NULL, "NrMiniBusesWaiting"=NULL, "NrBusesWaiting"=NULL, 
			"NrCarsIdling"=NULL, "NrLGVsIdling"=NULL, "NrMCLsIdling"=NULL, "NrTaxisIdling"=NULL, "NrOGVsIdling"=NULL, "NrMiniBusesIdling"=NULL, "NrBusesIdling"=NULL, 
			"NrCarsParkedIncorrectly"=NULL, "NrLGVsParkedIncorrectly"=NULL, "NrMCLsParkedIncorrectly"=NULL, "NrTaxisParkedIncorrectly"=NULL, "NrOGVsParkedIncorrectly"=NULL, "NrMiniBusesParkedIncorrectly"=NULL, "NrBusesParkedIncorrectly"=NULL, 
			"NrCarsWithDisabledBadgeParkedInPandD"=NULL
		WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
		AND "SurveyID" = curr_survey_id;

		IF NOT FOUND THEN
			RAISE EXCEPTION 'Count record not found';
		END IF;

    END LOOP;

END;
$do$;