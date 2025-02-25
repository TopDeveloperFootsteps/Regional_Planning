/*
  # Add comprehensive mapping status view

  1. New View
    - Creates home_codes_mapping_status view that shows:
      - ICD codes
      - Systems of Care
      - Mapping status (Mapped/Not mapped)
      - Service (if mapped)
      - Confidence (if mapped)
  
  2. Changes
    - Replaces the existing unmapped_home_codes view with a more comprehensive view
*/

DROP VIEW IF EXISTS unmapped_home_codes;

CREATE OR REPLACE VIEW home_codes_mapping_status AS
SELECT 
    hc."ICD FamilyCode" as icd_code,
    hc."Systems of Care" as systems_of_care,
    CASE 
        WHEN hsm.id IS NOT NULL THEN 'Mapped'
        ELSE 'Not mapped'
    END as status,
    hsm.service as mapped_service,
    hsm.confidence as mapping_confidence
FROM 
    home_codes hc
LEFT JOIN 
    home_services_mapping hsm 
    ON hc."ICD FamilyCode" = hsm.icd_code 
    AND hc."Systems of Care" = hsm.systems_of_care
ORDER BY 
    status DESC,
    hc."ICD FamilyCode";