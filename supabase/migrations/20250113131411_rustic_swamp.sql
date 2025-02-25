/*
  # Create Care Setting Codes Tables

  1. New Tables
    - `health_station_codes`
    - `home_codes`
    - `ambulatory_service_center_codes`
    - `specialty_care_center_codes`
    - `extended_care_facility_codes`
    - `hospital_codes`

    Each table has the following columns:
    - `id` (uuid, primary key)
    - `care_setting` (text)
    - `systems_of_care` (text)
    - `icd_family_code` (text)
    - `created_at` (timestamp with time zone)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to read data
*/

-- Health Station Codes
CREATE TABLE IF NOT EXISTS health_station_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  care_setting text NOT NULL,
  systems_of_care text NOT NULL,
  icd_family_code text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE health_station_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for authenticated users on health_station_codes"
  ON health_station_codes
  FOR SELECT
  TO authenticated
  USING (true);

-- Home Codes
CREATE TABLE IF NOT EXISTS home_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  care_setting text NOT NULL,
  systems_of_care text NOT NULL,
  icd_family_code text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE home_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for authenticated users on home_codes"
  ON home_codes
  FOR SELECT
  TO authenticated
  USING (true);

-- Ambulatory Service Center Codes
CREATE TABLE IF NOT EXISTS ambulatory_service_center_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  care_setting text NOT NULL,
  systems_of_care text NOT NULL,
  icd_family_code text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE ambulatory_service_center_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for authenticated users on ambulatory_service_center_codes"
  ON ambulatory_service_center_codes
  FOR SELECT
  TO authenticated
  USING (true);

-- Specialty Care Center Codes
CREATE TABLE IF NOT EXISTS specialty_care_center_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  care_setting text NOT NULL,
  systems_of_care text NOT NULL,
  icd_family_code text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE specialty_care_center_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for authenticated users on specialty_care_center_codes"
  ON specialty_care_center_codes
  FOR SELECT
  TO authenticated
  USING (true);

-- Extended Care Facility Codes
CREATE TABLE IF NOT EXISTS extended_care_facility_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  care_setting text NOT NULL,
  systems_of_care text NOT NULL,
  icd_family_code text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE extended_care_facility_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for authenticated users on extended_care_facility_codes"
  ON extended_care_facility_codes
  FOR SELECT
  TO authenticated
  USING (true);

-- Hospital Codes
CREATE TABLE IF NOT EXISTS hospital_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  care_setting text NOT NULL,
  systems_of_care text NOT NULL,
  icd_family_code text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE hospital_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for authenticated users on hospital_codes"
  ON hospital_codes
  FOR SELECT
  TO authenticated
  USING (true);