/*
  # Create service mapping tables for all care settings

  1. New Tables
    - health_station_services_mapping
    - ambulatory_services_mapping
    - specialty_services_mapping
    - extended_services_mapping
    - hospital_services_mapping

  2. Structure
    Each table includes:
    - id (uuid)
    - icd_code (text)
    - service (text)
    - confidence (text)
    - mapping_logic (text)
    - systems_of_care (text)
    - created_at (timestamptz)

  3. Security
    - Enable RLS on all tables
    - Add public read access policy for each table
*/

-- Health Station Services Mapping
CREATE TABLE IF NOT EXISTS health_station_services_mapping (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  icd_code text NOT NULL,
  service text NOT NULL,
  confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
  mapping_logic text NOT NULL,
  systems_of_care text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE health_station_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on health_station_services_mapping"
  ON health_station_services_mapping
  FOR SELECT
  TO public
  USING (true);

-- Ambulatory Services Mapping
CREATE TABLE IF NOT EXISTS ambulatory_services_mapping (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  icd_code text NOT NULL,
  service text NOT NULL,
  confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
  mapping_logic text NOT NULL,
  systems_of_care text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE ambulatory_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on ambulatory_services_mapping"
  ON ambulatory_services_mapping
  FOR SELECT
  TO public
  USING (true);

-- Specialty Services Mapping
CREATE TABLE IF NOT EXISTS specialty_services_mapping (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  icd_code text NOT NULL,
  service text NOT NULL,
  confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
  mapping_logic text NOT NULL,
  systems_of_care text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE specialty_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on specialty_services_mapping"
  ON specialty_services_mapping
  FOR SELECT
  TO public
  USING (true);

-- Extended Services Mapping
CREATE TABLE IF NOT EXISTS extended_services_mapping (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  icd_code text NOT NULL,
  service text NOT NULL,
  confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
  mapping_logic text NOT NULL,
  systems_of_care text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE extended_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on extended_services_mapping"
  ON extended_services_mapping
  FOR SELECT
  TO public
  USING (true);

-- Hospital Services Mapping
CREATE TABLE IF NOT EXISTS hospital_services_mapping (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  icd_code text NOT NULL,
  service text NOT NULL,
  confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
  mapping_logic text NOT NULL,
  systems_of_care text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE hospital_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on hospital_services_mapping"
  ON hospital_services_mapping
  FOR SELECT
  TO public
  USING (true);

-- Create indexes for faster searches
CREATE INDEX IF NOT EXISTS idx_health_station_services_mapping_icd_code 
ON health_station_services_mapping (icd_code);

CREATE INDEX IF NOT EXISTS idx_ambulatory_services_mapping_icd_code 
ON ambulatory_services_mapping (icd_code);

CREATE INDEX IF NOT EXISTS idx_specialty_services_mapping_icd_code 
ON specialty_services_mapping (icd_code);

CREATE INDEX IF NOT EXISTS idx_extended_services_mapping_icd_code 
ON extended_services_mapping (icd_code);

CREATE INDEX IF NOT EXISTS idx_hospital_services_mapping_icd_code 
ON hospital_services_mapping (icd_code);