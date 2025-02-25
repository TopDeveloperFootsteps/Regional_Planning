-- Drop existing policies
DROP POLICY IF EXISTS "Allow public access to icons" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads to icons" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to icons" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes from icons" ON storage.objects;

-- Ensure icons bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('icons', 'icons', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Create a single policy for public access to icons bucket
CREATE POLICY "Public access to icons bucket"
ON storage.objects FOR ALL
USING (bucket_id = 'icons')
WITH CHECK (bucket_id = 'icons');

-- Update map_icons table RLS
ALTER TABLE map_icons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for all users on map_icons" ON map_icons;
DROP POLICY IF EXISTS "Enable insert for all users on map_icons" ON map_icons;
DROP POLICY IF EXISTS "Enable update for all users on map_icons" ON map_icons;

CREATE POLICY "Public access to map_icons"
ON map_icons FOR ALL
USING (true)
WITH CHECK (true);