/*
  # Update home_services_mapping table access policy
  
  1. Changes
    - Drop existing RLS policy that requires authentication
    - Add new policy for public read access
    
  2. Security
    - Enables public read access to home_services_mapping table
    - No authentication required for SELECT operations
*/

-- Drop the existing policy
DROP POLICY IF EXISTS "Allow read access for authenticated users on home_services_mapping" ON home_services_mapping;

-- Create new policy for public access
CREATE POLICY "Allow public read access on home_services_mapping"
  ON home_services_mapping
  FOR SELECT
  TO public
  USING (true);