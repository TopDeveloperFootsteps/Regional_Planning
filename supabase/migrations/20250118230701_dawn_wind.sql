-- First: Get current unmapped codes statistics
WITH unmapped_stats AS (
  SELECT 
    "system of care",
    LEFT("icd family code", 3) as icd_prefix,
    COUNT(*) as count
  FROM encounters
  WHERE "care setting" = 'SPECIALTY CARE CENTER'
  AND service IS NULL
  GROUP BY "system of care", LEFT("icd family code", 3)
  ORDER BY COUNT(*) DESC
  LIMIT 500
)
SELECT * FROM unmapped_stats;

-- Add mappings for first batch of 500 unmapped codes
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Cardiology & Cardiovascular
  ('I11', 'Cardiology', 'high', 'Hypertensive heart disease requires cardiology management', 'Chronic conditions'),
  ('I12', 'Cardiology', 'high', 'Hypertensive chronic kidney disease needs specialist care', 'Complex, multi-morbid'),
  ('I13', 'Cardiology', 'high', 'Hypertensive heart and chronic kidney disease', 'Complex, multi-morbid'),
  ('I15', 'Cardiology', 'high', 'Secondary hypertension requires specialist evaluation', 'Chronic conditions'),
  ('I21', 'Cardiology', 'high', 'Acute myocardial infarction needs urgent cardiac care', 'Unplanned care'),
  
  -- Pulmonology
  ('J40', 'Pulmonology / Respiratory Medicine', 'high', 'Bronchitis requires respiratory care', 'Chronic conditions'),
  ('J41', 'Pulmonology / Respiratory Medicine', 'high', 'Simple chronic bronchitis needs management', 'Chronic conditions'),
  ('J42', 'Pulmonology / Respiratory Medicine', 'high', 'Unspecified chronic bronchitis requires care', 'Chronic conditions'),
  ('J43', 'Pulmonology / Respiratory Medicine', 'high', 'Emphysema needs specialist management', 'Chronic conditions'),
  ('J47', 'Pulmonology / Respiratory Medicine', 'high', 'Bronchiectasis requires specialist care', 'Chronic conditions'),
  
  -- Gastroenterology
  ('K20', 'Gastroenterology', 'high', 'Esophagitis needs gastroenterology care', 'Chronic conditions'),
  ('K25', 'Gastroenterology', 'high', 'Gastric ulcer requires specialist management', 'Chronic conditions'),
  ('K29', 'Gastroenterology', 'high', 'Gastritis and duodenitis need evaluation', 'Chronic conditions'),
  ('K30', 'Gastroenterology', 'high', 'Functional dyspepsia requires assessment', 'Chronic conditions'),
  ('K31', 'Gastroenterology', 'high', 'Other diseases of stomach and duodenum', 'Chronic conditions'),
  
  -- Neurology
  ('G20', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Parkinsons disease needs neurological care', 'Complex, multi-morbid'),
  ('G21', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Secondary parkinsonism requires evaluation', 'Complex, multi-morbid'),
  ('G23', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Other degenerative diseases of basal ganglia', 'Complex, multi-morbid'),
  ('G24', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Dystonia needs specialist management', 'Complex, multi-morbid'),
  ('G25', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Other extrapyramidal and movement disorders', 'Complex, multi-morbid'),
  
  -- Endocrinology
  ('E10', 'Endocrinology', 'high', 'Type 1 diabetes requires endocrine care', 'Chronic conditions'),
  ('E11', 'Endocrinology', 'high', 'Type 2 diabetes needs specialist management', 'Chronic conditions'),
  ('E13', 'Endocrinology', 'high', 'Other specified diabetes mellitus', 'Chronic conditions'),
  ('E14', 'Endocrinology', 'high', 'Unspecified diabetes mellitus needs evaluation', 'Chronic conditions'),
  ('E15', 'Endocrinology', 'high', 'Nondiabetic hypoglycemic coma requires care', 'Unplanned care'),
  
  -- Rheumatology
  ('M05', 'Rheumatology', 'high', 'Rheumatoid arthritis needs specialist care', 'Chronic conditions'),
  ('M06', 'Rheumatology', 'high', 'Other rheumatoid arthritis requires management', 'Chronic conditions'),
  ('M08', 'Rheumatology', 'high', 'Juvenile arthritis needs pediatric rheumatology', 'Children and young people'),
  ('M10', 'Rheumatology', 'high', 'Gout requires rheumatology care', 'Chronic conditions'),
  ('M11', 'Rheumatology', 'high', 'Other crystal arthropathies need evaluation', 'Chronic conditions'),
  
  -- Nephrology
  ('N17', 'Nephrology', 'high', 'Acute kidney failure needs urgent care', 'Unplanned care'),
  ('N18', 'Nephrology', 'high', 'Chronic kidney disease requires management', 'Complex, multi-morbid'),
  ('N19', 'Nephrology', 'high', 'Unspecified kidney failure needs evaluation', 'Complex, multi-morbid'),
  ('N20', 'Nephrology', 'high', 'Kidney stone requires specialist care', 'Unplanned care'),
  ('N21', 'Nephrology', 'high', 'Calculus of lower urinary tract needs treatment', 'Unplanned care'),
  
  -- Hematology
  ('D50', 'Haematology', 'high', 'Iron deficiency anemia needs evaluation', 'Chronic conditions'),
  ('D51', 'Haematology', 'high', 'Vitamin B12 deficiency anemia requires care', 'Chronic conditions'),
  ('D52', 'Haematology', 'high', 'Folate deficiency anemia needs management', 'Chronic conditions'),
  ('D53', 'Haematology', 'high', 'Other nutritional anemias require treatment', 'Chronic conditions'),
  ('D55', 'Haematology', 'high', 'Enzyme disorder anemia needs specialist care', 'Complex, multi-morbid');

-- Update encounters with new mappings
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'SPECIALTY CARE CENTER'
        AND service IS NULL
        LIMIT 500
    LOOP
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_care_center_services_mapping
        WHERE icd_code LIKE LEFT(r."icd family code", 3) || '%'
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

-- Show mapping progress
SELECT 
    'SPECIALTY CARE CENTER' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';