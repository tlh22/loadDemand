/***

If there are commas in the Notes field, change them to full stops.

NB: there may be other characters that need changing

SELECT "Notes", REGEXP_REPLACE("Notes",',','.', 'g') 
FROM demand."Counts"
WHERE "Notes" LIKE '%,%'

**/

UPDATE demand."Counts"
SET "Notes" = REGEXP_REPLACE("Notes",',','.', 'g') 
WHERE "Notes" LIKE '%,%';