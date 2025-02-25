-- Drop existing policies if they exist
DO $$ 
BEGIN
    -- Drop policies for ambulatory_service_center_services_mapping
    IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow public read access on ambulatory_service_center_services_mapping') THEN
        DROP POLICY "Allow public read access on ambulatory_service_center_services_mapping" ON ambulatory_service_center_services_mapping;
    END IF;

    -- Drop policies for health_station_services_mapping
    IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow public read access on health_station_services_mapping') THEN
        DROP POLICY "Allow public read access on health_station_services_mapping" ON health_station_services_mapping;
    END IF;

    -- Drop policies for specialty_care_center_services_mapping
    IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow public read access on specialty_care_center_services_mapping') THEN
        DROP POLICY "Allow public read access on specialty_care_center_services_mapping" ON specialty_care_center_services_mapping;
    END IF;

    -- Drop policies for extended_care_facility_services_mapping
    IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow public read access on extended_care_facility_services_mapping') THEN
        DROP POLICY "Allow public read access on extended_care_facility_services_mapping" ON extended_care_facility_services_mapping;
    END IF;

    -- Drop policies for hospital_services_mapping
    IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow public read access on hospital_services_mapping') THEN
        DROP POLICY "Allow public read access on hospital_services_mapping" ON hospital_services_mapping;
    END IF;
END $$;

-- Create tables and policies
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

-- Create health_station_services_mapping table
CREATE TABLE IF NOT EXISTS health_station_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    service text NOT NULL,
    confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
    mapping_logic text NOT NULL,
    systems_of_care text NOT NULL,
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

CREATE INDEX IF NOT EXISTS idx_health_station_services_mapping_systems_of_care
ON health_station_services_mapping (systems_of_care);

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

-- Create hospital_services_mapping table
CREATE TABLE IF NOT EXISTS hospital_services_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    service text NOT NULL,
    confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
    mapping_logic text NOT NULL,
    systems_of_care text NOT NULL,
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

CREATE INDEX IF NOT EXISTS idx_hospital_services_mapping_systems_of_care
ON hospital_services_mapping (systems_of_care);