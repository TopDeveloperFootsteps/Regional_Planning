-- Drop and recreate the care_settings_encounters table
DROP TABLE IF EXISTS care_settings_encounters CASCADE;

CREATE TABLE care_settings_encounters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    systems_of_care text NOT NULL,
    icd_family_code text NOT NULL,
    encounters integer NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE care_settings_encounters ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access on care_settings_encounters"
    ON care_settings_encounters
    FOR SELECT
    TO public
    USING (true);

-- Create indexes for better query performance
CREATE INDEX idx_encounters_care_setting 
ON care_settings_encounters (care_setting);

CREATE INDEX idx_encounters_icd_code 
ON care_settings_encounters (icd_family_code);

CREATE INDEX idx_encounters_systems_of_care 
ON care_settings_encounters (systems_of_care);

-- Insert sample encounter data
INSERT INTO care_settings_encounters 
(care_setting, systems_of_care, icd_family_code, encounters)
VALUES
  -- Home care encounters
  ('HOME', 'Chronic conditions', 'E11.9', 1250),
  ('HOME', 'Chronic conditions', 'I10', 2340),
  ('HOME', 'Chronic conditions', 'J44.9', 890),
  ('HOME', 'Complex, multi-morbid', 'F32.9', 567),
  ('HOME', 'Planned care', 'Z71.3', 789),
  ('HOME', 'Children and young people', 'Z00.129', 1234),
  ('HOME', 'Wellness and longevity', 'Z13.1', 456),
  ('HOME', 'Palliative care and support', 'Z51.5', 234),
  ('HOME', 'Unplanned care', 'R50.9', 678),
  ('HOME', 'Complex, multi-morbid', 'R26.81', 345),

  -- Health station encounters
  ('HEALTH STATION', 'Chronic conditions', 'E11.9', 3456),
  ('HEALTH STATION', 'Chronic conditions', 'I10', 4567),
  ('HEALTH STATION', 'Planned care', 'Z00.00', 2345),
  ('HEALTH STATION', 'Children and young people', 'Z00.129', 3456),
  ('HEALTH STATION', 'Wellness and longevity', 'Z13.1', 1234),
  ('HEALTH STATION', 'Unplanned care', 'J06.9', 2345),
  ('HEALTH STATION', 'Complex, multi-morbid', 'F41.1', 890),
  ('HEALTH STATION', 'Palliative care and support', 'Z51.5', 123),
  ('HEALTH STATION', 'Chronic conditions', 'J45.909', 1567),
  ('HEALTH STATION', 'Planned care', 'Z71.3', 2345),

  -- Ambulatory service center encounters
  ('AMBULATORY SERVICE CENTER', 'Chronic conditions', 'E11.9', 4567),
  ('AMBULATORY SERVICE CENTER', 'Chronic conditions', 'I10', 5678),
  ('AMBULATORY SERVICE CENTER', 'Planned care', 'Z51.81', 3456),
  ('AMBULATORY SERVICE CENTER', 'Children and young people', 'Z00.129', 2345),
  ('AMBULATORY SERVICE CENTER', 'Wellness and longevity', 'Z13.1', 1678),
  ('AMBULATORY SERVICE CENTER', 'Unplanned care', 'R10.9', 3456),
  ('AMBULATORY SERVICE CENTER', 'Complex, multi-morbid', 'F41.1', 1234),
  ('AMBULATORY SERVICE CENTER', 'Palliative care and support', 'Z51.5', 567),
  ('AMBULATORY SERVICE CENTER', 'Chronic conditions', 'J45.909', 2345),
  ('AMBULATORY SERVICE CENTER', 'Planned care', 'Z71.3', 3456),

  -- Specialty care center encounters
  ('SPECIALTY CARE CENTER', 'Chronic conditions', 'C50.911', 2345),
  ('SPECIALTY CARE CENTER', 'Chronic conditions', 'I25.10', 3456),
  ('SPECIALTY CARE CENTER', 'Planned care', 'Z51.11', 4567),
  ('SPECIALTY CARE CENTER', 'Children and young people', 'Q21.1', 1234),
  ('SPECIALTY CARE CENTER', 'Complex, multi-morbid', 'G35', 2345),
  ('SPECIALTY CARE CENTER', 'Palliative care and support', 'Z51.5', 890),
  ('SPECIALTY CARE CENTER', 'Chronic conditions', 'M05.79', 1567),
  ('SPECIALTY CARE CENTER', 'Unplanned care', 'S06.0X0A', 2345),
  ('SPECIALTY CARE CENTER', 'Complex, multi-morbid', 'F20.0', 1234),
  ('SPECIALTY CARE CENTER', 'Planned care', 'Z51.81', 3456),

  -- Extended care facility encounters
  ('EXTENDED CARE FACILITY', 'Complex, multi-morbid', 'F03.90', 3456),
  ('EXTENDED CARE FACILITY', 'Chronic conditions', 'I50.9', 4567),
  ('EXTENDED CARE FACILITY', 'Palliative care and support', 'Z51.5', 2345),
  ('EXTENDED CARE FACILITY', 'Complex, multi-morbid', 'G20', 1678),
  ('EXTENDED CARE FACILITY', 'Chronic conditions', 'J44.9', 2345),
  ('EXTENDED CARE FACILITY', 'Complex, multi-morbid', 'R26.81', 3456),
  ('EXTENDED CARE FACILITY', 'Planned care', 'Z51.89', 1234),
  ('EXTENDED CARE FACILITY', 'Chronic conditions', 'E11.9', 2345),
  ('EXTENDED CARE FACILITY', 'Complex, multi-morbid', 'F41.1', 1567),
  ('EXTENDED CARE FACILITY', 'Palliative care and support', 'Z51.11', 890),

  -- Hospital encounters
  ('HOSPITAL', 'Unplanned care', 'I21.4', 4567),
  ('HOSPITAL', 'Complex, multi-morbid', 'J96.01', 5678),
  ('HOSPITAL', 'Chronic conditions', 'E11.649', 3456),
  ('HOSPITAL', 'Children and young people', 'P07.39', 2345),
  ('HOSPITAL', 'Palliative care and support', 'Z51.5', 1234),
  ('HOSPITAL', 'Unplanned care', 'S72.0XA', 3456),
  ('HOSPITAL', 'Complex, multi-morbid', 'F20.0', 2345),
  ('HOSPITAL', 'Chronic conditions', 'I50.9', 4567),
  ('HOSPITAL', 'Planned care', 'Z51.11', 3456),
  ('HOSPITAL', 'Children and young people', 'Q21.1', 2345);

-- Create views for data analysis
CREATE OR REPLACE VIEW encounter_statistics AS
SELECT 
    care_setting,
    systems_of_care,
    COUNT(*) as total_codes,
    SUM(encounters) as total_encounters,
    ROUND(AVG(encounters)::numeric, 2) as avg_encounters_per_code,
    MAX(encounters) as max_encounters,
    MIN(encounters) as min_encounters
FROM care_settings_encounters
GROUP BY care_setting, systems_of_care
ORDER BY care_setting, systems_of_care;

CREATE OR REPLACE VIEW encounter_summary_by_care_setting AS
SELECT 
    care_setting,
    COUNT(DISTINCT icd_family_code) as unique_codes,
    COUNT(*) as total_records,
    SUM(encounters) as total_encounters,
    ROUND(AVG(encounters)::numeric, 2) as avg_encounters,
    MAX(encounters) as max_encounters
FROM care_settings_encounters
GROUP BY care_setting
ORDER BY care_setting;

CREATE OR REPLACE VIEW encounter_summary_by_system AS
SELECT 
    systems_of_care,
    COUNT(DISTINCT icd_family_code) as unique_codes,
    COUNT(*) as total_records,
    SUM(encounters) as total_encounters,
    ROUND(AVG(encounters)::numeric, 2) as avg_encounters,
    MAX(encounters) as max_encounters
FROM care_settings_encounters
GROUP BY systems_of_care
ORDER BY systems_of_care;

CREATE OR REPLACE VIEW top_icd_codes_by_encounters AS
SELECT 
    icd_family_code,
    care_setting,
    systems_of_care,
    encounters,
    RANK() OVER (PARTITION BY care_setting ORDER BY encounters DESC) as rank_in_setting
FROM care_settings_encounters
WHERE encounters > 0
ORDER BY encounters DESC, care_setting, icd_family_code
LIMIT 100;