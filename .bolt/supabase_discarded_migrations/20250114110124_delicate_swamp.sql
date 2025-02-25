/*
  # Map remaining ICD codes

  1. Updates
    - Map remaining ICD codes in home_sp based on code patterns and systems of care
    - Use logical mapping based on ICD code categories and system of care context
    - Default to Acute & urgent care for general medical conditions when no specific service applies
*/

-- Update codes starting with 'A' or 'B' (Infectious diseases)
UPDATE home_sp
SET 
    service = 'Acute & urgent care',
    confidence = 'high',
    mapping_logic = 'Infectious diseases typically require acute care and monitoring'
WHERE service IS NULL 
AND (LEFT(icd_code, 1) = 'A' OR LEFT(icd_code, 1) = 'B');

-- Update codes starting with 'C' (Neoplasms)
UPDATE home_sp
SET 
    service = 'Complex condition / Frail elderly',
    confidence = 'high',
    mapping_logic = 'Neoplasms require complex care management'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'C';

-- Update codes starting with 'D' (Blood disorders)
UPDATE home_sp
SET 
    service = 'Chronic metabolic diseases',
    confidence = 'high',
    mapping_logic = 'Blood disorders require ongoing metabolic management'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'D';

-- Update codes starting with 'E' (Endocrine disorders)
UPDATE home_sp
SET 
    service = 'Chronic metabolic diseases',
    confidence = 'high',
    mapping_logic = 'Endocrine disorders require metabolic management'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'E';

-- Update codes starting with 'F' (Mental disorders)
UPDATE home_sp
SET 
    service = 'Chronic mental health disorders',
    confidence = 'high',
    mapping_logic = 'Mental health conditions require specialized mental health care'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'F';

-- Update codes starting with 'G' (Nervous system)
UPDATE home_sp
SET 
    service = 'Complex condition / Frail elderly',
    confidence = 'high',
    mapping_logic = 'Neurological conditions often require complex care management'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'G';

-- Update codes starting with 'H' (Eye and ear)
UPDATE home_sp
SET 
    service = 'Allied Health & Health Promotion',
    confidence = 'medium',
    mapping_logic = 'Eye and ear conditions often require allied health support'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'H';

-- Update codes starting with 'I' (Circulatory system)
UPDATE home_sp
SET 
    service = 'Chronic metabolic diseases',
    confidence = 'high',
    mapping_logic = 'Circulatory conditions require metabolic management'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'I';

-- Update codes starting with 'J' (Respiratory system)
UPDATE home_sp
SET 
    service = 'Chronic respiratory diseases',
    confidence = 'high',
    mapping_logic = 'Respiratory conditions require specialized respiratory care'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'J';

-- Update codes starting with 'K' (Digestive system)
UPDATE home_sp
SET 
    service = 'Other chronic diseases',
    confidence = 'high',
    mapping_logic = 'Digestive conditions require chronic disease management'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'K';

-- Update codes starting with 'L' (Skin)
UPDATE home_sp
SET 
    service = 'Allied Health & Health Promotion',
    confidence = 'medium',
    mapping_logic = 'Skin conditions often require allied health support'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'L';

-- Update codes starting with 'M' (Musculoskeletal)
UPDATE home_sp
SET 
    service = 'Allied Health & Health Promotion',
    confidence = 'high',
    mapping_logic = 'Musculoskeletal conditions require physical therapy and allied health'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'M';

-- Update codes starting with 'N' (Genitourinary)
UPDATE home_sp
SET 
    service = 'Complex condition / Frail elderly',
    confidence = 'high',
    mapping_logic = 'Genitourinary conditions often require complex care'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'N';

-- Update codes starting with 'O' (Pregnancy)
UPDATE home_sp
SET 
    service = 'Maternal Care',
    confidence = 'high',
    mapping_logic = 'Pregnancy-related conditions require maternal care'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'O';

-- Update codes starting with 'P' (Perinatal)
UPDATE home_sp
SET 
    service = 'Well baby care (0 to 4)',
    confidence = 'high',
    mapping_logic = 'Perinatal conditions require specialized newborn care'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'P';

-- Update codes starting with 'Q' (Congenital)
UPDATE home_sp
SET 
    service = 'Complex condition / Frail elderly',
    confidence = 'high',
    mapping_logic = 'Congenital conditions require complex care management'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'Q';

-- Update codes starting with 'R' (Symptoms)
UPDATE home_sp
SET 
    service = 'Acute & urgent care',
    confidence = 'medium',
    mapping_logic = 'General symptoms require initial acute care assessment'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'R';

-- Update codes starting with 'S' or 'T' (Injury)
UPDATE home_sp
SET 
    service = 'Acute & urgent care',
    confidence = 'high',
    mapping_logic = 'Injuries require immediate acute care'
WHERE service IS NULL 
AND (LEFT(icd_code, 1) = 'S' OR LEFT(icd_code, 1) = 'T');

-- Update codes starting with 'V', 'W', 'X', or 'Y' (External causes)
UPDATE home_sp
SET 
    service = 'Acute & urgent care',
    confidence = 'high',
    mapping_logic = 'External causes require immediate acute care assessment'
WHERE service IS NULL 
AND LEFT(icd_code, 1) IN ('V', 'W', 'X', 'Y');

-- Update codes starting with 'Z' (Factors influencing health)
UPDATE home_sp
SET 
    service = 'Routine health checks',
    confidence = 'high',
    mapping_logic = 'Health factors require routine health monitoring'
WHERE service IS NULL 
AND LEFT(icd_code, 1) = 'Z';

-- Create a view to show final mapping statistics
CREATE OR REPLACE VIEW home_sp_final_stats AS
SELECT 
    service,
    systems_of_care,
    COUNT(*) as code_count,
    confidence,
    STRING_AGG(DISTINCT LEFT(icd_code, 1), ', ') as icd_categories
FROM home_sp
WHERE service IS NOT NULL
GROUP BY service, systems_of_care, confidence
ORDER BY service, systems_of_care;