-- First remove all objects from the icons bucket
DELETE FROM storage.objects
WHERE bucket_id = 'icons';

-- Drop icon-related tables and storage policies
DROP TABLE IF EXISTS map_icons CASCADE;

-- Remove storage policies
DROP POLICY IF EXISTS "Public access to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public insert to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public update to icons bucket" ON storage.objects;

-- Now we can safely remove the bucket
DELETE FROM storage.buckets 
WHERE id = 'icons' 
AND NOT EXISTS (
    SELECT 1 FROM storage.objects 
    WHERE bucket_id = 'icons'
);