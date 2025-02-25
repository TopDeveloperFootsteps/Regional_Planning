-- First: Remove any existing icon references to avoid constraint violations
UPDATE region_settings SET icon_id = NULL;
UPDATE sub_region_settings SET icon_id = NULL;

-- Now we can safely remove existing icons
DELETE FROM map_icons;

-- Insert icons with direct URLs
INSERT INTO map_icons (name, url, icon_type) VALUES 
    ('Location Pin', 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"%3E%3Cpath d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/%3E%3Ccircle cx="12" cy="10" r="3"/%3E%3C/svg%3E', 'both'),
    ('Navigation', 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"%3E%3Cpolygon points="3 11 22 2 13 21 11 13 3 11"/%3E%3C/svg%3E', 'both'),
    ('Building', 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"%3E%3Crect x="4" y="2" width="16" height="20" rx="2" ry="2"/%3E%3Cpath d="M9 22v-4h6v4"/%3E%3Cpath d="M8 6h.01"/%3E%3Cpath d="M16 6h.01"/%3E%3Cpath d="M12 6h.01"/%3E%3Cpath d="M12 10h.01"/%3E%3Cpath d="M12 14h.01"/%3E%3Cpath d="M16 10h.01"/%3E%3Cpath d="M16 14h.01"/%3E%3Cpath d="M8 10h.01"/%3E%3Cpath d="M8 14h.01"/%3E%3C/svg%3E', 'both');

-- Update settings with new icon IDs
UPDATE region_settings 
SET icon_id = (
    SELECT id 
    FROM map_icons 
    WHERE name = 'Location Pin'
    LIMIT 1
)
WHERE icon_id IS NULL;

UPDATE sub_region_settings 
SET icon_id = (
    SELECT id 
    FROM map_icons 
    WHERE name = 'Navigation'
    LIMIT 1
)
WHERE icon_id IS NULL;