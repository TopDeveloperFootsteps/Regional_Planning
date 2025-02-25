-- Create enum for icon types
CREATE TYPE icon_type AS ENUM ('region', 'sub_region', 'both');

-- Create table for map icons
CREATE TABLE map_icons (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    url text NOT NULL,
    icon_type icon_type NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- Create table for region settings
CREATE TABLE region_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    show_circles boolean DEFAULT true,
    circle_transparency integer DEFAULT 50 CHECK (circle_transparency BETWEEN 0 AND 100),
    circle_border boolean DEFAULT true,
    circle_radius_km integer DEFAULT 10 CHECK (circle_radius_km BETWEEN 5 AND 100),
    icon_id uuid REFERENCES map_icons(id),
    created_at timestamptz DEFAULT now()
);

-- Create table for sub-region settings
CREATE TABLE sub_region_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    show_circles boolean DEFAULT true,
    circle_transparency integer DEFAULT 50 CHECK (circle_transparency BETWEEN 0 AND 100),
    circle_border boolean DEFAULT true,
    circle_radius_km integer DEFAULT 5 CHECK (circle_radius_km BETWEEN 5 AND 100),
    icon_id uuid REFERENCES map_icons(id),
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE map_icons ENABLE ROW LEVEL SECURITY;
ALTER TABLE region_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE sub_region_settings ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on map_icons"
    ON map_icons FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable read access for all users on region_settings"
    ON region_settings FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable update for all users on region_settings"
    ON region_settings FOR UPDATE
    TO public
    USING (true);

CREATE POLICY "Enable read access for all users on sub_region_settings"
    ON sub_region_settings FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable update for all users on sub_region_settings"
    ON sub_region_settings FOR UPDATE
    TO public
    USING (true);

-- Insert initial settings
INSERT INTO region_settings (show_circles, circle_transparency, circle_border, circle_radius_km)
VALUES (true, 50, true, 10);

INSERT INTO sub_region_settings (show_circles, circle_transparency, circle_border, circle_radius_km)
VALUES (true, 50, true, 5);