-- Enable storage for icons bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('icons', 'icons', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public access to icons bucket
CREATE POLICY "Allow public access to icons"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'icons');

-- Allow authenticated uploads to icons bucket
CREATE POLICY "Allow authenticated uploads to icons"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'icons');

-- Allow authenticated updates to icons bucket
CREATE POLICY "Allow authenticated updates to icons"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'icons');

-- Allow authenticated deletes from icons bucket
CREATE POLICY "Allow authenticated deletes from icons"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'icons');