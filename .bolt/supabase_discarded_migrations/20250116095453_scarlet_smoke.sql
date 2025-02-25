-- First drop any views that might have been created by previous migrations
DROP VIEW IF EXISTS home_mapping_diagnostics CASCADE;
DROP VIEW IF EXISTS home_codes_mapping_status CASCADE;
DROP VIEW IF EXISTS home_mapping_data_check CASCADE;
DROP VIEW IF EXISTS home_mapping_summary CASCADE;
DROP VIEW IF EXISTS unmapped_home_codes_detail CASCADE;
DROP VIEW IF EXISTS unmapped_home_codes_summary CASCADE;
DROP VIEW IF EXISTS home_mapping_statistics CASCADE;
DROP VIEW IF EXISTS home_mapping_categories CASCADE;

-- Drop any potential remaining views from the database
DO $$ 
DECLARE 
    view_name text;
BEGIN 
    FOR view_name IN (
        SELECT table_name 
        FROM information_schema.views 
        WHERE table_schema = 'public'
    )
    LOOP
        EXECUTE 'DROP VIEW IF EXISTS ' || view_name || ' CASCADE';
    END LOOP;
END $$;