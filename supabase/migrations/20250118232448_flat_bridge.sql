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

-- Add final comprehensive mappings for remaining codes
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Pediatric Medicine (Final Batch)
  ('P70', 'Paediatric Medicine', 'high', 'Transitory disorders of carbohydrate metabolism specific to newborn', 'Children and young people'),
  ('P71', 'Paediatric Medicine', 'high', 'Transitory neonatal disorders of calcium and magnesium metabolism', 'Children and young people'),
  ('P72', 'Paediatric Medicine', 'high', 'Other transitory neonatal endocrine disorders', 'Children and young people'),
  ('P74', 'Paediatric Medicine', 'high', 'Other transitory neonatal electrolyte and metabolic disturbances', 'Children and young people'),
  ('P75', 'Paediatric Medicine', 'high', 'Meconium ileus in cystic fibrosis', 'Children and young people'),
  
  -- Complex Care (Final Batch)
  ('F80', 'Complex condition / Frail elderly', 'high', 'Specific developmental disorders of speech and language', 'Complex, multi-morbid'),
  ('F81', 'Complex condition / Frail elderly', 'high', 'Specific developmental disorders of scholastic skills', 'Complex, multi-morbid'),
  ('F82', 'Complex condition / Frail elderly', 'high', 'Specific developmental disorder of motor function', 'Complex, multi-morbid'),
  ('F83', 'Complex condition / Frail elderly', 'high', 'Mixed specific developmental disorders', 'Complex, multi-morbid'),
  ('F84', 'Complex condition / Frail elderly', 'high', 'Pervasive developmental disorders', 'Complex, multi-morbid'),
  
  -- Chronic Conditions (Final Batch)
  ('E85', 'Endocrinology', 'high', 'Amyloidosis requires ongoing specialist care', 'Chronic conditions'),
  ('E86', 'Endocrinology', 'high', 'Volume depletion needs endocrine management', 'Chronic conditions'),
  ('E87', 'Endocrinology', 'high', 'Other disorders of fluid, electrolyte and acid-base balance', 'Chronic conditions'),
  ('E88', 'Endocrinology', 'high', 'Other metabolic disorders require specialist care', 'Chronic conditions'),
  ('E89', 'Endocrinology', 'high', 'Postprocedural endocrine and metabolic complications', 'Chronic conditions'),
  
  -- Unplanned Care (Final Batch)
  ('R10', 'General Surgery', 'high', 'Abdominal and pelvic pain requires urgent evaluation', 'Unplanned care'),
  ('R11', 'Gastroenterology', 'high', 'Nausea and vomiting need assessment', 'Unplanned care'),
  ('R12', 'Gastroenterology', 'high', 'Heartburn requires evaluation', 'Unplanned care'),
  ('R13', 'Gastroenterology', 'high', 'Dysphagia needs urgent care', 'Unplanned care'),
  ('R14', 'Gastroenterology', 'high', 'Flatulence and related conditions', 'Unplanned care'),
  
  -- Planned Care (Final Batch)
  ('Z60', 'Social, Community and Preventative Medicine', 'high', 'Problems related to social environment', 'Planned care'),
  ('Z61', 'Social, Community and Preventative Medicine', 'high', 'Problems related to negative life events in childhood', 'Planned care'),
  ('Z62', 'Social, Community and Preventative Medicine', 'high', 'Other problems related to upbringing', 'Planned care'),
  ('Z63', 'Social, Community and Preventative Medicine', 'high', 'Other problems related to primary support group', 'Planned care'),
  ('Z64', 'Social, Community and Preventative Medicine', 'high', 'Problems related to certain psychosocial circumstances', 'Planned care'),
  
  -- Palliative Care (Final Batch)
  ('Z74', 'Hospice and Palliative Care', 'high', 'Problems related to care-provider dependency', 'Palliative care and support'),
  ('Z75', 'Hospice and Palliative Care', 'high', 'Problems related to medical facilities and other health care', 'Palliative care and support'),
  ('Z76', 'Hospice and Palliative Care', 'high', 'Persons encountering health services in other circumstances', 'Palliative care and support'),
  ('Z77', 'Hospice and Palliative Care', 'high', 'Other contact with health services', 'Palliative care and support'),
  ('Z78', 'Hospice and Palliative Care', 'high', 'Other specified health status', 'Palliative care and support');

-- Update remaining encounters with final enhanced matching logic
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

-- Show final mapping statistics
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