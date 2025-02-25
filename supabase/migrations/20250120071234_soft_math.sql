-- First disable RLS temporarily to ensure clean state
ALTER TABLE map_icons DISABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Public access to map_icons" ON map_icons;
DROP POLICY IF EXISTS "Public access to upload bucket" ON storage.objects;

-- Create bucket if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('upload', 'upload', true)
ON CONFLICT (id) DO UPDATE 
SET public = true;

-- Re-enable RLS
ALTER TABLE map_icons ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create new storage policy with explicit INSERT permission
CREATE POLICY "Allow public upload access"
    ON storage.objects
    FOR INSERT 
    TO public
    WITH CHECK (bucket_id = 'upload');

CREATE POLICY "Allow public select access"
    ON storage.objects
    FOR SELECT
    TO public
    USING (bucket_id = 'upload');

-- Create new map_icons policy with explicit permissions
CREATE POLICY "Allow public map_icons access"
    ON map_icons
    FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Grant necessary permissions
GRANT ALL ON map_icons TO public;
GRANT ALL ON storage.objects TO public;
GRANT ALL ON storage.buckets TO public;
GRANT USAGE ON SCHEMA storage TO public;

-- Ensure buckets are accessible
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public buckets access"
    ON storage.buckets
    FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);