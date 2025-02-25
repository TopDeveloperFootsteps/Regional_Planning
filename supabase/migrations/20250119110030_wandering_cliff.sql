-- First drop dependent objects
ALTER TABLE IF EXISTS sub_regions
    DROP CONSTRAINT IF EXISTS sub_regions_region_id_fkey;

-- Modify regions table to use text IDs
ALTER TABLE regions
    DROP CONSTRAINT IF EXISTS regions_pkey,
    ALTER COLUMN id TYPE text,  -- Change back to text
    ALTER COLUMN id SET DEFAULT NULL,  -- Remove uuid default
    ADD PRIMARY KEY (id);

-- Update sub_regions table to match
ALTER TABLE sub_regions
    ALTER COLUMN region_id TYPE text;  -- Change to match regions.id

-- Recreate foreign key constraint
ALTER TABLE sub_regions
    ADD CONSTRAINT sub_regions_region_id_fkey 
    FOREIGN KEY (region_id) 
    REFERENCES regions(id) 
    ON DELETE CASCADE;

-- Create or replace function to generate region ID
CREATE OR REPLACE FUNCTION generate_region_id(region_name text)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    prefix text;
    next_num integer;
    new_id text;
BEGIN
    -- Get first 3 letters of region name (uppercase)
    prefix := UPPER(LEFT(region_name, 3));
    
    -- Find the highest number used for this prefix
    SELECT COALESCE(MAX(NULLIF(REGEXP_REPLACE(id, '^' || prefix, ''), '')::integer), 0)
    INTO next_num
    FROM regions
    WHERE id LIKE prefix || '%';
    
    -- Generate new ID
    new_id := prefix || (next_num + 1);
    
    RETURN new_id;
END;
$$;

-- Create trigger function to set region ID before insert
CREATE OR REPLACE FUNCTION set_region_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id IS NULL THEN
        NEW.id := generate_region_id(NEW.name);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set region ID
CREATE TRIGGER set_region_id_trigger
    BEFORE INSERT ON regions
    FOR EACH ROW
    EXECUTE FUNCTION set_region_id();