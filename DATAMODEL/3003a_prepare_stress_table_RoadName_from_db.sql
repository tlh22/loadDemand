-- ** Remove "dots", i.e., zero length leaders
ALTER TABLE mhtc_operations."Supply" DISABLE TRIGGER insert_mngmt;

UPDATE mhtc_operations."Supply"
SET label_ldr = NULL
WHERE ST_Length(label_ldr) < 0.001;

UPDATE mhtc_operations."Supply"
SET label_loading_ldr = NULL
WHERE ST_Length(label_ldr) < 0.001;

-- Enable trigger
ALTER TABLE mhtc_operations."Supply" ENABLE TRIGGER insert_mngmt;
