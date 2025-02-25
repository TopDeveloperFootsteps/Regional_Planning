-- First drop dependent objects and existing triggers
DROP TRIGGER IF EXISTS region_inactivation_trigger ON regions;
DROP TRIGGER IF EXISTS update_regions_updated_at ON regions;
DROP TRIGGER IF EXISTS update_sub_regions_updated_at ON sub_regions;
DROP FUNCTION IF EXISTS inactivate_region_cascade();
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop dependent objects
ALTER TABLE IF EXISTS sub_regions
    DROP CONSTRAINT IF EXISTS sub_regions_region_id_fkey;

-- Modify regions table
ALTER TABLE regions
    DROP CONSTRAINT IF EXISTS regions_pkey,
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
    ADD PRIMARY KEY (id);

-- Update sub_regions table to match
ALTER TABLE sub_regions
    ALTER COLUMN region_id TYPE uuid USING (gen_random_uuid());

-- Recreate foreign key constraint
ALTER TABLE sub_regions
    ADD CONSTRAINT sub_regions_region_id_fkey 
    FOREIGN KEY (region_id) 
    REFERENCES regions(id) 
    ON DELETE CASCADE;

-- Create trigger function for updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_regions_updated_at
    BEFORE UPDATE ON regions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sub_regions_updated_at
    BEFORE UPDATE ON sub_regions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Recreate the region inactivation trigger
CREATE OR REPLACE FUNCTION inactivate_region_cascade()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'inactive' THEN
        UPDATE sub_regions
        SET status = 'inactive'
        WHERE region_id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER region_inactivation_trigger
    AFTER UPDATE OF status ON regions
    FOR EACH ROW
    WHEN (OLD.status = 'active' AND NEW.status = 'inactive')
    EXECUTE FUNCTION inactivate_region_cascade();