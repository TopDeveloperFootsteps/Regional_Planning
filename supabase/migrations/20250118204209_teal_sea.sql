/*
  # Create Service Mapping Tables

  1. New Tables
    - ambulatory_service_center_services_mapping
    - extended_care_facility_services_mapping
    - specialty_care_center_services_mapping
    Each table contains:
      - id (uuid, primary key)
      - icd_code (text)
      - service (text)
      - confidence (text: high/medium/low)
      - mapping_logic (text)
      - systems_of_care (text)
      - created_at (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add public read access policies
    
  3. Performance
    - Add indexes on icd_code and systems_of_care columns
*/

-- Create ambulatory_service_center_services_mapping table
CREATE TABLE IF NOT EXISTS ambulatory_service_center_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    service text NOT NULL,
    confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
    mapping_logic text NOT NULL,
    systems_of_care text NOT NULL,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE ambulatory_service_center_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on ambulatory_service_center_services_mapping"
    ON ambulatory_service_center_services_mapping
    FOR SELECT
    TO public
    USING (true);

CREATE INDEX IF NOT EXISTS idx_ambulatory_service_center_services_mapping_icd_code 
ON ambulatory_service_center_services_mapping (icd_code);

CREATE INDEX IF NOT EXISTS idx_ambulatory_service_center_services_mapping_systems_of_care
ON ambulatory_service_center_services_mapping (systems_of_care);

-- Create extended_care_facility_services_mapping table
CREATE TABLE IF NOT EXISTS extended_care_facility_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    service text NOT NULL,
    confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
    mapping_logic text NOT NULL,
    systems_of_care text NOT NULL,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE extended_care_facility_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on extended_care_facility_services_mapping"
    ON extended_care_facility_services_mapping
    FOR SELECT
    TO public
    USING (true);

CREATE INDEX IF NOT EXISTS idx_extended_care_facility_services_mapping_icd_code 
ON extended_care_facility_services_mapping (icd_code);

CREATE INDEX IF NOT EXISTS idx_extended_care_facility_services_mapping_systems_of_care
ON extended_care_facility_services_mapping (systems_of_care);

-- Create specialty_care_center_services_mapping table
CREATE TABLE IF NOT EXISTS specialty_care_center_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    service text NOT NULL,
    confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
    mapping_logic text NOT NULL,
    systems_of_care text NOT NULL,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE specialty_care_center_services_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on specialty_care_center_services_mapping"
    ON specialty_care_center_services_mapping
    FOR SELECT
    TO public
    USING (true);

CREATE INDEX IF NOT EXISTS idx_specialty_care_center_services_mapping_icd_code 
ON specialty_care_center_services_mapping (icd_code);

CREATE INDEX IF NOT EXISTS idx_specialty_care_center_services_mapping_systems_of_care
ON specialty_care_center_services_mapping (systems_of_care);

-- Insert some sample data for testing
INSERT INTO ambulatory_service_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) VALUES
('E11.9', 'Chronic metabolic diseases', 'high', 'Type 2 diabetes requires regular monitoring and management', 'Chronic conditions'),
('I10', 'Acute & urgent care', 'high', 'Hypertension may require immediate attention', 'Unplanned care');

INSERT INTO extended_care_facility_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) VALUES
('F32.9', 'Mental Health Services', 'high', 'Depression requires ongoing care and support', 'Complex, multi-morbid'),
('M17.9', 'Physical Therapy', 'high', 'Osteoarthritis requires regular physical therapy', 'Chronic conditions');

INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) VALUES
('C50.919', 'Oncology', 'high', 'Breast cancer requires specialized oncology care', 'Complex, multi-morbid'),
('J45.909', 'Pulmonology', 'high', 'Asthma requires specialist respiratory care', 'Chronic conditions');