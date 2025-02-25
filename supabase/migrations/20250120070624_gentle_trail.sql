-- Drop existing policies
DROP POLICY IF EXISTS "Public access to map_icons" ON map_icons;

-- Create comprehensive policies for map_icons table
CREATE POLICY "Enable read access for all users on map_icons"
    ON map_icons FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable insert for all users on map_icons"
    ON map_icons FOR INSERT
    TO public
    WITH CHECK (true);

CREATE POLICY "Enable update for all users on map_icons"
    ON map_icons FOR UPDATE
    TO public
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable delete for all users on map_icons"
    ON map_icons FOR DELETE
    TO public
    USING (true);

-- Ensure RLS is enabled
ALTER TABLE map_icons ENABLE ROW LEVEL SECURITY;