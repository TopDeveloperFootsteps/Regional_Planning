/*
  # Map health station services

  1. Changes
    - Update health station services mapping with appropriate services based on ICD code patterns
    - Set confidence levels and mapping logic
    - Create monitoring view for mapping statistics
*/

-- Update codes starting with 'A' or 'B' (Infectious diseases)
UPDATE health_station_services_mapping
SET 
    service = 'Acute & urgent care',
    confidence = 'high',
    mapping_logic = 'Infectious diseases typically require acute care at health stations'
WHERE service = 'Pending Review' 
AND (LEFT(icd_code, 1) = 'A' OR LEFT(icd_code, 1) = 'B');

-- Update codes starting with 'C' (Neoplasms)
UPDATE health_station_services_mapping
SET 
    service = 'Complex condition / Frail elderly',
    confidence = 'high',
    mapping_logic = 'Neoplasms require complex care management at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'C';

-- Update codes starting with 'D' (Blood disorders)
UPDATE health_station_services_mapping
SET 
    service = 'Chronic metabolic diseases',
    confidence = 'high',
    mapping_logic = 'Blood disorders require ongoing metabolic management at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'D';

-- Update codes starting with 'E' (Endocrine disorders)
UPDATE health_station_services_mapping
SET 
    service = 'Chronic metabolic diseases',
    confidence = 'high',
    mapping_logic = 'Endocrine disorders require metabolic management at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'E';

-- Update codes starting with 'F' (Mental disorders)
UPDATE health_station_services_mapping
SET 
    service = 'Chronic mental health disorders',
    confidence = 'high',
    mapping_logic = 'Mental health conditions require specialized mental health care at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'F';

-- Update codes starting with 'G' (Nervous system)
UPDATE health_station_services_mapping
SET 
    service = 'Complex condition / Frail elderly',
    confidence = 'high',
    mapping_logic = 'Neurological conditions require complex care at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'G';

-- Update codes starting with 'H' (Eye and ear)
UPDATE health_station_services_mapping
SET 
    service = 'Allied Health & Health Promotion',
    confidence = 'medium',
    mapping_logic = 'Eye and ear conditions require allied health support at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'H';

-- Update codes starting with 'I' (Circulatory system)
UPDATE health_station_services_mapping
SET 
    service = 'Chronic metabolic diseases',
    confidence = 'high',
    mapping_logic = 'Circulatory conditions require metabolic management at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'I';

-- Update codes starting with 'J' (Respiratory system)
UPDATE health_station_services_mapping
SET 
    service = 'Chronic respiratory diseases',
    confidence = 'high',
    mapping_logic = 'Respiratory conditions require specialized respiratory care at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'J';

-- Update codes starting with 'K' (Digestive system)
UPDATE health_station_services_mapping
SET 
    service = 'Other chronic diseases',
    confidence = 'high',
    mapping_logic = 'Digestive conditions require chronic disease management at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'K';

-- Update codes starting with 'L' (Skin)
UPDATE health_station_services_mapping
SET 
    service = 'Allied Health & Health Promotion',
    confidence = 'medium',
    mapping_logic = 'Skin conditions require allied health support at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'L';

-- Update codes starting with 'M' (Musculoskeletal)
UPDATE health_station_services_mapping
SET 
    service = 'Allied Health & Health Promotion',
    confidence = 'high',
    mapping_logic = 'Musculoskeletal conditions require physical therapy at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'M';

-- Update codes starting with 'N' (Genitourinary)
UPDATE health_station_services_mapping
SET 
    service = 'Complex condition / Frail elderly',
    confidence = 'high',
    mapping_logic = 'Genitourinary conditions require complex care at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'N';

-- Update codes starting with 'O' (Pregnancy)
UPDATE health_station_services_mapping
SET 
    service = 'Maternal Care',
    confidence = 'high',
    mapping_logic = 'Pregnancy-related conditions require maternal care at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'O';

-- Update codes starting with 'P' (Perinatal)
UPDATE health_station_services_mapping
SET 
    service = 'Well baby care (0 to 4)',
    confidence = 'high',
    mapping_logic = 'Perinatal conditions require specialized newborn care at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'P';

-- Update codes starting with 'Q' (Congenital)
UPDATE health_station_services_mapping
SET 
    service = 'Complex condition / Frail elderly',
    confidence = 'high',
    mapping_logic = 'Congenital conditions require complex care at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'Q';

-- Update codes starting with 'R' (Symptoms)
UPDATE health_station_services_mapping
SET 
    service = 'Acute & urgent care',
    confidence = 'medium',
    mapping_logic = 'General symptoms require initial assessment at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'R';

-- Update codes starting with 'S' or 'T' (Injury)
UPDATE health_station_services_mapping
SET 
    service = 'Acute & urgent care',
    confidence = 'high',
    mapping_logic = 'Injuries require immediate care at health stations'
WHERE service = 'Pending Review' 
AND (LEFT(icd_code, 1) = 'S' OR LEFT(icd_code, 1) = 'T');

-- Update codes starting with 'V', 'W', 'X', or 'Y' (External causes)
UPDATE health_station_services_mapping
SET 
    service = 'Acute & urgent care',
    confidence = 'high',
    mapping_logic = 'External causes require immediate assessment at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) IN ('V', 'W', 'X', 'Y');

-- Update codes starting with 'Z' (Factors influencing health)
UPDATE health_station_services_mapping
SET 
    service = 'Routine health checks',
    confidence = 'high',
    mapping_logic = 'Health factors require routine monitoring at health stations'
WHERE service = 'Pending Review' 
AND LEFT(icd_code, 1) = 'Z';

-- Update remaining unmapped codes based on systems of care
UPDATE health_station_services_mapping
SET 
    service = CASE 
        WHEN systems_of_care = 'Unplanned care' THEN 'Acute & urgent care'
        WHEN systems_of_care = 'Planned care' THEN 'Allied Health & Health Promotion'
        WHEN systems_of_care = 'Children and young people' THEN 'Paediatric care (5 to 16)'
        WHEN systems_of_care = 'Complex, multi-morbid' THEN 'Complex condition / Frail elderly'
        WHEN systems_of_care = 'Chronic conditions' THEN 'Other chronic diseases'
        WHEN systems_of_care = 'Palliative care and support' THEN 'Complex condition / Frail elderly'
        WHEN systems_of_care = 'Wellness and longevity' THEN 'Routine health checks'
    END,
    confidence = 'medium',
    mapping_logic = CASE 
        WHEN systems_of_care = 'Unplanned care' THEN 'Mapped based on unplanned care requirement at health station'
        WHEN systems_of_care = 'Planned care' THEN 'Mapped based on planned care requirement at health station'
        WHEN systems_of_care = 'Children and young people' THEN 'Mapped based on pediatric care requirement at health station'
        WHEN systems_of_care = 'Complex, multi-morbid' THEN 'Mapped based on complex care requirement at health station'
        WHEN systems_of_care = 'Chronic conditions' THEN 'Mapped based on chronic care requirement at health station'
        WHEN systems_of_care = 'Palliative care and support' THEN 'Mapped based on palliative care requirement at health station'
        WHEN systems_of_care = 'Wellness and longevity' THEN 'Mapped based on wellness requirement at health station'
    END
WHERE service = 'Pending Review';

-- Create a view to show mapping statistics by category
CREATE OR REPLACE VIEW health_station_mapping_categories AS
SELECT 
    service,
    systems_of_care,
    COUNT(*) as code_count,
    confidence,
    STRING_AGG(DISTINCT LEFT(icd_code, 1), ', ') as icd_categories
FROM health_station_services_mapping
GROUP BY service, systems_of_care, confidence
ORDER BY service, systems_of_care;