/*
  # Initialize Specialty Care Center Services Mapping

  1. Changes
    - Insert initial data from specialty_care_center_codes
    - Create monitoring view for mapping status
*/

-- Insert data from specialty_care_center_codes to specialty_services_mapping
INSERT INTO specialty_services_mapping 
(icd_code, systems_of_care, service, confidence, mapping_logic)
SELECT 
    codes."ICD FamilyCode",
    codes."Systems of Care",
    'Pending Review',  -- Default service
    'medium',         -- Default confidence
    'Initial mapping from specialty_care_center_codes' -- Default mapping logic
FROM specialty_care_center_codes codes;

-- Create a view to monitor the data transfer
CREATE OR REPLACE VIEW specialty_mapping_status AS
SELECT 
    COUNT(DISTINCT codes."ICD FamilyCode") as total_source_codes,
    COUNT(DISTINCT mapping.icd_code) as total_mapped_codes,
    ROUND((COUNT(DISTINCT mapping.icd_code)::numeric / NULLIF(COUNT(DISTINCT codes."ICD FamilyCode"), 0)::numeric) * 100, 2) as transfer_percentage
FROM specialty_care_center_codes codes
LEFT JOIN specialty_services_mapping mapping ON codes."ICD FamilyCode" = mapping.icd_code;