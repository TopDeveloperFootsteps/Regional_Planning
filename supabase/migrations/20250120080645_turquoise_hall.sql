-- Drop all icon and storage related tables and policies
DROP TABLE IF EXISTS map_icons CASCADE;
DROP TABLE IF EXISTS region_settings CASCADE;
DROP TABLE IF EXISTS sub_region_settings CASCADE;

-- Clean up storage
DELETE FROM storage.objects 
WHERE bucket_id IN ('icons', 'upload');

DELETE FROM storage.buckets 
WHERE id IN ('icons', 'upload');

-- Remove all storage policies
DROP POLICY IF EXISTS "Public access to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public insert to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public update to icons bucket" ON storage.objects;
DROP POLICY IF EXISTS "unrestricted_storage_policy" ON storage.objects;
DROP POLICY IF EXISTS "Allow public upload access" ON storage.objects;
DROP POLICY IF EXISTS "Allow public select access" ON storage.objects;
DROP POLICY IF EXISTS "Public access to upload bucket" ON storage.objects;
DROP POLICY IF EXISTS "unrestricted_buckets_policy" ON storage.buckets;

-- Update map_settings table to remove icon-related settings
ALTER TABLE IF EXISTS map_settings
    DROP COLUMN IF EXISTS show_icons;

-- Ensure regions and sub_regions have correct structure without icon references
ALTER TABLE IF EXISTS regions
    DROP COLUMN IF EXISTS icon_id,
    DROP COLUMN IF EXISTS circle_radius_km;

ALTER TABLE IF EXISTS sub_regions
    DROP COLUMN IF EXISTS icon_id,
    DROP COLUMN IF EXISTS circle_radius_km;