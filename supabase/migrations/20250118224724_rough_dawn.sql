/*
  # Add Additional Specialty Care Service Mappings

  1. New Mappings
    - Add comprehensive specialty care service mappings
    - Focus on specialized medical services
    - Cover multiple systems of care

  2. Process
    - Insert new specialty care mappings
    - Update unmapped encounters
*/

-- Add specialty care service mappings
INSERT INTO specialty_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Pediatric Specialties
  ('P07', 'Paediatric Medicine', 'high', 'Disorders related to short gestation require specialized pediatric care', 'Children and young people'),
  ('P22', 'Paediatric Medicine', 'high', 'Respiratory distress of newborn needs specialist care', 'Children and young people'),
  ('P29', 'Paediatric Medicine', 'high', 'Cardiovascular disorders originating in the perinatal period', 'Children and young people'),
  
  -- Obstetrics & Gynecology
  ('O24', 'Obstetrics & Gynaecology', 'high', 'Diabetes mellitus in pregnancy requires specialist care', 'Planned care'),
  ('O36', 'Obstetrics & Gynaecology', 'high', 'Maternal care for other fetal problems', 'Planned care'),
  ('O42', 'Obstetrics & Gynaecology', 'high', 'Premature rupture of membranes needs specialist care', 'Unplanned care'),
  
  -- Psychiatry
  ('F31', 'Psychiatry', 'high', 'Bipolar disorder requires specialist psychiatric care', 'Complex, multi-morbid'),
  ('F41', 'Psychiatry', 'high', 'Other anxiety disorders need specialist management', 'Chronic conditions'),
  ('F60', 'Psychiatry', 'high', 'Specific personality disorders require psychiatric care', 'Complex, multi-morbid'),
  
  -- Nuclear Medicine
  ('C73', 'Nuclear Medicine', 'high', 'Thyroid cancer requires nuclear medicine procedures', 'Complex, multi-morbid'),
  ('E05', 'Nuclear Medicine', 'high', 'Thyrotoxicosis needs nuclear medicine evaluation', 'Chronic conditions'),
  ('M86', 'Nuclear Medicine', 'high', 'Osteomyelitis requires nuclear medicine imaging', 'Complex, multi-morbid'),
  
  -- Medical Genetics
  ('Q90', 'Medical Genetics', 'high', 'Down syndrome requires genetic specialist care', 'Complex, multi-morbid'),
  ('Q96', 'Medical Genetics', 'high', 'Turner syndrome needs genetic management', 'Complex, multi-morbid'),
  ('E70', 'Medical Genetics', 'high', 'Disorders of aromatic amino-acid metabolism', 'Complex, multi-morbid'),
  
  -- Sexual & Reproductive Health
  ('N91', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Absent/rare/scanty menstruation needs specialist care', 'Planned care'),
  ('N94', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Pain associated with female genital organs', 'Planned care'),
  ('N97', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Female infertility requires specialist evaluation', 'Planned care'),
  
  -- Hospice and Palliative Care
  ('Z51.5', 'Hospice and Palliative Care', 'high', 'Palliative care for terminal conditions', 'Palliative care and support'),
  ('C78', 'Hospice and Palliative Care', 'high', 'Secondary malignant neoplasm requiring palliative care', 'Palliative care and support'),
  ('C79', 'Hospice and Palliative Care', 'high', 'Secondary malignant neoplasm of other sites', 'Palliative care and support'),
  
  -- Social, Community and Preventative Medicine
  ('Z71', 'Social, Community and Preventative Medicine', 'high', 'Persons encountering health services for counseling', 'Planned care'),
  ('Z73', 'Social, Community and Preventative Medicine', 'high', 'Problems related to life-management difficulty', 'Planned care'),
  ('Z60', 'Social, Community and Preventative Medicine', 'high', 'Problems related to social environment', 'Planned care');

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