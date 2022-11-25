/***
 * When data is entered into wrong time period, need to move to correct time period
 ***/

-- for VRMs
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	curr_survey_id INTEGER := 1001;
	curr_GeometryID VARCHAR := 'S_008571';
	new_GeometryID VARCHAR := 'S_008302';
BEGIN


    FOR relevant_restriction_in_survey IN
        SELECT DISTINCT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03", RiS."CaptureSource"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."GeometryID" = curr_GeometryID
        AND RiS."Done" IS true
        AND RiS."SurveyID" = curr_survey_id

    LOOP

        RAISE NOTICE '*****--- Processing % moving to (%) for [%]', curr_GeometryID, new_GeometryID, curr_survey_id;


            UPDATE "demand"."RestrictionsInSurveys"
                SET "DemandSurveyDateTime"=relevant_restriction_in_survey."DemandSurveyDateTime", "Enumerator"=relevant_restriction_in_survey."Enumerator", "Done"=relevant_restriction_in_survey."Done", "SuspensionReference"=relevant_restriction_in_survey."SuspensionReference",
                "SuspensionReason"=relevant_restriction_in_survey."SuspensionReason", "SuspensionLength"=relevant_restriction_in_survey."SuspensionLength", "NrBaysSuspended"=relevant_restriction_in_survey."NrBaysSuspended", "SuspensionNotes"=relevant_restriction_in_survey."SuspensionNotes",
                "Photos_01"=relevant_restriction_in_survey."Photos_01", "Photos_02"=relevant_restriction_in_survey."Photos_02", "Photos_03"=relevant_restriction_in_survey."Photos_03", "CaptureSource"=relevant_restriction_in_survey."CaptureSource"
            WHERE "GeometryID" = new_GeometryID
            AND "SurveyID" = curr_survey_id;

            -- Now add VRMs

            UPDATE "demand"."VRMs"
            SET "GeometryID" = new_GeometryID
            WHERE "GeometryID" = curr_GeometryID
            AND "SurveyID" = curr_survey_id;

            -- Now tidy up ...

            UPDATE "demand"."RestrictionsInSurveys"
            SET "Done" = false, "Enumerator" = NULL, "DemandSurveyDateTime" = NULL, "SuspensionReference" = NULL,
            "SuspensionReason" = NULL, "SuspensionLength" = NULL, "NrBaysSuspended"=NULL, "SuspensionNotes"=NULL,
            "Photos_01"=NULL, "Photos_02"=NULL, "Photos_03"=NULL, "CaptureSource"=NULL
            WHERE "GeometryID" = curr_GeometryID
            AND "SurveyID" = curr_survey_id;


    END LOOP;

END;
$do$;
