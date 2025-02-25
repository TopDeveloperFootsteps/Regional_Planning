/*
  # Phase 1: High-Priority Specialty Care Mappings

  1. Focus Areas
    - Map most frequent ICD codes first
    - Prioritize complex, multi-morbid and chronic conditions
    - Cover major medical specialties

  2. Approach
    - Add comprehensive specialty mappings
    - Update encounters table with new mappings
    - Track mapping statistics
*/

-- Phase 1: Add high-priority specialty mappings
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Neurosurgery
  ('G91', 'Neurosurgery', 'high', 'Hydrocephalus requires neurosurgical intervention', 'Complex, multi-morbid'),
  ('G93', 'Neurosurgery', 'high', 'Other disorders of brain need specialist evaluation', 'Complex, multi-morbid'),
  ('G95', 'Neurosurgery', 'high', 'Other diseases of spinal cord require specialist care', 'Complex, multi-morbid'),

  -- Cardiothoracic Surgery
  ('I71', 'Cardiothoracic & Cardiovascular Surgery', 'high', 'Aortic aneurysm requires specialized surgical care', 'Complex, multi-morbid'),
  ('I72', 'Cardiothoracic & Cardiovascular Surgery', 'high', 'Other aneurysm needs surgical evaluation', 'Complex, multi-morbid'),
  ('Q20', 'Cardiothoracic & Cardiovascular Surgery', 'high', 'Congenital malformations of cardiac chambers', 'Complex, multi-morbid'),

  -- Endocrinology
  ('E22', 'Endocrinology', 'high', 'Hyperfunction of pituitary gland needs specialist care', 'Complex, multi-morbid'),
  ('E23', 'Endocrinology', 'high', 'Hypofunction of pituitary gland requires management', 'Complex, multi-morbid'),
  ('E24', 'Endocrinology', 'high', 'Cushings syndrome needs endocrine specialist', 'Complex, multi-morbid'),

  -- Gastroenterology
  ('K22', 'Gastroenterology', 'high', 'Other diseases of esophagus need specialist care', 'Chronic conditions'),
  ('K26', 'Gastroenterology', 'high', 'Duodenal ulcer requires specialist management', 'Chronic conditions'),
  ('K71', 'Gastroenterology', 'high', 'Toxic liver disease needs specialist evaluation', 'Complex, multi-morbid'),

  -- Rheumatology
  ('M07', 'Rheumatology', 'high', 'Psoriatic arthropathies require specialist care', 'Chronic conditions'),
  ('M08', 'Rheumatology', 'high', 'Juvenile arthritis needs rheumatology management', 'Children and young people'),
  ('M30', 'Rheumatology', 'high', 'Polyarteritis nodosa requires specialist care', 'Complex, multi-morbid'),

  -- Nephrology
  ('N17', 'Nephrology', 'high', 'Acute kidney failure requires specialist care', 'Unplanned care'),
  ('N19', 'Nephrology', 'high', 'Unspecified kidney failure needs evaluation', 'Complex, multi-morbid'),
  ('N25', 'Nephrology', 'high', 'Disorders from impaired renal tubular function', 'Complex, multi-morbid'),

  -- Pediatric Specialties
  ('P27', 'Paediatric Medicine', 'high', 'Chronic respiratory disease originating in perinatal period', 'Children and young people'),
  ('P28', 'Paediatric Medicine', 'high', 'Other respiratory conditions of newborn', 'Children and young people'),
  ('P35', 'Paediatric Medicine', 'high', 'Congenital viral diseases need specialist care', 'Children and young people'),

  -- Obstetrics & Gynecology
  ('O14', 'Obstetrics & Gynaecology', 'high', 'Pre-eclampsia requires specialist management', 'Planned care'),
  ('O30', 'Obstetrics & Gynaecology', 'high', 'Multiple gestation needs specialist care', 'Planned care'),
  ('O31', 'Obstetrics & Gynaecology', 'high', 'Complications specific to multiple gestation', 'Complex, multi-morbid');

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
        AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
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