-- deal with 0 and O

UPDATE demand."VRMs"
SET "VRM" =
--SELECT "VRM",  --"VRM" SIMILAR TO '[A-Z]{2}[O][0-9]-[A-Z]{3}',
CASE
    -- Current UK VRM  (AA99-AAA)
    WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z]{3}' THEN "VRM" -- Normal
	WHEN "VRM" SIMILAR TO '[0][A-Z][0-9]{2}-[A-Z]{3}' THEN regexp_replace("VRM", '[0]([A-Z][0-9]{2}-[A-Z]{3})', 'O\1')  -- First character is 0
	WHEN "VRM" SIMILAR TO '[A-Z][0][0-9]{2}-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z])[0]([0-9]{2}-[A-Z]{3})', '\1O\2')  -- Second character is 0
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[O][0-9]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2})[O]([0-9]-[A-Z]{3})', '\10\2') -- Third character is O
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9][O]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2}[0-9])[O](-[A-Z]{3})', '\10\2') -- Fourth character is O
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[0][A-Z]{2}' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-)[0]([A-Z]{2})', '\1O\2')  -- Fifth character is 0
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z][0][A-Z]' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-[A-Z])[0]([A-Z])', '\1O\2')  -- Sixth character is 0
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z]{2}[0]' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-[A-Z]{2})[0]', '\1O')  -- Seventh character is 0

	-- Also need to check for 1/I
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[I][0-9]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2})[I]([0-9]-[A-Z]{3})', '\11\2') -- Third character is I
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9][I]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2}[0-9])[I](-[A-Z]{3})', '\11\2') -- Fourth character is I

	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[1][A-Z]{2}' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-)[1]([A-Z]{2})', '\1I\2')  -- Fifth character is 1
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z][1][A-Z]' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-[A-Z])[1]([A-Z])', '\1I\2')  -- Sixth character is 1
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z]{2}[1]' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-[A-Z]{2})[1]', '\1I')  -- Seventh character is 1

    -- Previous UK (A999-AAA)
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{3}-[A-Z]{3}' THEN "VRM"
	WHEN "VRM" SIMILAR TO '[A-Z][O][0-9]{2}-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z])[O]([0-9]{2}-[A-Z]{3})', '\10\2')  -- First number is O
	WHEN "VRM" SIMILAR TO '[A-Z][0-9][O][0-9]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z][0-9])[O]([0-9]-[A-Z]{3})', '\10\2')  -- Second number is O
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{2}[O]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z][0-9]{2})[O](-[A-Z]{3})', '\10\2')  -- Second number is O

    -- Tidy Previous UK (A99-AAA)
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{2}-[A-Z]{3}' THEN "VRM"
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{2}[A-Z]-[A-Z]{2}' THEN regexp_replace("VRM", '([A-Z][0-9]{2})([A-Z])-([A-Z]{2})', '\1-\2\3')

    -- Tidy Previous UK (A9-AAA)
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]-[A-Z]{3}' THEN "VRM"
	WHEN "VRM" SIMILAR TO '[A-Z][0-9][A-Z]{2}-[A-Z]' THEN regexp_replace("VRM", '([A-Z][0-9])([A-Z]{2})-([A-Z])', '\1-\2\3')

    -- Early UK (AAA-999A)
	WHEN "VRM" SIMILAR TO '[A-Z]{3}-[0-9]{3}[A-Z]' THEN "VRM"
	WHEN "VRM" SIMILAR TO '[A-Z]{3}[0-9]-[0-9]{2}[A-Z]' THEN regexp_replace("VRM", '([A-Z]{3})([0-9])-([0-9]{2}[A-Z])', '\1-\2\3')

	ELSE "VRM"
END
--FROM demand."VRMs"
--WHERE "VRM" SIMILAR TO '[A-Z]{2}[O][0-9]-[A-Z]{3}'