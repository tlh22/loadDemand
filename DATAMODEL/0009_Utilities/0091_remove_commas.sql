/***

Ensure that there are no commas in string

***/

UPDATE demand."VRMs"
SET "Notes" = replace("Notes", ',', '.');


