-- Add region_settings table
CREATE TABLE IF NOT EXISTS region_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icon_id uuid REFERENCES map_icons(id),
    circle_radius_km integer DEFAULT 10,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Add sub_region_settings table
CREATE TABLE IF NOT EXISTS sub_region_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icon_id uuid REFERENCES map_icons(id),
    circle_radius_km integer DEFAULT 5,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE region_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE sub_region_settings ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on region_settings"
    ON region_settings FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable update for all users on region_settings"
    ON region_settings FOR UPDATE
    TO public
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable read access for all users on sub_region_settings"
    ON sub_region_settings FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable update for all users on sub_region_settings"
    ON sub_region_settings FOR UPDATE
    TO public
    USING (true)
    WITH CHECK (true);

-- Remove icon_id and circle_radius_km from regions table
ALTER TABLE regions 
    DROP COLUMN IF EXISTS icon_id,
    DROP COLUMN IF EXISTS circle_radius_km;

-- Remove icon_id and circle_radius_km from sub_regions table
ALTER TABLE sub_regions
    DROP COLUMN IF EXISTS icon_id,
    DROP COLUMN IF EXISTS circle_radius_km;

-- Insert initial settings
INSERT INTO region_settings (icon_id, circle_radius_km)
SELECT 
    (SELECT id FROM map_icons WHERE name = 'City' AND icon_type = 'region' LIMIT 1),
    10
WHERE NOT EXISTS (SELECT 1 FROM region_settings);

INSERT INTO sub_region_settings (icon_id, circle_radius_km)
SELECT 
    (SELECT id FROM map_icons WHERE name = 'District' AND icon_type = 'sub_region' LIMIT 1),
    5
WHERE NOT EXISTS (SELECT 1 FROM sub_region_settings);