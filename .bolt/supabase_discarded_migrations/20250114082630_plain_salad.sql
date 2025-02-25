/*
  # Fix mapping status view

  1. Changes
    - Updates the view to use a less strict join condition
    - Adds UPPER and TRIM to ensure consistent string comparison
    - Adds diagnostic counts to help verify the data
*/

-- First, create a diagnostic view to help us understand the data
CREATE OR REPLACE VIEW home_mapping_diagnostics AS
SELECT 
    COUNT(*) as total_codes,
    SUM(CASE WHEN hsm.id IS NOT NULL THEN 1 ELSE 0 END) as mapped_count,
    SUM(CASE WHEN hsm.id IS NULL THEN 1 ELSE 0 END) as unmapped_count
FROM 
    home_codes hc
LEFT JOIN 
    home_services_mapping hsm 
    ON UPPER(TRIM(hc."ICD FamilyCode")) = UPPER(TRIM(hsm.icd_code));

-- Update the main status view with improved joining logic
DROP VIEW IF EXISTS home_codes_mapping_status;

CREATE OR REPLACE VIEW home_codes_mapping_status AS
SELECT 
    hc."ICD FamilyCode" as icd_code,
    hc."Systems of Care" as systems_of_care,
    CASE 
        WHEN hsm.id IS NOT NULL THEN 'Mapped'
        ELSE 'Not mapped'
    END as status,
    hsm.service as mapped_service,
    hsm.confidence as mapping_confidence,
    hsm.systems_of_care as mapped_system_of_care
FROM 
    home_codes hc
LEFT JOIN 
    home_services_mapping hsm 
    ON UPPER(TRIM(hc."ICD FamilyCode")) = UPPER(TRIM(hsm.icd_code))
ORDER BY 
    status DESC,
    hc."ICD FamilyCode";