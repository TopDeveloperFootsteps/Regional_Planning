-- Drop existing policies
DROP POLICY IF EXISTS "Allow public read access on regions" ON regions;
DROP POLICY IF EXISTS "Allow public read access on sub_regions" ON sub_regions;
DROP POLICY IF EXISTS "Allow public read access on map_icons" ON map_icons;
DROP POLICY IF EXISTS "Allow public read access on map_settings" ON map_settings;

-- Create comprehensive policies for regions
CREATE POLICY "Enable read access for all users on regions"
    ON regions FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable insert for all users on regions"
    ON regions FOR INSERT
    TO public
    WITH CHECK (true);

CREATE POLICY "Enable update for all users on regions"
    ON regions FOR UPDATE
    TO public
    USING (true)
    WITH CHECK (true);

-- Create comprehensive policies for sub_regions
CREATE POLICY "Enable read access for all users on sub_regions"
    ON sub_regions FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable insert for all users on sub_regions"
    ON sub_regions FOR INSERT
    TO public
    WITH CHECK (true);

CREATE POLICY "Enable update for all users on sub_regions"
    ON sub_regions FOR UPDATE
    TO public
    USING (true)
    WITH CHECK (true);

-- Create comprehensive policies for map_icons
CREATE POLICY "Enable read access for all users on map_icons"
    ON map_icons FOR SELECT
    TO public
    USING (true);

-- Create comprehensive policies for map_settings
CREATE POLICY "Enable read access for all users on map_settings"
    ON map_settings FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable update for all users on map_settings"
    ON map_settings FOR UPDATE
    TO public
    USING (true)
    WITH CHECK (true);

-- Add some sample data for testing
INSERT INTO map_icons (name, url, icon_type, is_active)
VALUES 
    ('City', 'https://example.com/city.png', 'region', true),
    ('Town', 'https://example.com/town.png', 'region', true),
    ('Village', 'https://example.com/village.png', 'region', true),
    ('District', 'https://example.com/district.png', 'sub_region', true),
    ('Area', 'https://example.com/area.png', 'sub_region', true)
ON CONFLICT DO NOTHING;

-- Insert initial map settings if not exists
INSERT INTO map_settings (
    show_icons,
    show_circles,
    circle_transparency,
    circle_border,
    circle_radius_km
)
SELECT 
    true,
    false,
    50,
    true,
    10
WHERE NOT EXISTS (
    SELECT 1 FROM map_settings
);