-- First remove any references to map_icons from other tables
ALTER TABLE regions DROP COLUMN IF EXISTS icon_id;
ALTER TABLE sub_regions DROP COLUMN IF EXISTS icon_id;
ALTER TABLE region_settings DROP COLUMN IF EXISTS icon_id;
ALTER TABLE sub_region_settings DROP COLUMN IF EXISTS icon_id;

-- Drop icon-related tables
DROP TABLE IF EXISTS map_icons CASCADE;

-- Delete all objects in the icons bucket
DELETE FROM storage.objects
WHERE bucket_id = 'icons';

-- Delete all objects in the upload bucket (used for icon uploads)
DELETE FROM storage.objects
WHERE bucket_id = 'upload';

-- Remove the buckets
DELETE FROM storage.buckets 
WHERE id IN ('icons', 'upload');

-- Remove storage policies
DROP POLICY IF EXISTS "Public access to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public insert to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public update to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "unrestricted_storage_policy" ON storage.objects;
DROP POLICY IF EXISTS "Allow public upload access" ON storage.objects;
DROP POLICY IF EXISTS "Allow public select access" ON storage.objects;
DROP POLICY IF EXISTS "Public access to upload bucket" ON storage.objects;