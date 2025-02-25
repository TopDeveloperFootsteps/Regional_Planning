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
  -- Oncology Services
  ('C15', 'Oncology', 'high', 'Malignant neoplasm of esophagus requires oncology care', 'Complex, multi-morbid'),
  ('C16', 'Oncology', 'high', 'Malignant neoplasm of stomach needs specialist care', 'Complex, multi-morbid'),
  ('C17', 'Oncology', 'high', 'Malignant neoplasm of small intestine', 'Complex, multi-morbid'),
  ('C18', 'Oncology', 'high', 'Malignant neoplasm of colon requires treatment', 'Complex, multi-morbid'),
  ('C19', 'Oncology', 'high', 'Malignant neoplasm of rectosigmoid junction', 'Complex, multi-morbid'),
  
  -- Hematology Services
  ('D60', 'Haematology', 'high', 'Acquired pure red cell aplasia requires specialist care', 'Complex, multi-morbid'),
  ('D61', 'Haematology', 'high', 'Other aplastic anemias need hematology management', 'Complex, multi-morbid'),
  ('D62', 'Haematology', 'high', 'Acute posthemorrhagic anemia requires treatment', 'Unplanned care'),
  ('D63', 'Haematology', 'high', 'Anemia in chronic diseases needs evaluation', 'Complex, multi-morbid'),
  ('D64', 'Haematology', 'high', 'Other anemias require specialist care', 'Complex, multi-morbid'),
  
  -- Rheumatology Services
  ('M30', 'Rheumatology', 'high', 'Polyarteritis nodosa requires rheumatology care', 'Complex, multi-morbid'),
  ('M31', 'Rheumatology', 'high', 'Other necrotizing vasculopathies need treatment', 'Complex, multi-morbid'),
  ('M32', 'Rheumatology', 'high', 'Systemic lupus erythematosus requires management', 'Complex, multi-morbid'),
  ('M33', 'Rheumatology', 'high', 'Dermatopolymyositis needs specialist care', 'Complex, multi-morbid'),
  ('M34', 'Rheumatology', 'high', 'Systemic sclerosis requires evaluation', 'Complex, multi-morbid'),
  
  -- Neurology Services
  ('G60', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Hereditary and idiopathic neuropathy needs care', 'Complex, multi-morbid'),
  ('G61', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Inflammatory polyneuropathy requires treatment', 'Complex, multi-morbid'),
  ('G62', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Other polyneuropathies need evaluation', 'Complex, multi-morbid'),
  ('G63', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Polyneuropathy in diseases classified elsewhere', 'Complex, multi-morbid'),
  ('G64', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Other disorders of peripheral nervous system', 'Complex, multi-morbid'),
  
  -- Endocrinology Services
  ('E20', 'Endocrinology', 'high', 'Hypoparathyroidism requires endocrine care', 'Chronic conditions'),
  ('E21', 'Endocrinology', 'high', 'Hyperparathyroidism needs specialist management', 'Chronic conditions'),
  ('E22', 'Endocrinology', 'high', 'Hyperfunction of pituitary gland requires care', 'Complex, multi-morbid'),
  ('E23', 'Endocrinology', 'high', 'Hypofunction of pituitary gland needs treatment', 'Complex, multi-morbid'),
  ('E24', 'Endocrinology', 'high', 'Cushings syndrome requires specialist evaluation', 'Complex, multi-morbid'),
  
  -- Gastroenterology Services
  ('K55', 'Gastroenterology', 'high', 'Vascular disorders of intestine need specialist care', 'Complex, multi-morbid'),
  ('K56', 'Gastroenterology', 'high', 'Paralytic ileus and intestinal obstruction', 'Unplanned care'),
  ('K57', 'Gastroenterology', 'high', 'Diverticular disease requires evaluation', 'Chronic conditions'),
  ('K58', 'Gastroenterology', 'high', 'Irritable bowel syndrome needs management', 'Chronic conditions'),
  ('K59', 'Gastroenterology', 'high', 'Other functional intestinal disorders', 'Chronic conditions');

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
        LIMIT 1000
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