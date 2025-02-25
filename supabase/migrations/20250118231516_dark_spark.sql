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
  LIMIT 20
)
SELECT * FROM unmapped_analysis;

-- Add mappings for common unmapped codes
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Pediatric Specialties
  ('P00', 'Paediatric Medicine', 'high', 'Fetus and newborn affected by maternal conditions', 'Children and young people'),
  ('P01', 'Paediatric Medicine', 'high', 'Fetus and newborn affected by maternal complications', 'Children and young people'),
  ('P02', 'Paediatric Medicine', 'high', 'Fetus and newborn affected by complications', 'Children and young people'),
  ('P03', 'Paediatric Medicine', 'high', 'Fetus and newborn affected by other complications', 'Children and young people'),
  ('P04', 'Paediatric Medicine', 'high', 'Fetus and newborn affected by noxious influences', 'Children and young people'),
  
  -- Complex Care
  ('Z51', 'Complex condition / Frail elderly', 'high', 'Other medical care including palliative care', 'Complex, multi-morbid'),
  ('Z52', 'Complex condition / Frail elderly', 'high', 'Donors of organs and tissues', 'Complex, multi-morbid'),
  ('Z53', 'Complex condition / Frail elderly', 'high', 'Persons encountering health services for specific procedures', 'Complex, multi-morbid'),
  ('Z54', 'Complex condition / Frail elderly', 'high', 'Convalescence', 'Complex, multi-morbid'),
  ('Z55', 'Complex condition / Frail elderly', 'high', 'Problems related to education and literacy', 'Complex, multi-morbid'),
  
  -- Chronic Conditions
  ('Z82', 'Chronic conditions', 'high', 'Family history of certain disabilities and chronic diseases', 'Chronic conditions'),
  ('Z83', 'Chronic conditions', 'high', 'Family history of other specific disorders', 'Chronic conditions'),
  ('Z84', 'Chronic conditions', 'high', 'Family history of other conditions', 'Chronic conditions'),
  ('Z85', 'Chronic conditions', 'high', 'Personal history of malignant neoplasm', 'Chronic conditions'),
  ('Z86', 'Chronic conditions', 'high', 'Personal history of certain other diseases', 'Chronic conditions'),
  
  -- Planned Care
  ('Z40', 'Planned care', 'high', 'Prophylactic surgery', 'Planned care'),
  ('Z41', 'Planned care', 'high', 'Procedures for purposes other than remedying health state', 'Planned care'),
  ('Z42', 'Planned care', 'high', 'Follow-up care involving plastic surgery', 'Planned care'),
  ('Z43', 'Planned care', 'high', 'Attention to artificial openings', 'Planned care'),
  ('Z44', 'Planned care', 'high', 'Fitting and adjustment of external prosthetic devices', 'Planned care');

-- Update encounters with more aggressive matching logic
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
        
        -- If still no match, try matching just by system of care
        IF mapping_result IS NULL THEN
            SELECT 
                service, 
                confidence, 
                mapping_logic
            FROM specialty_care_center_services_mapping
            WHERE systems_of_care = r."system of care"
            ORDER BY confidence DESC
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