-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public access to upload bucket" ON storage.objects;

-- Ensure upload bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('upload', 'upload', true)
ON CONFLICT (id) DO UPDATE 
SET public = true;

-- Create comprehensive policies for upload bucket
CREATE POLICY "Public access to upload bucket"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'upload');

CREATE POLICY "Public insert to upload bucket"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'upload');

CREATE POLICY "Public update to upload bucket"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'upload');

-- Enable RLS for storage.objects if not already enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Grant usage on storage schema to public
GRANT USAGE ON SCHEMA storage TO public;

-- Grant select on storage.objects to public
GRANT SELECT ON storage.objects TO public;

-- Grant select on storage.buckets to public
GRANT SELECT ON storage.buckets TO public;