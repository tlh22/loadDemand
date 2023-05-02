-- Active suspensions ...

DROP TABLE IF EXISTS demand."Supply_for_viewing_parking_locations" CASCADE;

CREATE TABLE demand."Supply_for_viewing_parking_locations"
(
    gid INT GENERATED ALWAYS AS IDENTITY,
	"SurveyID" integer NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom geometry(LineString,27700) NOT NULL,
    "RestrictionLength" double precision NOT NULL,
    "RestrictionTypeID" integer NOT NULL,
    "GeomShapeID" integer NOT NULL,
    "AzimuthToRoadCentreLine" double precision,
    "BayOrientation" double precision,
    "NrBays" integer NOT NULL DEFAULT '-1'::integer,
    "Capacity" integer,
    "Demand" double precision
)

TABLESPACE pg_default;

ALTER TABLE demand."Supply_for_viewing_parking_locations"
    OWNER to postgres;
-- Index: sidx_Supply_geom

-- DROP INDEX mhtc_operations."sidx_Supply_geom";

CREATE INDEX "sidx_Supply_for_viewing_parking_locations_geom"
    ON demand."Supply_for_viewing_parking_locations" USING gist
    (geom)
    TABLESPACE pg_default;




DO
$do$
DECLARE

     row1 RECORD;
     row2 RECORD;
          
	 vehicleLength real := 0.0;
	 vehicleWidth real := 0.0;
	 
	 survey_id integer;
	 geometry_id text;
	 capacity integer;
	 restriction_capacity integer;
	 new_capacity integer;
	 demand real;
	 new_demand real;
	 
BEGIN

	-- Get vehicle length
	
    select "Value" into vehicleLength
    from "mhtc_operations"."project_parameters"
    where "Field" = 'VehicleLength';
    
    select "Value" into vehicleWidth
    from "mhtc_operations"."project_parameters"
    where "Field" = 'VehicleWidth';
            
    -- Add all records
	INSERT INTO demand."Supply_for_viewing_parking_locations"(
		"SurveyID", "GeometryID", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", 
		"AzimuthToRoadCentreLine", "BayOrientation", "NrBays", "Capacity", "Demand", geom)
	
	SELECT y."SurveyID", y."GeometryID", "RestrictionLength", y."RestrictionTypeID", y."GeomShapeID", 
		y."AzimuthToRoadCentreLine", "BayOrientation",  
		     CASE WHEN "NrBays" = -1 THEN 
				CASE WHEN "Capacity" = 0 THEN ROUND(ST_LENGTH(y.geom)/vehicleLength)
					ELSE "Capacity"
					END
	              ELSE "NrBays"
	         END AS "NrBays", "Capacity", "Demand", -- increase the NrBays value to deal with over parked areas
	         (ST_Dump(CASE WHEN a.geom IS NOT NULL THEN ST_Difference(y.geom, ST_Buffer(a.geom, 0.1, 'endcap=flat'))
	              ELSE y.geom
	              END)).geom AS geom
	FROM	
	(SELECT ris."SurveyID", ris."GeometryID", s.geom, "RestrictionLength", "RestrictionTypeID",
	        CASE WHEN "GeomShapeID" < 10 THEN "GeomShapeID" + 20
	             WHEN "GeomShapeID" >= 10 AND "GeomShapeID" < 20 THEN 21
	             ELSE "GeomShapeID"
	         END
	         , "AzimuthToRoadCentreLine", "BayOrientation",
			 "NrBays", "CapacityAtTimeOfSurvey" AS "Capacity",  -- increase the NrBays value to deal with over parked areas
			 "Demand"
		FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, mhtc_operations."Supply" s
		WHERE ris."SurveyID" = su."SurveyID"
	    AND ris."GeometryID" = s."GeometryID"
	 	AND su."SurveyID" > 0) y LEFT JOIN "demand"."ActiveSuspensions" AS a ON y."SurveyID" = a."SurveyID" AND y."GeometryID" = a."GeometryID"
		;
		
    -- Now consider the details in ActiveSuspensions
    
    FOR row1 IN 
    	SELECT "SurveyID", "GeometryID"
    	FROM demand."ActiveSuspensions"
		
	LOOP
	
		-- get capacity for restriction
		
		SELECT "CapacityAtTimeOfSurvey", "Demand"
		INTO restriction_capacity, demand
		FROm demand."RestrictionsInSurveys"
		WHERE "SurveyID" = row1."SurveyID"
		AND "GeometryID" = row1."GeometryID";
		
    	-- update capacity for each section
     	
     	FOR row2 IN 
	    	SELECT gid
	    	FROM demand."Supply_for_viewing_parking_locations"
	    	WHERE "SurveyID" = row1."SurveyID"
			AND "GeometryID" = row1."GeometryID"
		LOOP
		
			UPDATE demand."Supply_for_viewing_parking_locations"
			SET "Capacity" = 
	
				CASE WHEN "RestrictionTypeID" < 200 THEN
				     
	                CASE WHEN "GeomShapeID" IN (4, 5, 6, 24, 25, 26) THEN 
		                 	 FLOOR(public.ST_Length ("geom")::numeric/vehicleWidth::numeric)
		                 WHEN "RestrictionLength" >=(vehicleLength*4) THEN
		                     CASE WHEN MOD(public.ST_Length ("geom")::numeric, vehicleLength::numeric) > (vehicleLength-1.0) THEN 
		                         	  CEILING(public.ST_Length ("geom")/vehicleLength)
		                          ELSE 
		                          	 FLOOR(public.ST_Length ("geom")/vehicleLength)
		                          END
		                 WHEN public.ST_Length ("geom") <=(vehicleLength-1.0) THEN 1
		                 ELSE
		                      CASE WHEN MOD(public.ST_Length ("geom")::numeric, vehicleLength::numeric) > (vehicleLength*0.9) THEN 
		                      		   CEILING(public.ST_Length ("geom")/vehicleLength)
		                           ELSE 
		                           	   FLOOR(public.ST_Length ("geom")/vehicleLength)
		                           END
			             END
				ELSE
				      CASE WHEN public.ST_Length ("geom")::numeric < vehicleLength AND public.ST_Length ("geom")::numeric > (vehicleLength*0.9) THEN
	                          1
	                          --  /** this considers "just short" lengths **/ CASE WHEN MOD(public.ST_Length (NEW."geom")::numeric, vehicleLength::numeric) > (vehicleLength*0.9) THEN NEW."Capacity" = CEILING(public.ST_Length (NEW."geom")/vehicleLength);
	                       ELSE 
	                           FLOOR(public.ST_Length ("geom")/vehicleLength)
	                       END
				END
				
			WHERE gid = row2.gid;
	    	
	    	SELECT "Capacity"
			INTO new_capacity
			FROM demand."Supply_for_viewing_parking_locations"
			WHERE gid = row2.gid;

			TODO: Need to check that new_capacity is less than restriction_capacity
			
	    	-- Now deal with demand
	    	
	    	IF restriction_capacity > 0 THEN
	    		new_demand = demand * (new_capacity::real/restriction_capacity::real);
	    	ELSE
	    		new_demand = 0;
	    	END IF;
	    		    		
	    	RAISE NOTICE '***** SurveyID: %, GeometryID: % gid: % - total: % , Capacity: % -- Demand %; new: %', 
	    		row1."SurveyID", row1."GeometryID", row2.gid, new_capacity, restriction_capacity, demand, new_demand;
   	
	    	UPDATE demand."Supply_for_viewing_parking_locations"
			SET "Demand" = new_demand, "NrBays" = new_capacity
			WHERE gid = row2.gid;
			
    	END LOOP;  
    		
    END LOOP;    
	
END
$do$;

