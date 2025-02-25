/*
  # Copy ambulatory service center codes to mapping table

  1. Changes
    - Copy ICD codes and systems of care from ambulatory_service_center_codes to ambulatory_services_mapping
    - Set default values for service, confidence, and mapping_logic
    - Create monitoring view
*/

-- Insert data from ambulatory_service_center_codes to ambulatory_services_mapping
INSERT INTO ambulatory_services_mapping 
(icd_code, systems_of_care, service, confidence, mapping_logic)
SELECT 
    codes."ICD FamilyCode",
    codes."Systems of Care",
    'Pending Review',  -- Default service
    'medium',         -- Default confidence
    'Initial mapping from ambulatory_service_center_codes' -- Default mapping logic
FROM ambulatory_service_center_codes codes;

-- Create a view to monitor the data transfer
CREATE OR REPLACE VIEW ambulatory_mapping_status AS
SELECT 
    COUNT(DISTINCT codes."ICD FamilyCode") as total_source_codes,
    COUNT(DISTINCT mapping.icd_code) as total_mapped_codes,
    ROUND((COUNT(DISTINCT mapping.icd_code)::numeric / NULLIF(COUNT(DISTINCT codes."ICD FamilyCode"), 0)::numeric) * 100, 2) as transfer_percentage
FROM ambulatory_service_center_codes codes
LEFT JOIN ambulatory_services_mapping mapping ON codes."ICD FamilyCode" = mapping.icd_code;