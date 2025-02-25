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

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_regions_status ON regions(status);
CREATE INDEX IF NOT EXISTS idx_sub_regions_status ON sub_regions(status);
CREATE INDEX IF NOT EXISTS idx_map_icons_is_active ON map_icons(is_active);

-- Update RLS policies to ensure they work correctly
DROP POLICY IF EXISTS "Allow public read access on map_settings" ON map_settings;
CREATE POLICY "Allow public read access on map_settings"
    ON map_settings
    FOR SELECT
    USING (true);

-- Add helpful functions for map settings
CREATE OR REPLACE FUNCTION get_map_settings()
RETURNS map_settings
LANGUAGE sql
STABLE
AS $$
    SELECT *
    FROM map_settings
    LIMIT 1;
$$;