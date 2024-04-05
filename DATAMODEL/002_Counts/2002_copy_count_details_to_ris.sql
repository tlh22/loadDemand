-- set up fields in RiS

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCars" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxis" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrPCLs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrEScooters" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrDocklessPCLs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVs" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBuses" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBuses" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrSpaces" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Notes" character varying(10000);

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "DoubleParkingDetails" character varying;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCars_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxis_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrPCLs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrEScooters_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrDocklessPCLs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVs_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBuses_Suspended" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBuses_Suspended" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCarsIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCarsParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVsIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVsParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLsIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLsParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxisIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxisParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVsIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVsParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBusesIdling" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBusesParkedIncorrectly" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCarsWithDisabledBadgeParkedInPandD" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "MCL_Notes" character varying(10000);
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Supply_Notes" character varying(10000);
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Parking_Notes" character varying(10000);

-- Add relevant calculated fields

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedAvailableSpaces" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedCapacityAtTimeOfSurvey" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedStress" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "SupplyCapacity" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "CapacityAtTimeOfSurvey" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Stress" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Suspended" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Waiting" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Idling" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_ParkedIncorrectly" double precision;
	
-- And now for Counts
    
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "MCL_Notes" character varying(10000);
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "Supply_Notes" character varying(10000);
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "Parking_Notes" character varying(10000);
    
-- Now copy

UPDATE demand."RestrictionsInSurveys" AS RiS
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

-- Waiting vehicles

-- Waiting vehicles

ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrCarsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrLGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMCLsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrTaxisWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrOGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrBusesWaiting" integer;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrCarsWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrLGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMCLsWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrTaxisWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrOGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesWaiting" integer;
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "NrBusesWaiting" integer;