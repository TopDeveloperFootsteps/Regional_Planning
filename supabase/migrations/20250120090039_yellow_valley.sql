-- First remove existing icons
DELETE FROM map_icons;

-- Insert location and location mark icons (blue and green)
INSERT INTO map_icons (name, url, icon_type) VALUES 
    ('Location Pin Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/map-pin.svg', 'both'),
    ('Location Pin Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/navigation.svg', 'both'),
    ('Location Mark Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/locate.svg', 'both'),
    ('Location Mark Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/target.svg', 'both'),
    ('Navigation Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/navigation-2.svg', 'both'),
    ('Navigation Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/compass.svg', 'both'),

    -- Healthcare facility icons (blue and green)
    ('Hospital Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/building-2.svg', 'both'),
    ('Hospital Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/hotel.svg', 'both'),
    ('Medical Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/stethoscope.svg', 'both'),
    ('Medical Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/heart-pulse.svg', 'both'),
    ('Clinic Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/activity.svg', 'both'),
    ('Clinic Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/first-aid.svg', 'both'),

    -- Government/Organization icons (blue and green)
    ('Government Blue', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/landmark.svg', 'both'),
    ('Government Green', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/building.svg', 'both'),

    -- Emergency icon (red)
    ('Emergency Red', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/ambulance.svg', 'both');

-- Update region settings to use a default icon
UPDATE region_settings 
SET icon_id = (
    SELECT id 
    FROM map_icons 
    WHERE name = 'Location Pin Blue' 
    LIMIT 1
);

-- Update sub-region settings to use a default icon
UPDATE sub_region_settings 
SET icon_id = (
    SELECT id 
    FROM map_icons 
    WHERE name = 'Location Mark Blue' 
    LIMIT 1
);