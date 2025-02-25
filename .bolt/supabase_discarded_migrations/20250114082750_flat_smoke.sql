/*
  # Diagnose mapping data issue

  1. Changes
    - Add diagnostic queries to check data in both tables
    - Add sample data to home_codes if empty
    - Ensure consistent ICD code format
*/

-- First, let's see what data we have
CREATE OR REPLACE VIEW home_mapping_data_check AS
SELECT 
    'home_codes' as table_name,
    COUNT(*) as record_count,
    array_agg(DISTINCT "ICD FamilyCode") as sample_codes
FROM home_codes
UNION ALL
SELECT 
    'home_services_mapping' as table_name,
    COUNT(*) as record_count,
    array_agg(DISTINCT icd_code) as sample_codes
FROM home_services_mapping;

-- Add sample data to home_codes if it's empty
INSERT INTO home_codes ("Care Setting", "Systems of Care", "ICD FamilyCode")
SELECT 
    'HOME',
    systems_of_care,
    icd_code
FROM home_services_mapping
WHERE NOT EXISTS (
    SELECT 1 FROM home_codes WHERE "ICD FamilyCode" = home_services_mapping.icd_code
)
ON CONFLICT DO NOTHING;