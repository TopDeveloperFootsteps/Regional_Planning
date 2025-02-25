-- Add comprehensive specialty care mappings based on ServiceList 2
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- General Medicine Categories
  ('A', 'Infectious Diseases', 'high', 'Infectious and parasitic diseases require specialist management', 'Complex, multi-morbid'),
  ('B', 'Infectious Diseases', 'high', 'Viral infections need specialist care', 'Complex, multi-morbid'),
  ('C', 'Oncology', 'high', 'Malignant neoplasms require oncology care', 'Complex, multi-morbid'),
  ('D', 'Haematology', 'high', 'Blood disorders need hematology management', 'Complex, multi-morbid'),
  ('E', 'Endocrinology', 'high', 'Endocrine and metabolic disorders require specialist care', 'Chronic conditions'),
  ('F', 'Psychiatry', 'high', 'Mental and behavioral disorders need psychiatric care', 'Complex, multi-morbid'),
  ('G', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Diseases of nervous system require neurological care', 'Complex, multi-morbid'),
  ('H', 'Ophthalmology', 'high', 'Eye and adnexa disorders need ophthalmology care', 'Planned care'),
  ('I', 'Cardiology', 'high', 'Circulatory system diseases require cardiology care', 'Complex, multi-morbid'),
  ('J', 'Pulmonology / Respiratory Medicine', 'high', 'Respiratory system diseases need pulmonology care', 'Chronic conditions'),
  ('K', 'Gastroenterology', 'high', 'Digestive system diseases require gastroenterology care', 'Chronic conditions'),
  ('L', 'Dermatology', 'high', 'Skin and subcutaneous tissue disorders need dermatology care', 'Planned care'),
  ('M', 'Rheumatology', 'high', 'Musculoskeletal system disorders need rheumatology care', 'Chronic conditions'),
  ('N', 'Nephrology', 'high', 'Genitourinary system diseases require nephrology care', 'Complex, multi-morbid'),
  ('O', 'Obstetrics & Gynaecology', 'high', 'Pregnancy and childbirth conditions need specialist care', 'Planned care'),
  ('P', 'Paediatric Medicine', 'high', 'Conditions originating in perinatal period need pediatric care', 'Children and young people'),
  ('Q', 'Medical Genetics', 'high', 'Congenital malformations need genetics specialist care', 'Complex, multi-morbid'),
  ('R', 'Internal Medicine', 'high', 'Symptoms and signs need internal medicine evaluation', 'Unplanned care'),
  ('S', 'General Surgery', 'high', 'Injuries require surgical care', 'Unplanned care'),
  ('T', 'General Surgery', 'high', 'Injuries and consequences of external causes need surgical care', 'Unplanned care'),
  ('Z', 'Social, Community and Preventative Medicine', 'high', 'Factors influencing health status need preventive care', 'Planned care');

-- Update remaining unmapped encounters using broader category matching
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'SPECIALTY CARE CENTER'
        AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
    LOOP
        -- Get first character of ICD code for category matching
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_care_center_services_mapping
        WHERE icd_code = LEFT(r."icd family code", 1)
        AND systems_of_care = r."system of care"
        LIMIT 1
        INTO mapping_result;
        
        IF mapping_result IS NOT NULL THEN
            UPDATE encounters 
            SET 
                service = mapping_result.service,
                confidence = mapping_result.confidence,
                "mapping logic" = mapping_result.mapping_logic
            WHERE id = r.id;
        END IF;
    END LOOP;
END $$;

-- Show updated mapping statistics
SELECT 
    'SPECIALTY CARE CENTER' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';