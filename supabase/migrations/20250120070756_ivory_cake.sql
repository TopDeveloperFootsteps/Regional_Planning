-- Drop all existing policies
DROP POLICY IF EXISTS "Allow all operations on map_icons" ON map_icons;
DROP POLICY IF EXISTS "Allow all operations on upload bucket" ON storage.objects;

-- Create a single unrestricted policy for map_icons
CREATE POLICY "Unrestricted access to map_icons"
    ON map_icons
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create a single unrestricted policy for storage.objects
CREATE POLICY "Unrestricted access to upload bucket"
    ON storage.objects
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Ensure RLS is enabled but with unrestricted access
ALTER TABLE map_icons ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Grant full permissions
GRANT ALL ON map_icons TO PUBLIC;
GRANT ALL ON storage.objects TO PUBLIC;
GRANT ALL ON storage.buckets TO PUBLIC;

-- Ensure storage schema access
GRANT USAGE ON SCHEMA storage TO PUBLIC;

-- Ensure the upload bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('upload', 'upload', true)
ON CONFLICT (id) DO UPDATE 
SET public = true;