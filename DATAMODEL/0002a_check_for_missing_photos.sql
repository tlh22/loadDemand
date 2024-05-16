/***
To work out files missing (or that can be deleted), the steps are:
1. generate a list of the photos within the tables. See script below
2. generate list of files within the photos directory use $ ls /home/QGIS/projects/Islington/Mapping/photos -X > /home/tim/Documents/photo_check/photos_in_directory_201127.txt
3a. grep -v -f  photos_in_database.csv photos_in_directory.txt (this will show the photos that are not required)
    3b. grep -v -f  photos_in_directory_201127.txt photos_in_database.csv (this will show the photos not yet uploaded)

grep -v -f fileA fileB (finds lines in fileB that are not present in fileA)

***/--
--DROP FUNCTION mhtc_operations.getPhotosFromTable(schemaname text, tablename text);
CREATE OR REPLACE FUNCTION mhtc_operations.getPhotosFromTable(tablename regclass)
  RETURNS TABLE (photo_name character varying(255)) AS
$func$
DECLARE
	 squery text;
BEGIN
   RAISE NOTICE 'checking: %', tablename;
   squery = format('SELECT "Photos_01"
                    FROM   %s
                    WHERE "Photos_01" IS NOT NULL
                    UNION
                    SELECT "Photos_02"
                    FROM   %s
                    WHERE "Photos_02" IS NOT NULL
                    UNION
                    SELECT "Photos_03"
                    FROM   %s
                    WHERE "Photos_03" IS NOT NULL
                    ', tablename, tablename, tablename);
   --RAISE NOTICE '2: %', squery;
   RETURN QUERY EXECUTE squery;
END;
$func$ LANGUAGE plpgsql;

-- query

WITH relevant_tables AS (
      select concat(table_schema, '.', quote_ident(table_name)) AS full_table_name
      from information_schema.columns
      where column_name = 'Photos_01'
      AND table_schema IN ('demand')
    )

    SELECT mhtc_operations.getPhotosFromTable(full_table_name)
    FROM relevant_tables;



CREATE OR REPLACE FUNCTION mhtc_operations.checkPhotosExist(photo_path character varying(255))
  RETURNS TABLE (photo_name text, capture_source character varying(255)) AS
$func$
DECLARE
    relevant_restriction RECORD;
    relevant_count RECORD;
    squery text;
BEGIN

    squery = format(

    'SELECT v.photo_name, v."CaptureSource"
    FROM (
        SELECT CONCAT(''%s'', ''\'', p."Photo") AS photo_name, p."CaptureSource"
        FROM
        (
        SELECT RiS."Photos_01" AS "Photo", RiS."CaptureSource"
        FROM demand."RestrictionsInSurveys" RiS
        WHERE "Photos_01" IS NOT NULL

        UNION

        SELECT RiS."Photos_02" AS "Photo", RiS."CaptureSource"
        FROM demand."RestrictionsInSurveys" RiS
        WHERE "Photos_02" IS NOT NULL

        UNION

        SELECT RiS."Photos_03" AS "Photo", RiS."CaptureSource"
        FROM demand."RestrictionsInSurveys" RiS
        WHERE "Photos_03" IS NOT NULL
        ) as p ) as v
        WHERE pg_stat_file(v.photo_name, true) IS NULL
        ', photo_path);

   RETURN QUERY EXECUTE squery;

END;
$func$ LANGUAGE plpgsql;

SELECT mhtc_operations.checkPhotosExist('Z:\Tim\STH22-11 Cambridge Parking Surveys\Demand\Mapping\Photos')

