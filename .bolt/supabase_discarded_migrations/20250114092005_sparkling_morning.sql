/*
  # Create view for unmapped ICD codes with categories

  1. New Views
    - Creates a comprehensive view showing unmapped ICD codes with their categories
    - Includes code category based on ICD-10 chapter classification
    - Shows system of care and total unmapped count
    - Automatically updates when codes are mapped

  2. Features
    - Categorizes codes by ICD-10 chapters
    - Shows system of care grouping
    - Provides running total of unmapped codes
    - Orders results by category and code
*/

CREATE OR REPLACE VIEW unmapped_icd_codes AS
WITH unmapped_codes AS (
    SELECT 
        hc."ICD FamilyCode" as icd_code,
        hc."Systems of Care" as system_of_care,
        CASE 
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'A' THEN 'Chapter 1: Infectious diseases'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'B' THEN 'Chapter 1: Infectious diseases'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'C' THEN 'Chapter 2: Neoplasms'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'D' THEN 'Chapter 3: Blood and immune system'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'E' THEN 'Chapter 4: Endocrine and metabolic'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'F' THEN 'Chapter 5: Mental and behavioral'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'G' THEN 'Chapter 6: Nervous system'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'H' THEN 'Chapter 7: Eye and ear'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'I' THEN 'Chapter 9: Circulatory system'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'J' THEN 'Chapter 10: Respiratory system'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'K' THEN 'Chapter 11: Digestive system'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'L' THEN 'Chapter 12: Skin conditions'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'M' THEN 'Chapter 13: Musculoskeletal system'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'N' THEN 'Chapter 14: Genitourinary system'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'O' THEN 'Chapter 15: Pregnancy and childbirth'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'P' THEN 'Chapter 16: Perinatal conditions'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'Q' THEN 'Chapter 17: Congenital malformations'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'R' THEN 'Chapter 18: Symptoms and signs'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'S' THEN 'Chapter 19: Injury and trauma'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'T' THEN 'Chapter 19: Injury and trauma'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'V' THEN 'Chapter 20: External causes'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'W' THEN 'Chapter 20: External causes'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'X' THEN 'Chapter 20: External causes'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'Y' THEN 'Chapter 20: External causes'
            WHEN LEFT(hc."ICD FamilyCode", 1) = 'Z' THEN 'Chapter 21: Factors influencing health'
            ELSE 'Other'
        END as icd_chapter,
        SUBSTRING(hc."ICD FamilyCode" from 1 for 3) as code_block
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
    icd_chapter,
    code_block,
    COUNT(*) OVER() as total_unmapped_count,
    COUNT(*) OVER(PARTITION BY icd_chapter) as chapter_unmapped_count
FROM unmapped_codes
ORDER BY 
    icd_chapter,
    code_block,
    icd_code;