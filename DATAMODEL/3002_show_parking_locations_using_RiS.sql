-- create view with to show stress

drop materialized view IF EXISTS demand."Demand_view_to_show_parking_locations" CASCADE;

create MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations"
TABLESPACE pg_default
AS

    select row_number() over (partition by true::boolean) as id,
    s."GeometryID", s.geom, s."RestrictionTypeID", s."GeomShapeID", s."AzimuthToRoadCentreLine", s."BayOrientation",
    case when f."Demand" > s."NrBays" then f."Demand"
         else s."NrBays"
    end as "NrBays",
    f."Capacity",
    f."SurveyID", f."Demand" as "Demand"

    from demand."Supply_for_viewing_parking_locations" s,

        (select d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description",
        d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
        d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", d."Demand"
        from
        (select ris."SurveyID", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" as "RestrictionType Description",
        "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", ris."SupplyCapacity" AS "Capacity", "Demand", "Stress",
        ris."Photos_01", ris."Photos_02", ris."Photos_03"
        from demand."RestrictionsInSurveys" ris, demand."Surveys" su,
        (mhtc_operations."Supply" as a
         left join "toms_lookups"."BayLineTypes" as "BayLineTypes" on a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") as s
         where ris."SurveyID" = su."SurveyID"
         and ris."GeometryID" = s."GeometryID"
         AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
         ) as d

        order by d."RestrictionTypeID", d."GeometryID", d."SurveyID") as f

	WHERE f."GeometryID" = s."GeometryID"

with DATA;

alter table demand."Demand_view_to_show_parking_locations"
    OWNER TO postgres;

create UNIQUE INDEX "idx_Demand_view_to_show_parking_locations_id"
    ON demand."Demand_view_to_show_parking_locations" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations";

