/*
  # Create detailed view for unmapped home codes

  1. New View
    - Creates a comprehensive view of unmapped ICD-10 codes
    - Includes system of care information
    - Provides additional context about the codes

  2. Features
    - Lists all unmapped codes with their systems of care
    - Orders results for easy analysis
    - Includes total count of unmapped codes
*/

-- Drop existing view if it exists
DROP VIEW IF EXISTS unmapped_home_codes_detailed;

-- Create new comprehensive view for unmapped codes
CREATE OR REPLACE VIEW unmapped_home_codes_detailed AS
WITH unmapped_codes AS (
    SELECT 
        hc."ICD FamilyCode" as icd_code,
        hc."Systems of Care" as system_of_care,
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
        END as code_category
    FROM home_codes hc
    WHERE NOT EXISTS (
        SELECT 1 
        FROM home_services_mapping hsm 
        WHERE hc."ICD FamilyCode" = hsm.icd_code
    )
)
SELECT 
    icd_code,
    system_of_care,
    code_category,
    COUNT(*) OVER() as total_unmapped_count
FROM unmapped_codes
ORDER BY 
    code_category,
    system_of_care,
    icd_code;

-- Create a summary view for unmapped codes by category
CREATE OR REPLACE VIEW unmapped_home_codes_summary AS
SELECT 
    code_category,
    system_of_care,
    COUNT(*) as code_count
FROM unmapped_home_codes_detailed
GROUP BY 
    code_category,
    system_of_care
ORDER BY 
    code_category,
    system_of_care;