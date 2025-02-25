-- Create storage bucket for icons
INSERT INTO storage.buckets (id, name, public)
VALUES ('icons', 'icons', true)
ON CONFLICT (id) DO UPDATE 
SET public = true;

-- Create policy for public access to icons bucket
CREATE POLICY "Public access to icons bucket"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'icons');

-- Insert sample icons
INSERT INTO map_icons (name, url, icon_type)
VALUES 
    ('City', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/city.svg', 'region'),
    ('Building', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/building.svg', 'region'),
    ('Landmark', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/landmark.svg', 'region'),
    ('Home', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/home.svg', 'sub_region'),
    ('Store', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/store.svg', 'sub_region'),
    ('Building 2', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/building-2.svg', 'both'),
    ('Map Pin', 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/map-pin.svg', 'both');