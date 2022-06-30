/***
 * When data is entered into a different time period, need to be to across to correct time period
 ***/

 -- for Haringey

 -- data is entered into incorrect project

 -- Copy across VRMs

SELECT  v."SurveyID", v."SectionID", v."GeometryID", v."PositionID", v."VRM", v."VehicleTypeID", v."RestrictionTypeID", v."PermitTypeID", v."Notes"
	FROM "demand_WGR"."VRMs" v, "demand_WGR"."Surveys" s, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = r."GeometryID"
AND r."SurveyArea" = a.name
AND r."SurveyArea" IN ('7S-7', '7S-6');

INSERT INTO "demand_WGR"."VRMs"(
	"ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes")
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?); -- Need to check that RiS is not done ...


SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
	FROM "demand_WGR"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = r."GeometryID"
AND r."SurveyArea" = a.name
AND r."SurveyArea" IN ('7S-7', '7S-6')
AND RiS."Done" IS true;


UPDATE "demand"."RestrictionsInSurveys" AS RiS1
	SET "DemandSurveyDateTime"=RiS."DemandSurveyDateTime", "Enumerator"=RiS."Enumerator", "Done"=RiS."Done", "SuspensionReference"=RiS."SuspensionReference", "SuspensionReason"=RiS."SuspensionReason", "SuspensionLength"=RiS."SuspensionLength", "NrBaysSuspended"=RiS."NrBaysSuspended", "SuspensionNotes"=RiS."SuspensionNotes",
	"Photos_01"=RiS."Photos_01", "Photos_02"=RiS."Photos_02", "Photos_03"=RiS."Photos_03"
	FROM "demand_WGR"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
    WHERE RiS."GeometryID" = r."GeometryID"
    AND r."SurveyArea" = a.name
    AND r."SurveyArea" IN ('7S-7', '7S-6')
    AND RiS."Done" IS true
    AND (RiS1."Done" IS false OR RiS1."Done" IS NULL);



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

        RAISE NOTICE '*****--- Changing survey ID for % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = relevant_restriction_in_survey."SurveyID" + 1000
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = relevant_restriction_in_survey."SurveyID" + 1000
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

    END LOOP;

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."SurveyID" = 1107
    LOOP

        RAISE NOTICE '*****--- Changing survey ID for % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = 108
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = 108
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

    END LOOP;

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."SurveyID" = 1108
    LOOP

        RAISE NOTICE '*****--- Changing survey ID for % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = 107
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = 107
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

    END LOOP;

END;
$do$;

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
        WHERE RiS."SurveyID" = 1101
    LOOP

        RAISE NOTICE '*****--- Changing survey ID for % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = 102
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = 102
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

    END LOOP;

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."SurveyID" = 1102
    LOOP

        RAISE NOTICE '*****--- Changing survey ID for % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = 101
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = 101
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

    END LOOP;

END;
$do$;

-- for VRMs
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
BEGIN

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand_WGR"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
        WHERE RiS."GeometryID" = r."GeometryID"
        AND r."SurveyArea" = a.name
        AND r."SurveyArea" IN ('7S-7', '7S-6')
        AND RiS."Done" IS true
        AND RiS."SurveyID" = 101
    LOOP

        RAISE NOTICE '*****--- Processing % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";

        -- check to see if the restriction already has a value
        SELECT "Done"
        INTO current_done
        FROM "demand"."RestrictionsInSurveys"
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        IF current_done IS false or current_done IS NULL THEN

            UPDATE "demand"."RestrictionsInSurveys"
                SET "DemandSurveyDateTime"=relevant_restriction_in_survey."DemandSurveyDateTime", "Enumerator"=relevant_restriction_in_survey."Enumerator", "Done"=relevant_restriction_in_survey."Done", "SuspensionReference"=relevant_restriction_in_survey."SuspensionReference",
                "SuspensionReason"=relevant_restriction_in_survey."SuspensionReason", "SuspensionLength"=relevant_restriction_in_survey."SuspensionLength", "NrBaysSuspended"=relevant_restriction_in_survey."NrBaysSuspended", "SuspensionNotes"=relevant_restriction_in_survey."SuspensionNotes",
                "Photos_01"=relevant_restriction_in_survey."Photos_01", "Photos_02"=relevant_restriction_in_survey."Photos_02", "Photos_03"=relevant_restriction_in_survey."Photos_03"
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

            -- Now add VRMs

            INSERT INTO "demand"."VRMs"(
            "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes")
            SELECT "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes"
                FROM "demand_WGR"."VRMs"
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        END IF;

        UPDATE "demand_WGR"."RestrictionsInSurveys"
        SET "Done" = false
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        DELETE FROM "demand_WGR"."VRMs"
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";


    END LOOP;

END;
$do$;