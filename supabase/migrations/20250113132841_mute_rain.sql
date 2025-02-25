/*
  # Create home services mapping table

  1. New Tables
    - `home_services_mapping`
      - `id` (uuid, primary key)
      - `icd_code` (text, references home_codes)
      - `service` (text)
      - `confidence` (text)
      - `mapping_logic` (text)
      - `created_at` (timestamp)
  2. Security
    - Enable RLS on `home_services_mapping` table
    - Add policy for authenticated users to read data
*/

CREATE TABLE IF NOT EXISTS home_services_mapping (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  icd_code text NOT NULL,
  service text NOT NULL,
  confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
  mapping_logic text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE home_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for authenticated users on home_services_mapping"
  ON home_services_mapping
  FOR SELECT
  TO authenticated
  USING (true);