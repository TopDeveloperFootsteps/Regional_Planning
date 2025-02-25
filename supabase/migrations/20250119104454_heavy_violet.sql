-- Drop dependent constraints first
ALTER TABLE IF EXISTS sub_regions
    DROP CONSTRAINT IF EXISTS sub_regions_region_id_fkey;

-- Drop dependent triggers
DROP TRIGGER IF EXISTS region_inactivation_trigger ON regions;

-- Now we can safely modify the regions table
ALTER TABLE regions 
    DROP CONSTRAINT IF EXISTS regions_pkey,
    ALTER COLUMN id SET DATA TYPE uuid USING gen_random_uuid(),
    ADD PRIMARY KEY (id);

-- Update sub_regions table to match
ALTER TABLE sub_regions
    ALTER COLUMN region_id SET DATA TYPE uuid USING gen_random_uuid();

-- Recreate the foreign key constraint
ALTER TABLE sub_regions
    ADD CONSTRAINT sub_regions_region_id_fkey 
    FOREIGN KEY (region_id) 
    REFERENCES regions(id) 
    ON DELETE CASCADE;

-- Drop the ID generation functions as they're no longer needed
DROP FUNCTION IF EXISTS generate_region_id;
DROP FUNCTION IF EXISTS generate_sub_region_id;

-- Recreate the region inactivation trigger function
CREATE OR REPLACE FUNCTION inactivate_region_cascade()
RETURNS trigger AS $func$
BEGIN
    IF NEW.status = 'inactive' THEN
        UPDATE sub_regions
        SET status = 'inactive'
        WHERE region_id = NEW.id;
    END IF;
    RETURN NEW;
END;
$func$ LANGUAGE plpgsql;

-- Recreate the trigger
CREATE TRIGGER region_inactivation_trigger
    AFTER UPDATE OF status ON regions
    FOR EACH ROW
    WHEN (OLD.status = 'active' AND NEW.status = 'inactive')
    EXECUTE FUNCTION inactivate_region_cascade();