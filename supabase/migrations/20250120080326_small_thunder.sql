-- First delete all objects in the icons bucket
DELETE FROM storage.objects
WHERE bucket_id = 'icons';

-- Now we can safely delete the bucket
DELETE FROM storage.buckets 
WHERE id = 'icons';

-- Drop icon-related tables and storage policies
DROP TABLE IF EXISTS map_icons CASCADE;

-- Remove storage policies
DROP POLICY IF EXISTS "Public access to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public insert to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public update to icons bucket" ON storage.objects;