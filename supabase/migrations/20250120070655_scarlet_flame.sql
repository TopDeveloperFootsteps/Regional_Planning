-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users on map_icons" ON map_icons;
DROP POLICY IF EXISTS "Enable insert for all users on map_icons" ON map_icons;
DROP POLICY IF EXISTS "Enable update for all users on map_icons" ON map_icons;
DROP POLICY IF EXISTS "Enable delete for all users on map_icons" ON map_icons;
DROP POLICY IF EXISTS "Public access to upload bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public insert to upload bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public update to upload bucket" ON storage.objects;

-- Create unrestricted policies for map_icons table
CREATE POLICY "Allow all operations on map_icons"
    ON map_icons FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create unrestricted policies for storage.objects
CREATE POLICY "Allow all operations on upload bucket"
    ON storage.objects FOR ALL
    TO public
    USING (bucket_id = 'upload')
    WITH CHECK (bucket_id = 'upload');

-- Ensure RLS is enabled
ALTER TABLE map_icons ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Grant necessary permissions
GRANT ALL ON map_icons TO public;
GRANT ALL ON storage.objects TO public;