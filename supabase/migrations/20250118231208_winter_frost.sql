-- Add mappings for next batch of unmapped codes
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Allergy and Immunology
  ('J30', 'Allergy and Immunology', 'high', 'Vasomotor and allergic rhinitis requires specialist care', 'Chronic conditions'),
  ('J45', 'Allergy and Immunology', 'high', 'Asthma needs immunology management', 'Chronic conditions'),
  ('L20', 'Allergy and Immunology', 'high', 'Atopic dermatitis requires immunology care', 'Chronic conditions'),
  ('T78', 'Allergy and Immunology', 'high', 'Adverse effects and allergic reactions need specialist care', 'Unplanned care'),
  ('D80', 'Allergy and Immunology', 'high', 'Immunodeficiency requires specialist management', 'Complex, multi-morbid'),

  -- Medical Genetics
  ('Q90', 'Medical Genetics', 'high', 'Down syndrome requires genetic specialist care', 'Complex, multi-morbid'),
  ('Q91', 'Medical Genetics', 'high', 'Edwards and Patau syndromes need genetic management', 'Complex, multi-morbid'),
  ('Q92', 'Medical Genetics', 'high', 'Other trisomies requires genetic evaluation', 'Complex, multi-morbid'),
  ('Q93', 'Medical Genetics', 'high', 'Monosomies and deletions need genetic care', 'Complex, multi-morbid'),
  ('Q95', 'Medical Genetics', 'high', 'Balanced rearrangements requires genetic specialist', 'Complex, multi-morbid'),

  -- Nuclear Medicine
  ('C73', 'Nuclear Medicine', 'high', 'Thyroid cancer requires nuclear medicine procedures', 'Complex, multi-morbid'),
  ('C74', 'Nuclear Medicine', 'high', 'Adrenal gland malignancy needs nuclear medicine', 'Complex, multi-morbid'),
  ('C75', 'Nuclear Medicine', 'high', 'Other endocrine glands cancer requires evaluation', 'Complex, multi-morbid'),
  ('E05', 'Nuclear Medicine', 'high', 'Thyrotoxicosis needs nuclear medicine assessment', 'Chronic conditions'),
  ('M89', 'Nuclear Medicine', 'high', 'Bone disorders require nuclear medicine imaging', 'Complex, multi-morbid'),

  -- Physical Medicine and Rehabilitation
  ('M40', 'Physical Medicine and Rehabilitation', 'high', 'Kyphosis and lordosis need rehabilitation', 'Chronic conditions'),
  ('M41', 'Physical Medicine and Rehabilitation', 'high', 'Scoliosis requires physical medicine care', 'Chronic conditions'),
  ('M42', 'Physical Medicine and Rehabilitation', 'high', 'Spinal osteochondrosis needs rehabilitation', 'Chronic conditions'),
  ('M43', 'Physical Medicine and Rehabilitation', 'high', 'Other deforming dorsopathies require care', 'Chronic conditions'),
  ('M50', 'Physical Medicine and Rehabilitation', 'high', 'Cervical disc disorders need rehabilitation', 'Chronic conditions'),

  -- Anesthesiology
  ('G89', 'Anesthesiology', 'high', 'Pain disorders require anesthesiology care', 'Chronic conditions'),
  ('R52', 'Anesthesiology', 'high', 'Pain needs anesthesiology management', 'Chronic conditions'),
  ('T88.2', 'Anesthesiology', 'high', 'Shock due to anesthesia requires specialist care', 'Unplanned care'),
  ('T88.3', 'Anesthesiology', 'high', 'Malignant hyperthermia due to anesthesia', 'Unplanned care'),
  ('T88.5', 'Anesthesiology', 'high', 'Other complications of anesthesia', 'Unplanned care'),

  -- Critical Care Medicine
  ('R57', 'Critical Care Medicine', 'high', 'Shock requires intensive care management', 'Unplanned care'),
  ('R58', 'Critical Care Medicine', 'high', 'Hemorrhage requires critical care', 'Unplanned care'),
  ('R65', 'Critical Care Medicine', 'high', 'Inflammatory response syndrome needs intensive care', 'Unplanned care'),
  ('J96', 'Critical Care Medicine', 'high', 'Respiratory failure requires critical care', 'Unplanned care'),
  ('K72', 'Critical Care Medicine', 'high', 'Hepatic failure needs intensive care', 'Unplanned care'),

  -- Social, Community and Preventative Medicine
  ('Z71', 'Social, Community and Preventative Medicine', 'high', 'Persons seeking health counseling', 'Planned care'),
  ('Z72', 'Social, Community and Preventative Medicine', 'high', 'Problems related to lifestyle need intervention', 'Planned care'),
  ('Z73', 'Social, Community and Preventative Medicine', 'high', 'Problems related to life management difficulty', 'Planned care'),
  ('Z75', 'Social, Community and Preventative Medicine', 'high', 'Problems related to medical facilities', 'Planned care'),
  ('Z76', 'Social, Community and Preventative Medicine', 'high', 'Persons encountering health services', 'Planned care');

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