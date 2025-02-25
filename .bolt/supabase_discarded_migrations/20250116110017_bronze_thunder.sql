-- Drop the table if it exists to ensure a clean slate
DROP TABLE IF EXISTS care_settings_encounters CASCADE;

-- Create the care_settings_encounters table
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

-- Add comments for better documentation
COMMENT ON TABLE care_settings_encounters IS 'Stores encounter data for ICD codes across different care settings';
COMMENT ON COLUMN care_settings_encounters.care_setting IS 'The healthcare setting where the encounter occurred';
COMMENT ON COLUMN care_settings_encounters.systems_of_care IS 'The system of care category';
COMMENT ON COLUMN care_settings_encounters.icd_family_code IS 'The ICD-10 family code';
COMMENT ON COLUMN care_settings_encounters.encounters IS 'Number of encounters for this combination';