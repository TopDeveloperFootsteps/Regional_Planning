-- First remove any references to icons from other tables
ALTER TABLE IF EXISTS regions 
    DROP COLUMN IF EXISTS icon_id;

ALTER TABLE IF EXISTS sub_regions 
    DROP COLUMN IF EXISTS icon_id;

ALTER TABLE IF EXISTS region_settings 
    DROP COLUMN IF EXISTS icon_id;

ALTER TABLE IF EXISTS sub_region_settings 
    DROP COLUMN IF EXISTS icon_id;

-- Drop settings tables that might reference icons
DROP TABLE IF EXISTS region_settings CASCADE;
DROP TABLE IF EXISTS sub_region_settings CASCADE;

-- Clean up storage objects first
DELETE FROM storage.objects 
WHERE bucket_id IN ('icons', 'upload');

-- Now clean up storage buckets
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
DROP POLICY IF EXISTS "unrestricted_buckets_policy" ON storage.buckets;

-- Ensure regions table has correct structure
CREATE TABLE IF NOT EXISTS regions (
    id text PRIMARY KEY,
    name text NOT NULL,
    latitude decimal(10,6) NOT NULL,
    longitude decimal(10,6) NOT NULL,
    status region_status DEFAULT 'active',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Ensure sub_regions table has correct structure
CREATE TABLE IF NOT EXISTS sub_regions (
    id text PRIMARY KEY,
    region_id text REFERENCES regions(id) ON DELETE CASCADE,
    name text NOT NULL,
    latitude decimal(10,6) NOT NULL,
    longitude decimal(10,6) NOT NULL,
    status region_status DEFAULT 'active',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);