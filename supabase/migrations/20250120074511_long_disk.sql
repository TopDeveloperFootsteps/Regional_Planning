-- First disable RLS temporarily
ALTER TABLE map_icons DISABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
ALTER TABLE storage.buckets DISABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Public access to map_icons" ON map_icons;
DROP POLICY IF EXISTS "Public access to upload bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow public upload access" ON storage.objects;
DROP POLICY IF EXISTS "Allow public select access" ON storage.objects;
DROP POLICY IF EXISTS "Allow public buckets access" ON storage.buckets;

-- Ensure upload bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('upload', 'upload', true)
ON CONFLICT (id) DO UPDATE 
SET public = true;

-- Grant fresh permissions
GRANT ALL ON map_icons TO public;
GRANT ALL ON storage.objects TO public;
GRANT ALL ON storage.buckets TO public;
GRANT USAGE ON SCHEMA storage TO public;

-- Re-enable RLS with new policies
ALTER TABLE map_icons ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

-- Create simplified policies
CREATE POLICY "unrestricted_map_icons_policy"
ON map_icons
FOR ALL
TO public
USING (true)
WITH CHECK (true);

CREATE POLICY "unrestricted_storage_policy"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'upload')
WITH CHECK (bucket_id = 'upload');

CREATE POLICY "unrestricted_buckets_policy"
ON storage.buckets
FOR ALL
TO public
USING (true)
WITH CHECK (true);