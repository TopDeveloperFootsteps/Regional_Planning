-- Insert data from extended_care_facility_codes to extended_services_mapping
INSERT INTO extended_services_mapping 
(icd_code, systems_of_care, service, confidence, mapping_logic)
SELECT 
    codes."ICD FamilyCode",
    codes."Systems of Care",
    'Pending Review',  -- Default service
    'medium',         -- Default confidence
    'Initial mapping from extended_care_facility_codes' -- Default mapping logic
FROM extended_care_facility_codes codes;

-- Create a view to monitor the data transfer
CREATE OR REPLACE VIEW extended_mapping_status AS
SELECT 
    COUNT(DISTINCT codes."ICD FamilyCode") as total_source_codes,
    COUNT(DISTINCT mapping.icd_code) as total_mapped_codes,
    ROUND((COUNT(DISTINCT mapping.icd_code)::numeric / NULLIF(COUNT(DISTINCT codes."ICD FamilyCode"), 0)::numeric) * 100, 2) as transfer_percentage
FROM extended_care_facility_codes codes
LEFT JOIN extended_services_mapping mapping ON codes."ICD FamilyCode" = mapping.icd_code;