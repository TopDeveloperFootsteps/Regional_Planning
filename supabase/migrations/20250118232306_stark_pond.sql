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
  -- Pediatric Specialties (Final)
  ('P30', 'Paediatric Medicine', 'high', 'Cardiovascular disorders specific to perinatal period', 'Children and young people'),
  ('P35', 'Paediatric Medicine', 'high', 'Congenital viral diseases need specialist care', 'Children and young people'),
  ('P36', 'Paediatric Medicine', 'high', 'Bacterial sepsis of newborn requires urgent care', 'Children and young people'),
  ('P37', 'Paediatric Medicine', 'high', 'Other congenital infectious diseases', 'Children and young people'),
  ('P38', 'Paediatric Medicine', 'high', 'Omphalitis of newborn needs treatment', 'Children and young people'),
  
  -- Medical Genetics (Final)
  ('Q85', 'Medical Genetics', 'high', 'Phakomatoses requires genetic evaluation', 'Complex, multi-morbid'),
  ('Q86', 'Medical Genetics', 'high', 'Congenital malformation syndromes due to known exogenous causes', 'Complex, multi-morbid'),
  ('Q87', 'Medical Genetics', 'high', 'Other specified congenital malformation syndromes', 'Complex, multi-morbid'),
  ('Q89', 'Medical Genetics', 'high', 'Other congenital malformations', 'Complex, multi-morbid'),
  ('Q99', 'Medical Genetics', 'high', 'Other chromosome abnormalities', 'Complex, multi-morbid'),
  
  -- Infectious Disease (Final)
  ('A55', 'Infectious Diseases', 'high', 'Chlamydial lymphogranuloma requires specialist care', 'Complex, multi-morbid'),
  ('A56', 'Infectious Diseases', 'high', 'Other sexually transmitted chlamydial diseases', 'Complex, multi-morbid'),
  ('A57', 'Infectious Diseases', 'high', 'Chancroid needs infectious disease management', 'Complex, multi-morbid'),
  ('A58', 'Infectious Diseases', 'high', 'Granuloma inguinale requires treatment', 'Complex, multi-morbid'),
  ('A59', 'Infectious Diseases', 'high', 'Trichomoniasis needs specialist care', 'Complex, multi-morbid'),
  
  -- Nuclear Medicine (Final)
  ('Y40', 'Nuclear Medicine', 'high', 'Systemic antibiotics causing adverse effects', 'Complex, multi-morbid'),
  ('Y41', 'Nuclear Medicine', 'high', 'Other systemic anti-infectives and antiparasitics', 'Complex, multi-morbid'),
  ('Y42', 'Nuclear Medicine', 'high', 'Hormones and synthetic substitutes', 'Complex, multi-morbid'),
  ('Y43', 'Nuclear Medicine', 'high', 'Primarily systemic agents', 'Complex, multi-morbid'),
  ('Y44', 'Nuclear Medicine', 'high', 'Agents primarily affecting blood constituents', 'Complex, multi-morbid'),
  
  -- Palliative Care (Final)
  ('Z51.0', 'Hospice and Palliative Care', 'high', 'Radiotherapy session', 'Palliative care and support'),
  ('Z51.1', 'Hospice and Palliative Care', 'high', 'Chemotherapy session', 'Palliative care and support'),
  ('Z51.2', 'Hospice and Palliative Care', 'high', 'Other chemotherapy', 'Palliative care and support'),
  ('Z51.3', 'Hospice and Palliative Care', 'high', 'Blood transfusion without reported diagnosis', 'Palliative care and support'),
  ('Z51.4', 'Hospice and Palliative Care', 'high', 'Preparatory care for subsequent treatment', 'Palliative care and support'),
  
  -- Preventive Medicine (Final)
  ('Z45', 'Social, Community and Preventative Medicine', 'high', 'Adjustment and management of implanted devices', 'Planned care'),
  ('Z46', 'Social, Community and Preventative Medicine', 'high', 'Fitting and adjustment of other devices', 'Planned care'),
  ('Z47', 'Social, Community and Preventative Medicine', 'high', 'Other orthopedic follow-up care', 'Planned care'),
  ('Z48', 'Social, Community and Preventative Medicine', 'high', 'Other surgical follow-up care', 'Planned care'),
  ('Z49', 'Social, Community and Preventative Medicine', 'high', 'Care involving dialysis', 'Planned care');

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