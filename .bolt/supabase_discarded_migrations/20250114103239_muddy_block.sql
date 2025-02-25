-- Create a view to show mapping status
CREATE OR REPLACE VIEW mapping_status AS
SELECT 
    (SELECT COUNT(*) FROM home_codes) as total_codes,
    (SELECT COUNT(*) FROM home_services_mapping) as total_mappings,
    (
        SELECT COUNT(DISTINCT hc."ICD FamilyCode") 
        FROM home_codes hc
        LEFT JOIN home_services_mapping hsm ON hc."ICD FamilyCode" = hsm.icd_code
        WHERE hsm.id IS NULL
    ) as unmapped_codes,
    CASE 
        WHEN (SELECT COUNT(*) FROM home_services_mapping) > (SELECT COUNT(*) FROM home_codes) THEN 'Too many mappings'
        WHEN (SELECT COUNT(*) FROM home_services_mapping) < (SELECT COUNT(*) FROM home_codes) THEN 'Missing mappings'
        ELSE 'Correct number of mappings'
    END as status;

-- Create a view to list unmapped codes
CREATE OR REPLACE VIEW unmapped_codes AS
SELECT 
    hc."ICD FamilyCode",
    hc."Systems of Care",
    CASE 
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'A' THEN 'Infectious diseases'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'B' THEN 'Infectious diseases'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'C' THEN 'Neoplasms'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'D' THEN 'Blood and immune system'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'E' THEN 'Endocrine and metabolic'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'F' THEN 'Mental and behavioral'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'G' THEN 'Nervous system'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'H' THEN 'Eye and ear'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'I' THEN 'Circulatory system'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'J' THEN 'Respiratory system'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'K' THEN 'Digestive system'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'L' THEN 'Skin'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'M' THEN 'Musculoskeletal system'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'N' THEN 'Genitourinary system'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'O' THEN 'Pregnancy and childbirth'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'P' THEN 'Perinatal conditions'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'Q' THEN 'Congenital malformations'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'R' THEN 'Symptoms and signs'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'S' THEN 'Injury and trauma'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'T' THEN 'Injury and trauma'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'V' THEN 'External causes'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'W' THEN 'External causes'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'X' THEN 'External causes'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'Y' THEN 'External causes'
        WHEN LEFT(hc."ICD FamilyCode", 1) = 'Z' THEN 'Factors influencing health'
        ELSE 'Other'
    END as category
FROM home_codes hc
LEFT JOIN home_services_mapping hsm ON hc."ICD FamilyCode" = hsm.icd_code
WHERE hsm.id IS NULL
ORDER BY category, hc."ICD FamilyCode";