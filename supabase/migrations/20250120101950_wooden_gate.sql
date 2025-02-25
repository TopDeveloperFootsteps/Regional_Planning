-- First: Set icon_id to NULL in settings tables to avoid FK constraint violations
UPDATE region_settings SET icon_id = NULL;
UPDATE sub_region_settings SET icon_id = NULL;

-- Now we can safely remove existing icons
DELETE FROM map_icons;

-- Add storage columns if they don't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'map_icons' 
        AND column_name = 'storage_path'
    ) THEN
        ALTER TABLE map_icons ADD COLUMN storage_path text;
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'map_icons' 
        AND column_name = 'mime_type'
    ) THEN
        ALTER TABLE map_icons ADD COLUMN mime_type text;
    END IF;
END $$;

-- Insert icons with storage paths
INSERT INTO map_icons (name, url, icon_type, storage_path, mime_type) VALUES 
    ('Location Pin Blue', 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/location-pin-blue.svg', 'both', 'location-pin-blue.svg', 'image/svg+xml'),
    ('Location Pin Green', 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/location-pin-green.svg', 'both', 'location-pin-green.svg', 'image/svg+xml'),
    ('Location Mark Blue', 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/location-mark-blue.svg', 'both', 'location-mark-blue.svg', 'image/svg+xml'),
    ('Location Mark Green', 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/location-mark-green.svg', 'both', 'location-mark-green.svg', 'image/svg+xml'),
    ('Hospital Blue', 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/hospital-blue.svg', 'both', 'hospital-blue.svg', 'image/svg+xml'),
    ('Hospital Green', 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/hospital-green.svg', 'both', 'hospital-green.svg', 'image/svg+xml'),
    ('Medical Blue', 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/medical-blue.svg', 'both', 'medical-blue.svg', 'image/svg+xml'),
    ('Medical Green', 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/medical-green.svg', 'both', 'medical-green.svg', 'image/svg+xml'),
    ('Emergency Red', 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/emergency-red.svg', 'both', 'emergency-red.svg', 'image/svg+xml');

-- Update settings with new icon IDs
UPDATE region_settings 
SET icon_id = (
    SELECT id 
    FROM map_icons 
    WHERE name = 'Location Pin Blue' 
    LIMIT 1
)
WHERE icon_id IS NULL;

UPDATE sub_region_settings 
SET icon_id = (
    SELECT id 
    FROM map_icons 
    WHERE name = 'Location Mark Blue' 
    LIMIT 1
)
WHERE icon_id IS NULL;