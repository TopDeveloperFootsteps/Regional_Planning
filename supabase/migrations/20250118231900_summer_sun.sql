-- First: Analyze remaining unmapped encounters
WITH unmapped_analysis AS (
  SELECT 
    "system of care",
    LEFT("icd family code", 3) as icd_prefix,
    COUNT(*) as count
  FROM encounters
  WHERE "care setting" = 'SPECIALTY CARE CENTER'
  AND service IS NULL
  GROUP BY "system of care", LEFT("icd family code", 3)
  ORDER BY count DESC
  LIMIT 50
)
SELECT * FROM unmapped_analysis;

-- Add comprehensive mappings for remaining common unmapped codes
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Pediatric Medicine (Extended)
  ('P05', 'Paediatric Medicine', 'high', 'Slow fetal growth and malnutrition needs pediatric care', 'Children and young people'),
  ('P07', 'Paediatric Medicine', 'high', 'Disorders related to short gestation require specialist care', 'Children and young people'),
  ('P08', 'Paediatric Medicine', 'high', 'Disorders related to long gestation and high birth weight', 'Children and young people'),
  ('P10', 'Paediatric Medicine', 'high', 'Intracranial laceration and hemorrhage due to birth injury', 'Children and young people'),
  ('P11', 'Paediatric Medicine', 'high', 'Other birth injuries to central nervous system', 'Children and young people'),
  ('P12', 'Paediatric Medicine', 'high', 'Birth injury to scalp needs pediatric evaluation', 'Children and young people'),
  ('P13', 'Paediatric Medicine', 'high', 'Birth injury to skeleton requires specialist care', 'Children and young people'),
  ('P14', 'Paediatric Medicine', 'high', 'Birth injury to peripheral nervous system', 'Children and young people'),
  ('P15', 'Paediatric Medicine', 'high', 'Other birth injuries need pediatric management', 'Children and young people'),
  ('P20', 'Paediatric Medicine', 'high', 'Intrauterine hypoxia requires urgent care', 'Children and young people'),
  
  -- Complex Multi-morbid Care
  ('F70', 'Complex condition / Frail elderly', 'high', 'Mild intellectual disabilities need comprehensive care', 'Complex, multi-morbid'),
  ('F71', 'Complex condition / Frail elderly', 'high', 'Moderate intellectual disabilities require support', 'Complex, multi-morbid'),
  ('F72', 'Complex condition / Frail elderly', 'high', 'Severe intellectual disabilities need specialist care', 'Complex, multi-morbid'),
  ('F73', 'Complex condition / Frail elderly', 'high', 'Profound intellectual disabilities require management', 'Complex, multi-morbid'),
  ('F78', 'Complex condition / Frail elderly', 'high', 'Other intellectual disabilities need evaluation', 'Complex, multi-morbid'),
  ('F79', 'Complex condition / Frail elderly', 'high', 'Unspecified intellectual disabilities require assessment', 'Complex, multi-morbid'),
  ('F80', 'Complex condition / Frail elderly', 'high', 'Specific developmental disorders of speech and language', 'Complex, multi-morbid'),
  ('F81', 'Complex condition / Frail elderly', 'high', 'Specific developmental disorders of scholastic skills', 'Complex, multi-morbid'),
  ('F82', 'Complex condition / Frail elderly', 'high', 'Specific developmental disorder of motor function', 'Complex, multi-morbid'),
  ('F84', 'Complex condition / Frail elderly', 'high', 'Pervasive developmental disorders need specialist care', 'Complex, multi-morbid'),
  
  -- Chronic Conditions Management
  ('E66', 'Endocrinology', 'high', 'Obesity requires specialist management', 'Chronic conditions'),
  ('E67', 'Endocrinology', 'high', 'Other hyperalimentation needs evaluation', 'Chronic conditions'),
  ('E68', 'Endocrinology', 'high', 'Sequelae of hyperalimentation require care', 'Chronic conditions'),
  ('E70', 'Endocrinology', 'high', 'Disorders of aromatic amino-acid metabolism', 'Chronic conditions'),
  ('E71', 'Endocrinology', 'high', 'Disorders of branched-chain amino-acid metabolism', 'Chronic conditions'),
  ('E72', 'Endocrinology', 'high', 'Other disorders of amino-acid metabolism', 'Chronic conditions'),
  ('E73', 'Endocrinology', 'high', 'Lactose intolerance needs management', 'Chronic conditions'),
  ('E74', 'Endocrinology', 'high', 'Other disorders of carbohydrate metabolism', 'Chronic conditions'),
  ('E75', 'Endocrinology', 'high', 'Disorders of sphingolipid metabolism', 'Chronic conditions'),
  ('E76', 'Endocrinology', 'high', 'Disorders of glycosaminoglycan metabolism', 'Chronic conditions'),
  
  -- Unplanned Care
  ('R00', 'Cardiology', 'high', 'Abnormalities of heart beat need urgent evaluation', 'Unplanned care'),
  ('R01', 'Cardiology', 'high', 'Cardiac murmurs and other cardiac sounds', 'Unplanned care'),
  ('R02', 'Vascular Surgery', 'high', 'Gangrene requires urgent surgical care', 'Unplanned care'),
  ('R03', 'Cardiology', 'high', 'Abnormal blood pressure reading needs assessment', 'Unplanned care'),
  ('R04', 'Otolaryngology / ENT', 'high', 'Hemorrhage from respiratory passages needs urgent care', 'Unplanned care'),
  ('R05', 'Pulmonology / Respiratory Medicine', 'high', 'Cough requires evaluation', 'Unplanned care'),
  ('R06', 'Pulmonology / Respiratory Medicine', 'high', 'Abnormalities of breathing need assessment', 'Unplanned care'),
  ('R07', 'Cardiology', 'high', 'Pain in throat and chest requires urgent evaluation', 'Unplanned care'),
  ('R09', 'Pulmonology / Respiratory Medicine', 'high', 'Other symptoms involving circulatory and respiratory systems', 'Unplanned care'),
  ('R10', 'General Surgery', 'high', 'Abdominal and pelvic pain needs urgent assessment', 'Unplanned care'),
  
  -- Planned Care Services
  ('Z30', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Contraceptive management', 'Planned care'),
  ('Z31', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Procreative management', 'Planned care'),
  ('Z32', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Pregnancy examination and test', 'Planned care'),
  ('Z33', 'Obstetrics & Gynaecology', 'high', 'Pregnant state needs routine monitoring', 'Planned care'),
  ('Z34', 'Obstetrics & Gynaecology', 'high', 'Supervision of normal pregnancy', 'Planned care'),
  ('Z35', 'Obstetrics & Gynaecology', 'high', 'Supervision of high-risk pregnancy', 'Planned care'),
  ('Z36', 'Obstetrics & Gynaecology', 'high', 'Antenatal screening', 'Planned care'),
  ('Z37', 'Obstetrics & Gynaecology', 'high', 'Outcome of delivery requires documentation', 'Planned care'),
  ('Z38', 'Paediatric Medicine', 'high', 'Liveborn infants according to place of birth', 'Planned care'),
  ('Z39', 'Obstetrics & Gynaecology', 'high', 'Postpartum care and examination', 'Planned care');

-- Update encounters with enhanced matching logic
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
        LIMIT 1000  -- Increased batch size
    LOOP
        -- Try exact 3-character match first
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_care_center_services_mapping
        WHERE icd_code = LEFT(r."icd family code", 3)
        AND systems_of_care = r."system of care"
        LIMIT 1
        INTO mapping_result;
        
        -- If no match, try first character match
        IF mapping_result IS NULL THEN
            SELECT 
                service, 
                confidence, 
                mapping_logic
            FROM specialty_care_center_services_mapping
            WHERE icd_code = LEFT(r."icd family code", 1)
            AND systems_of_care = r."system of care"
            LIMIT 1
            INTO mapping_result;
        END IF;
        
        -- If still no match, try matching just by system of care with high confidence
        IF mapping_result IS NULL THEN
            SELECT 
                service, 
                confidence, 
                mapping_logic
            FROM specialty_care_center_services_mapping
            WHERE systems_of_care = r."system of care"
            AND confidence = 'high'
            ORDER BY created_at DESC
            LIMIT 1
            INTO mapping_result;
        END IF;
        
        -- Update if mapping found
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
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage,
    COUNT(*) FILTER (WHERE confidence = 'high') as high_confidence_count,
    COUNT(*) FILTER (WHERE confidence = 'medium') as medium_confidence_count,
    COUNT(*) FILTER (WHERE confidence = 'low') as low_confidence_count
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';