-- First ensure the upload bucket exists and is properly configured
INSERT INTO storage.buckets (id, name, public)
VALUES ('upload', 'upload', true)
ON CONFLICT (id) DO UPDATE 
SET public = true;

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Unrestricted access to map_icons" ON map_icons;
DROP POLICY IF EXISTS "Unrestricted access to upload bucket" ON storage.objects;

-- Create simplified and permissive policies
CREATE POLICY "Public access to map_icons"
    ON map_icons
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Public access to upload bucket"
    ON storage.objects
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (bucket_id = 'upload')
    WITH CHECK (bucket_id = 'upload');

-- Grant explicit permissions
GRANT ALL ON map_icons TO public;
GRANT ALL ON storage.objects TO public;
GRANT ALL ON storage.buckets TO public;
GRANT USAGE ON SCHEMA storage TO public;

-- Ensure RLS is enabled but with permissive policies
ALTER TABLE map_icons ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;