-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public access to icons bucket" ON storage.objects;

-- Create upload bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('upload', 'upload', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Create policy for public access to upload bucket
CREATE POLICY "Public access to upload bucket"
ON storage.objects FOR ALL
USING (bucket_id = 'upload')
WITH CHECK (bucket_id = 'upload');