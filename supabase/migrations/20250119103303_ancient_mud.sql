-- Create enum for region status
CREATE TYPE region_status AS ENUM ('active', 'inactive');

-- Create table for map settings
CREATE TABLE map_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    show_icons boolean DEFAULT true,
    show_circles boolean DEFAULT false,
    circle_transparency integer DEFAULT 50 CHECK (circle_transparency BETWEEN 0 AND 100),
    circle_border boolean DEFAULT true,
    circle_radius_km integer DEFAULT 10,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create table for map icons
CREATE TABLE map_icons (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    url text NOT NULL,
    icon_type text NOT NULL CHECK (icon_type IN ('region', 'sub_region')),
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create table for regions
CREATE TABLE regions (
    id text PRIMARY KEY,  -- Will store format like 'NEW1'
    name text NOT NULL,
    latitude decimal(10,6) NOT NULL,
    longitude decimal(10,6) NOT NULL,
    status region_status DEFAULT 'active',
    icon_id uuid REFERENCES map_icons(id),
    circle_radius_km integer,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create table for sub-regions
CREATE TABLE sub_regions (
    id text PRIMARY KEY,  -- Will store format like 'SUB1NEW1'
    region_id text REFERENCES regions(id) ON DELETE CASCADE,
    name text NOT NULL,
    latitude decimal(10,6) NOT NULL,
    longitude decimal(10,6) NOT NULL,
    status region_status DEFAULT 'active',
    icon_id uuid REFERENCES map_icons(id),
    circle_radius_km integer,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE map_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE map_icons ENABLE ROW LEVEL SECURITY;
ALTER TABLE regions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sub_regions ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow public read access on map_settings"
    ON map_settings FOR SELECT TO public USING (true);

CREATE POLICY "Allow public read access on map_icons"
    ON map_icons FOR SELECT TO public USING (true);

CREATE POLICY "Allow public read access on regions"
    ON regions FOR SELECT TO public USING (true);

CREATE POLICY "Allow public read access on sub_regions"
    ON sub_regions FOR SELECT TO public USING (true);

-- Create function to generate region ID
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

-- Create function to generate sub-region ID
CREATE OR REPLACE FUNCTION generate_sub_region_id(region_id text)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    next_num integer;
    new_id text;
BEGIN
    -- Find the highest number used for this region
    SELECT COALESCE(MAX(NULLIF(REGEXP_REPLACE(id, '^SUB', ''), '')::integer), 0)
    INTO next_num
    FROM sub_regions
    WHERE region_id = $1;
    
    -- Generate new ID
    new_id := 'SUB' || (next_num + 1) || region_id;
    
    RETURN new_id;
END;
$$;

-- Create function to handle region inactivation
CREATE OR REPLACE FUNCTION inactivate_region_cascade()
RETURNS trigger AS $$
BEGIN
    IF NEW.status = 'inactive' THEN
        UPDATE sub_regions
        SET status = 'inactive'
        WHERE region_id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for region inactivation
CREATE TRIGGER region_inactivation_trigger
    AFTER UPDATE OF status ON regions
    FOR EACH ROW
    WHEN (OLD.status = 'active' AND NEW.status = 'inactive')
    EXECUTE FUNCTION inactivate_region_cascade();