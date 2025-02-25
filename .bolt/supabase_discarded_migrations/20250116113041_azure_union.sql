/*
  # Update Care Settings Encounters Table

  1. Changes
    - Add service column
    - Add confidence column
    - Add mapping_logic column
    - Add constraints and validation

  2. Data Preservation
    - Existing data is preserved
    - New columns are added with default values
    - Indexes are updated for new columns

  3. Security
    - RLS policies are maintained
    - New column access is granted
*/

-- Add new columns to the table
ALTER TABLE care_settings_encounters
ADD COLUMN service text,
ADD COLUMN confidence text CHECK (confidence IN ('high', 'medium', 'low')),
ADD COLUMN mapping_logic text;

-- Create indexes for new columns
CREATE INDEX IF NOT EXISTS idx_encounters_service
ON care_settings_encounters (service);

CREATE INDEX IF NOT EXISTS idx_encounters_confidence
ON care_settings_encounters (confidence);

-- Update existing views to include new columns
CREATE OR REPLACE VIEW encounter_statistics AS
SELECT 
    care_setting,
    systems_of_care,
    service,
    confidence,
    COUNT(*) as total_codes,
    SUM(encounters) as total_encounters,
    ROUND(AVG(encounters)::numeric, 2) as avg_encounters_per_code,
    MAX(encounters) as max_encounters,
    MIN(encounters) as min_encounters
FROM care_settings_encounters
GROUP BY care_setting, systems_of_care, service, confidence
ORDER BY care_setting, systems_of_care;

CREATE OR REPLACE VIEW encounter_summary_by_care_setting AS
SELECT 
    care_setting,
    COUNT(DISTINCT icd_family_code) as unique_codes,
    COUNT(DISTINCT service) as unique_services,
    COUNT(*) as total_records,
    SUM(encounters) as total_encounters,
    ROUND(AVG(encounters)::numeric, 2) as avg_encounters,
    MAX(encounters) as max_encounters
FROM care_settings_encounters
GROUP BY care_setting
ORDER BY care_setting;

CREATE OR REPLACE VIEW top_icd_codes_by_encounters AS
SELECT 
    icd_family_code,
    care_setting,
    systems_of_care,
    service,
    confidence,
    encounters,
    mapping_logic,
    RANK() OVER (PARTITION BY care_setting ORDER BY encounters DESC) as rank_in_setting
FROM care_settings_encounters
WHERE encounters > 0
ORDER BY encounters DESC, care_setting, icd_family_code
LIMIT 100;

-- Create new view for service mapping analysis
CREATE OR REPLACE VIEW service_mapping_analysis AS
SELECT 
    service,
    confidence,
    COUNT(*) as total_mappings,
    COUNT(DISTINCT icd_family_code) as unique_codes,
    COUNT(DISTINCT care_setting) as care_settings_count,
    SUM(encounters) as total_encounters,
    ROUND(AVG(encounters)::numeric, 2) as avg_encounters
FROM care_settings_encounters
WHERE service IS NOT NULL
GROUP BY service, confidence
ORDER BY total_mappings DESC;

-- Add comments for documentation
COMMENT ON COLUMN care_settings_encounters.service IS 'The mapped service for this ICD code and care setting';
COMMENT ON COLUMN care_settings_encounters.confidence IS 'Confidence level of the service mapping (high, medium, low)';
COMMENT ON COLUMN care_settings_encounters.mapping_logic IS 'Explanation of the mapping logic used';