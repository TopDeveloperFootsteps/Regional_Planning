/*
  # Add Additional Specialty Care Service Mappings

  1. New Mappings
    - Add comprehensive set of specialty care service mappings
    - Focus on common specialty conditions and procedures
    - Cover multiple systems of care

  2. Process
    - Insert new specialty care mappings
    - Update unmapped encounters
    - Show updated mapping statistics
*/

-- Add more specialty care service mappings
INSERT INTO specialty_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Cardiology
  ('I20', 'Cardiology', 'high', 'Angina pectoris requires specialized cardiac care', 'Complex, multi-morbid'),
  ('I25', 'Cardiology', 'high', 'Chronic ischemic heart disease needs specialist management', 'Chronic conditions'),
  ('I35', 'Cardiology', 'high', 'Aortic valve disorders require specialized cardiac evaluation', 'Complex, multi-morbid'),
  
  -- Endocrinology
  ('E05', 'Endocrinology', 'high', 'Thyrotoxicosis requires specialist endocrine care', 'Chronic conditions'),
  ('E06', 'Endocrinology', 'high', 'Thyroiditis needs endocrinology management', 'Chronic conditions'),
  ('E21', 'Endocrinology', 'high', 'Hyperparathyroidism requires specialist care', 'Complex, multi-morbid'),
  
  -- Gastroenterology
  ('K21', 'Gastroenterology', 'high', 'Gastro-esophageal reflux disease requiring specialist care', 'Chronic conditions'),
  ('K25', 'Gastroenterology', 'high', 'Gastric ulcer needs specialized management', 'Chronic conditions'),
  ('K70', 'Gastroenterology', 'high', 'Alcoholic liver disease requires specialist care', 'Complex, multi-morbid'),
  
  -- Neurology
  ('G40', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Epilepsy requires neurological management', 'Chronic conditions'),
  ('G43', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Migraine needs specialized neurological care', 'Chronic conditions'),
  ('G47', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Sleep disorders require specialist evaluation', 'Chronic conditions'),
  
  -- Pulmonology
  ('J44', 'Pulmonology / Respiratory Medicine', 'high', 'COPD requires specialist respiratory care', 'Chronic conditions'),
  ('J47', 'Pulmonology / Respiratory Medicine', 'high', 'Bronchiectasis needs pulmonology management', 'Chronic conditions'),
  ('J84', 'Pulmonology / Respiratory Medicine', 'high', 'Interstitial lung disease requires specialist care', 'Complex, multi-morbid'),
  
  -- Rheumatology
  ('M06', 'Rheumatology', 'high', 'Other rheumatoid arthritis requires specialist care', 'Chronic conditions'),
  ('M45', 'Rheumatology', 'high', 'Ankylosing spondylitis needs rheumatology management', 'Chronic conditions'),
  ('M35', 'Rheumatology', 'high', 'Systemic connective tissue disorders need specialist care', 'Complex, multi-morbid'),
  
  -- Nephrology
  ('N18', 'Nephrology', 'high', 'Chronic kidney disease requires specialist care', 'Complex, multi-morbid'),
  ('N04', 'Nephrology', 'high', 'Nephrotic syndrome needs nephrology management', 'Complex, multi-morbid'),
  ('N10', 'Nephrology', 'high', 'Acute pyelonephritis requires specialist evaluation', 'Unplanned care'),
  
  -- Hematology
  ('D50', 'Haematology', 'high', 'Iron deficiency anemia needs specialist evaluation', 'Chronic conditions'),
  ('D55', 'Haematology', 'high', 'Enzyme disorders need hematology management', 'Complex, multi-morbid'),
  ('D69', 'Haematology', 'high', 'Purpura and other hemorrhagic conditions require specialist care', 'Complex, multi-morbid'),
  
  -- Oncology
  ('C15', 'Oncology', 'high', 'Esophageal cancer requires specialized oncology care', 'Complex, multi-morbid'),
  ('C25', 'Oncology', 'high', 'Pancreatic cancer needs comprehensive oncology management', 'Complex, multi-morbid'),
  ('C43', 'Oncology', 'high', 'Melanoma requires specialist oncology care', 'Complex, multi-morbid');

-- Map SPECIALTY CARE CENTER encounters
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    -- Loop through unmapped SPECIALTY CARE CENTER encounters
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'SPECIALTY CARE CENTER'
        AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
    LOOP
        -- Get mapping from specialty_services_mapping
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_services_mapping
        WHERE icd_code LIKE LEFT(r."icd family code", 3) || '%'
        AND systems_of_care = r."system of care"
        LIMIT 1
        INTO mapping_result;
        
        -- Update encounter if mapping found
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