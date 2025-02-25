-- Create storage bucket for icons
INSERT INTO storage.buckets (id, name, public)
VALUES ('icons', 'icons', true)
ON CONFLICT (id) DO UPDATE 
SET public = true;

-- Enable RLS for storage
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create comprehensive storage policies
CREATE POLICY "Allow public read access to icons"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'icons');

CREATE POLICY "Allow public upload to icons"
    ON storage.objects FOR INSERT
    TO public
    WITH CHECK (bucket_id = 'icons');

CREATE POLICY "Allow public update to icons"
    ON storage.objects FOR UPDATE
    TO public
    USING (bucket_id = 'icons')
    WITH CHECK (bucket_id = 'icons');

-- Update map_icons table to use storage URLs
ALTER TABLE map_icons 
ADD COLUMN storage_path text,
ADD COLUMN mime_type text;

-- Create function to get public URL
CREATE OR REPLACE FUNCTION get_icon_url(storage_path text)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/' || storage_path;
END;
$$;