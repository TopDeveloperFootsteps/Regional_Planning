-- Create a view to count mapped vs unmapped codes
CREATE OR REPLACE VIEW home_mapping_summary AS
SELECT 
    status,
    COUNT(*) as code_count
FROM home_codes_mapping_status
GROUP BY status
ORDER BY status DESC;

-- Create a view to list unmapped codes with their systems of care
CREATE OR REPLACE VIEW unmapped_home_codes_detail AS
SELECT 
    "ICD FamilyCode" as icd_code,
    "Systems of Care" as system_of_care
FROM home_codes
WHERE NOT EXISTS (
    SELECT 1 
    FROM home_services_mapping 
    WHERE home_codes."ICD FamilyCode" = home_services_mapping.icd_code
)
ORDER BY "ICD FamilyCode";