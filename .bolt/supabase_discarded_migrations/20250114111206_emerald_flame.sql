/*
  # Standardize service mapping tables

  1. New Tables
    - Recreate all service mapping tables with consistent structure:
      - ambulatory_services_mapping
      - extended_services_mapping
      - health_station_services_mapping
      - specialty_services_mapping
      - hospital_services_mapping

  2. Structure
    - All tables will have the same structure as home_sm:
      - id (uuid, primary key)
      - icd_code (text)
      - systems_of_care (text)
      - service (text)
      - confidence (text)
      - mapping_logic (text)
      - created_at (timestamptz)

  3. Security
    - Enable RLS on all tables
    - Add public read access policies
*/

-- Drop existing tables if they exist
DROP TABLE IF EXISTS ambulatory_services_mapping CASCADE;
DROP TABLE IF EXISTS extended_services_mapping CASCADE;
DROP TABLE IF EXISTS health_station_services_mapping CASCADE;
DROP TABLE IF EXISTS specialty_services_mapping CASCADE;
DROP TABLE IF EXISTS hospital_services_mapping CASCADE;

-- Create ambulatory_services_mapping
CREATE TABLE IF NOT EXISTS ambulatory_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    systems_of_care text NOT NULL,
    service text,
    confidence text,
    mapping_logic text,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE ambulatory_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on ambulatory_services_mapping"
    ON ambulatory_services_mapping
    FOR SELECT
    TO public
    USING (true);

CREATE INDEX IF NOT EXISTS idx_ambulatory_services_mapping_icd_code 
ON ambulatory_services_mapping (icd_code);

-- Create extended_services_mapping
CREATE TABLE IF NOT EXISTS extended_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    systems_of_care text NOT NULL,
    service text,
    confidence text,
    mapping_logic text,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE extended_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on extended_services_mapping"
    ON extended_services_mapping
    FOR SELECT
    TO public
    USING (true);

CREATE INDEX IF NOT EXISTS idx_extended_services_mapping_icd_code 
ON extended_services_mapping (icd_code);

-- Create health_station_services_mapping
CREATE TABLE IF NOT EXISTS health_station_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    systems_of_care text NOT NULL,
    service text,
    confidence text,
    mapping_logic text,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE health_station_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on health_station_services_mapping"
    ON health_station_services_mapping
    FOR SELECT
    TO public
    USING (true);

CREATE INDEX IF NOT EXISTS idx_health_station_services_mapping_icd_code 
ON health_station_services_mapping (icd_code);

-- Create specialty_services_mapping
CREATE TABLE IF NOT EXISTS specialty_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    systems_of_care text NOT NULL,
    service text,
    confidence text,
    mapping_logic text,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE specialty_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on specialty_services_mapping"
    ON specialty_services_mapping
    FOR SELECT
    TO public
    USING (true);

CREATE INDEX IF NOT EXISTS idx_specialty_services_mapping_icd_code 
ON specialty_services_mapping (icd_code);

-- Create hospital_services_mapping
CREATE TABLE IF NOT EXISTS hospital_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    systems_of_care text NOT NULL,
    service text,
    confidence text,
    mapping_logic text,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE hospital_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on hospital_services_mapping"
    ON hospital_services_mapping
    FOR SELECT
    TO public
    USING (true);

CREATE INDEX IF NOT EXISTS idx_hospital_services_mapping_icd_code 
ON hospital_services_mapping (icd_code);

-- Create views for mapping statistics
CREATE OR REPLACE VIEW service_mapping_stats AS
SELECT 
    'ambulatory_services_mapping' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as mapped_rows,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_rows,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapped_percentage
FROM ambulatory_services_mapping
UNION ALL
SELECT 
    'extended_services_mapping' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as mapped_rows,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_rows,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapped_percentage
FROM extended_services_mapping
UNION ALL
SELECT 
    'health_station_services_mapping' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as mapped_rows,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_rows,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapped_percentage
FROM health_station_services_mapping
UNION ALL
SELECT 
    'specialty_services_mapping' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as mapped_rows,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_rows,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapped_percentage
FROM specialty_services_mapping
UNION ALL
SELECT 
    'hospital_services_mapping' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as mapped_rows,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_rows,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapped_percentage
FROM hospital_services_mapping;