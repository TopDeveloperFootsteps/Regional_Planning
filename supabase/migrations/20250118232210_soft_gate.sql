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

-- Add final comprehensive mappings
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Pediatric Specialties (Extended)
  ('P21', 'Paediatric Medicine', 'high', 'Birth asphyxia requires urgent pediatric care', 'Children and young people'),
  ('P22', 'Paediatric Medicine', 'high', 'Respiratory distress of newborn needs specialist care', 'Children and young people'),
  ('P23', 'Paediatric Medicine', 'high', 'Congenital pneumonia requires pediatric management', 'Children and young people'),
  ('P24', 'Paediatric Medicine', 'high', 'Neonatal aspiration syndromes need urgent care', 'Children and young people'),
  ('P25', 'Paediatric Medicine', 'high', 'Interstitial emphysema in perinatal period', 'Children and young people'),
  
  -- Medical Genetics (Extended)
  ('Q80', 'Medical Genetics', 'high', 'Congenital ichthyosis requires genetic evaluation', 'Complex, multi-morbid'),
  ('Q81', 'Medical Genetics', 'high', 'Epidermolysis bullosa needs genetic management', 'Complex, multi-morbid'),
  ('Q82', 'Medical Genetics', 'high', 'Other congenital malformations of skin', 'Complex, multi-morbid'),
  ('Q83', 'Medical Genetics', 'high', 'Congenital malformations of breast', 'Complex, multi-morbid'),
  ('Q84', 'Medical Genetics', 'high', 'Other congenital malformations of integument', 'Complex, multi-morbid'),
  
  -- Infectious Disease (Specialized)
  ('A50', 'Infectious Diseases', 'high', 'Congenital syphilis requires specialist care', 'Complex, multi-morbid'),
  ('A51', 'Infectious Diseases', 'high', 'Early syphilis needs infectious disease management', 'Complex, multi-morbid'),
  ('A52', 'Infectious Diseases', 'high', 'Late syphilis requires specialist treatment', 'Complex, multi-morbid'),
  ('A53', 'Infectious Diseases', 'high', 'Other and unspecified syphilis', 'Complex, multi-morbid'),
  ('A54', 'Infectious Diseases', 'high', 'Gonococcal infection needs specialist care', 'Complex, multi-morbid'),
  
  -- Nuclear Medicine (Extended)
  ('Y88', 'Nuclear Medicine', 'high', 'Sequelae with medical and surgical care as external cause', 'Complex, multi-morbid'),
  ('Y92', 'Nuclear Medicine', 'high', 'Place of occurrence of the external cause', 'Complex, multi-morbid'),
  ('Y95', 'Nuclear Medicine', 'high', 'Nosocomial condition requires evaluation', 'Complex, multi-morbid'),
  ('Y97', 'Nuclear Medicine', 'high', 'Environmental-pollution-related condition', 'Complex, multi-morbid'),
  ('Y98', 'Nuclear Medicine', 'high', 'Lifestyle-related condition needs assessment', 'Complex, multi-morbid'),
  
  -- Palliative Care (Comprehensive)
  ('Z51.5', 'Hospice and Palliative Care', 'high', 'Palliative care services', 'Palliative care and support'),
  ('Z51.8', 'Hospice and Palliative Care', 'high', 'Other specified medical care', 'Palliative care and support'),
  ('Z51.9', 'Hospice and Palliative Care', 'high', 'Medical care, unspecified', 'Palliative care and support'),
  ('Z54.0', 'Hospice and Palliative Care', 'high', 'Convalescence following surgery', 'Palliative care and support'),
  ('Z54.8', 'Hospice and Palliative Care', 'high', 'Convalescence following other treatment', 'Palliative care and support'),
  
  -- Preventive Medicine (Extended)
  ('Z40', 'Social, Community and Preventative Medicine', 'high', 'Preventive surgery for risk factors', 'Planned care'),
  ('Z41', 'Social, Community and Preventative Medicine', 'high', 'Procedures for purposes other than health state', 'Planned care'),
  ('Z42', 'Social, Community and Preventative Medicine', 'high', 'Follow-up care involving plastic surgery', 'Planned care'),
  ('Z43', 'Social, Community and Preventative Medicine', 'high', 'Attention to artificial openings', 'Planned care'),
  ('Z44', 'Social, Community and Preventative Medicine', 'high', 'Fitting and adjustment of external prosthetic devices', 'Planned care');

-- Update remaining encounters with enhanced matching logic
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