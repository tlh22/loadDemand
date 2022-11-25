/***
 * When data is entered into wrong time period, need to move to correct time period
 ***/

-- for Counts (need to break into individual loops)
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	curr_survey_id INTEGER := 107;
	new_survey_id INTEGER := 108;
BEGIN

    FOR relevant_restriction_in_survey IN
        SELECT DISTINCT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03",
            RiS."CaptureSource", RiS."Demand", RiS."CapacityAtTimeOfSurvey", RiS."Stress", RiS."SupplyCapacity"
        FROM "demand"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
        WHERE RiS."GeometryID" = r."GeometryID"
        AND r."SurveyAreaID" = a."Code"
        AND a."SurveyAreaName" IN ('WHP-1')
        AND RiS."Done" IS true
        AND RiS."SurveyID" = curr_survey_id
		--AND RiS."DemandSurveyDateTime" < '2022-06-29'::date
    LOOP

        -- check to see if the restriction already has a value
        SELECT "Done"
        INTO current_done
        FROM "demand"."RestrictionsInSurveys"
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = new_survey_id;

        IF current_done IS false or current_done IS NULL THEN

            RAISE NOTICE '*****--- Processing % copying from (%) to (%)', relevant_restriction_in_survey."GeometryID", curr_survey_id, new_survey_id;

            UPDATE "demand"."RestrictionsInSurveys"
                SET "DemandSurveyDateTime"=relevant_restriction_in_survey."DemandSurveyDateTime", "Enumerator"=relevant_restriction_in_survey."Enumerator", "Done"=relevant_restriction_in_survey."Done", "SuspensionReference"=relevant_restriction_in_survey."SuspensionReference",
                "SuspensionReason"=relevant_restriction_in_survey."SuspensionReason", "SuspensionLength"=relevant_restriction_in_survey."SuspensionLength", "NrBaysSuspended"=relevant_restriction_in_survey."NrBaysSuspended", "SuspensionNotes"=relevant_restriction_in_survey."SuspensionNotes",
                "Photos_01"=relevant_restriction_in_survey."Photos_01", "Photos_02"=relevant_restriction_in_survey."Photos_02", "Photos_03"=relevant_restriction_in_survey."Photos_03",

                "CaptureSource"=relevant_restriction_in_survey."CaptureSource",
                "Demand"=relevant_restriction_in_survey."Demand",
                "CapacityAtTimeOfSurvey"=relevant_restriction_in_survey."CapacityAtTimeOfSurvey", "Stress"=relevant_restriction_in_survey."Stress",
                "SupplyCapacity"=relevant_restriction_in_survey."SupplyCapacity"

            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = new_survey_id;

            -- Now update Counts

            UPDATE demand."Counts" c1
	        SET "NrCars"=c2."NrCars", "NrLGVs"=c2."NrLGVs", "NrMCLs"=c2."NrMCLs", "NrTaxis"=c2."NrTaxis", "NrPCLs"=c2."NrPCLs", "NrEScooters"=c2."NrEScooters",
	        "NrDocklessPCLs"=c2."NrDocklessPCLs", "NrOGVs"=c2."NrOGVs", "NrMiniBuses"=c2."NrMiniBuses", "NrBuses"=c2."NrBuses", "NrSpaces"=c2."NrSpaces", "Notes"=c2."Notes", "DoubleParkingDetails"=c2."DoubleParkingDetails",
	        "NrCars_Suspended"=c2."NrCars_Suspended", "NrLGVs_Suspended"=c2."NrLGVs_Suspended", "NrMCLs_Suspended"=c2."NrMCLs_Suspended",
	        "NrTaxis_Suspended"=c2."NrTaxis_Suspended", "NrPCLs_Suspended"=c2."NrPCLs_Suspended", "NrEScooters_Suspended"=c2."NrEScooters_Suspended",
	        "NrDocklessPCLs_Suspended"=c2."NrDocklessPCLs_Suspended", "NrOGVs_Suspended"=c2."NrOGVs_Suspended", "NrMiniBuses_Suspended"=c2."NrMiniBuses_Suspended", "NrBuses_Suspended"=c2."NrBuses_Suspended"

            ,"NrCarsWaiting"=c2."NrCarsWaiting",
            "NrLGVsWaiting"=c2."NrLGVsWaiting",
            "NrMCLsWaiting"=c2."NrMCLsWaiting",
            "NrTaxisWaiting"=c2."NrTaxisWaiting",
            "NrOGVsWaiting"=c2."NrOGVsWaiting",
            "NrMiniBusesWaiting"=c2."NrMiniBusesWaiting",
            "NrBusesWaiting"=c2."NrBusesWaiting",

            "NrCarsIdling"=c2."NrCarsIdling",
            "NrLGVsIdling"=c2."NrLGVsIdling",
            "NrMCLsIdling"=c2."NrMCLsIdling",
            "NrTaxisIdling"=c2."NrTaxisIdling",
            "NrOGVsIdling"=c2."NrOGVsIdling",
            "NrMiniBusesIdling"=c2."NrMiniBusesIdling",
            "NrBusesIdling"=c2."NrBusesIdling",

            "NrCarsWithDisabledBadgeParkedInPandD"=c2."NrCarsWithDisabledBadgeParkedInPandD"


            FROM demand."Counts" c2
            WHERE c1."SurveyID" = new_survey_id
            AND c2."SurveyID" = curr_survey_id
            AND c1."GeometryID" = c2."GeometryID"
            AND c1."GeometryID" = relevant_restriction_in_survey."GeometryID";

        ELSE

            RAISE NOTICE '*****--- % already has details on survey id (%) ', relevant_restriction_in_survey."GeometryID", new_survey_id;

        END IF;

    END LOOP;

END;
$do$;
