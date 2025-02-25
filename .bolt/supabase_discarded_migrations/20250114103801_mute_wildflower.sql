/*
  # Create home_sp table with mappings

  1. New Tables
    - `home_sp`
      - `id` (uuid, primary key)
      - `icd_code` (text)
      - `systems_of_care` (text)
      - `service` (text)
      - `confidence` (text)
      - `mapping_logic` (text)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on `home_sp` table
    - Add policy for public read access
*/

-- Create the home_sp table
CREATE TABLE IF NOT EXISTS home_sp (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    systems_of_care text NOT NULL,
    service text,
    confidence text,
    mapping_logic text,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE home_sp ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access on home_sp"
    ON home_sp
    FOR SELECT
    TO public
    USING (true);

-- Insert data from home_codes and home_services_mapping
INSERT INTO home_sp (icd_code, systems_of_care, service, confidence, mapping_logic)
SELECT 
    hc."ICD FamilyCode",
    hc."Systems of Care",
    hsm.service,
    hsm.confidence,
    hsm.mapping_logic
FROM home_codes hc
LEFT JOIN home_services_mapping hsm ON hc."ICD FamilyCode" = hsm.icd_code;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_home_sp_icd_code 
ON home_sp (icd_code);

-- Create view to show mapping statistics
CREATE OR REPLACE VIEW home_sp_stats AS
SELECT 
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as mapped_rows,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_rows,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapped_percentage
FROM home_sp;