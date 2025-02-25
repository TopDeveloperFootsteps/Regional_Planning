-- First: Set icon_id to NULL in settings tables to avoid FK constraint violations
UPDATE region_settings SET icon_id = NULL;
UPDATE sub_region_settings SET icon_id = NULL;

-- Now we can safely remove existing icons
DELETE FROM map_icons;

-- Insert new icons with proper SVG URLs
INSERT INTO map_icons (name, url, icon_type) VALUES 
    ('Location Pin Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/map-pin.svg', 'both'),
    ('Location Pin Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/navigation.svg', 'both'),
    ('Location Mark Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/locate.svg', 'both'),
    ('Location Mark Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/target.svg', 'both'),
    ('Hospital Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/building-2.svg', 'both'),
    ('Hospital Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/hotel.svg', 'both'),
    ('Medical Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/stethoscope.svg', 'both'),
    ('Medical Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/heart-pulse.svg', 'both'),
    ('Emergency Red', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/plus-circle.svg', 'both');

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