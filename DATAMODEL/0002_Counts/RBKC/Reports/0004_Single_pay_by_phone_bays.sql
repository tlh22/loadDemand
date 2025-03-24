/***
 * Single bays
 ***/
 
 -- Pay by Phone bays
 
SELECT "GeometryID", item_refs, "RoadName"
FROM mhtc_operations."Supply" s1 LEFT JOIN (SELECT "GeometryID" AS "GeometryID_Links", ARRAY_AGG ("item_ref") AS item_refs
											 FROM mhtc_operations."RBKC_item_ref_links_2024"
											 GROUP BY "GeometryID" ) AS l ON s1."GeometryID" = l."GeometryID_Links"
WHERE s1."Capacity" = 1
AND s1."RestrictionTypeID" = 103
AND NOT EXISTS (SELECT 1
				FROM mhtc_operations."Supply" s2 
				WHERE s2."RestrictionTypeID" = 103
				AND s1."GeometryID" != s2."GeometryID"
				AND ST_DWithin (s1.geom, s2.geom, 25)
				);

-- Single Residents' Bays adjoining Pay by Phone bay(s) + others

SELECT "GeometryID", item_refs, "RoadName"
FROM mhtc_operations."Supply" s1 LEFT JOIN (SELECT "GeometryID" AS "GeometryID_Links", ARRAY_AGG ("item_ref") AS item_refs
											 FROM mhtc_operations."RBKC_item_ref_links_2024"
											 GROUP BY "GeometryID" ) AS l ON s1."GeometryID" = l."GeometryID_Links"
WHERE s1."Capacity" = 1
AND s1."RestrictionTypeID" = 101
AND NOT EXISTS (SELECT 1
				FROM mhtc_operations."Supply" s2 
				WHERE s2."RestrictionTypeID" = 101
				AND s1."GeometryID" != s2."GeometryID"
				AND ST_DWithin (s1.geom, s2.geom, 25)
				)
AND EXISTS (SELECT 1
				FROM mhtc_operations."Supply" s3 
				WHERE s3."RestrictionTypeID" IN (103, 108, 110, 111, 112, 113, 124)
				AND s1."GeometryID" != s3."GeometryID"
				AND ST_DWithin (s1.geom, s3.geom, 2)
				)