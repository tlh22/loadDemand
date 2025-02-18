/***
 * When supply needs to be changed ...
 ***/
 
-- for Counts (need to break into individual loops)
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
BEGIN

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."SurveyID" IN (107, 108)
        AND "GeometryID" IN (SELECT DISTINCT RiS2."GeometryID"
                            FROM "demand"."RestrictionsInSurveys" RiS2, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a, demand."Surveys" s
                            WHERE RiS2."GeometryID" = r."GeometryID"
                            AND RiS2."SurveyID" = s."SurveyID"
                            AND r."SurveyArea" = a.name
                            AND r."SurveyArea" IN ('1', '2')
                            AND "Enumerator" = 'peter a'
                            AND s."SurveyID" IN (107, 108))
    LOOP
	
	
UPDATE demand."Counts" AS RiS
SET "NrCars"=c."NrCars", "NrLGVs"=c."NrLGVs", "NrMCLs"=c."NrMCLs", "NrTaxis"=c."NrTaxis", "NrPCLs"=c."NrPCLs",
"NrEScooters"=c."NrEScooters", "NrDocklessPCLs"=c."NrDocklessPCLs", "NrOGVs"=c."NrOGVs", "NrMiniBuses"=c."NrMiniBuses", "NrBuses"=c."NrBuses", "NrSpaces"=c."NrSpaces",
"Notes"=c."Notes", "DoubleParkingDetails"=c."DoubleParkingDetails", "NrCars_Suspended"=c."NrCars_Suspended", "NrLGVs_Suspended"=c."NrLGVs_Suspended", "NrMCLs_Suspended"=c."NrMCLs_Suspended",
"NrTaxis_Suspended"=c."NrTaxis_Suspended", "NrPCLs_Suspended"=c."NrPCLs_Suspended", "NrEScooters_Suspended"=c."NrEScooters_Suspended", "NrDocklessPCLs_Suspended"=c."NrDocklessPCLs_Suspended",
"NrOGVs_Suspended"=c."NrOGVs_Suspended", "NrMiniBuses_Suspended"=c."NrMiniBuses_Suspended", "NrBuses_Suspended"=c."NrBuses_Suspended", "NrCarsIdling"=c."NrCarsIdling",
"NrCarsParkedIncorrectly"=c."NrCarsParkedIncorrectly", "NrLGVsIdling"=c."NrLGVsIdling", "NrLGVsParkedIncorrectly"=c."NrLGVsParkedIncorrectly", "NrMCLsIdling"=c."NrMCLsIdling", "NrMCLsParkedIncorrectly"=c."NrMCLsParkedIncorrectly", 
"NrTaxisIdling"=c."NrTaxisIdling", "NrTaxisParkedIncorrectly"=c."NrTaxisParkedIncorrectly", "NrOGVsIdling"=c."NrOGVsIdling", "NrOGVsParkedIncorrectly"=c."NrOGVsParkedIncorrectly", 
"NrMiniBusesIdling"=c."NrMiniBusesIdling", "NrMiniBusesParkedIncorrectly"=c."NrMiniBusesParkedIncorrectly", "NrBusesIdling"=c."NrBusesIdling", "NrBusesParkedIncorrectly"=c."NrBusesParkedIncorrectly", 
"NrCarsWithDisabledBadgeParkedInPandD"=c."NrCarsWithDisabledBadgeParkedInPandD", "MCL_Notes"=c."MCL_Notes", "Supply_Notes"=c."Supply_Notes"
FROM demand."Counts" c
	WHERE RiS."GeometryID" = c."GeometryID"
	AND RiS."SurveyID" = c."SurveyID";
