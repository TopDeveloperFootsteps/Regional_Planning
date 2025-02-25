-- First: Get current unmapped codes statistics
WITH unmapped_stats AS (
  SELECT 
    "system of care",
    LEFT("icd family code", 1) as icd_category,
    COUNT(*) as count
  FROM encounters
  WHERE "care setting" = 'SPECIALTY CARE CENTER'
  AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
  GROUP BY "system of care", LEFT("icd family code", 1)
  ORDER BY COUNT(*) DESC
)
SELECT * FROM unmapped_stats;

-- Add more detailed specialty mappings
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Diagnostic Services
  ('R90', 'Diagnostics & Therapeutics', 'high', 'Abnormal findings on diagnostic imaging of central nervous system', 'Complex, multi-morbid'),
  ('R91', 'Diagnostics & Therapeutics', 'high', 'Abnormal findings on diagnostic imaging of lung', 'Complex, multi-morbid'),
  ('R93', 'Diagnostics & Therapeutics', 'high', 'Abnormal findings on diagnostic imaging of other body structures', 'Complex, multi-morbid'),
  
  -- Surgical Specialties
  ('S00', 'General Surgery', 'high', 'Superficial injury of head needs surgical evaluation', 'Unplanned care'),
  ('S01', 'General Surgery', 'high', 'Open wound of head requires surgical care', 'Unplanned care'),
  ('S06', 'Neurosurgery', 'high', 'Intracranial injury needs neurosurgical evaluation', 'Unplanned care'),
  
  -- Medical Specialties
  ('I20', 'Cardiology', 'high', 'Angina pectoris requires cardiology care', 'Chronic conditions'),
  ('J45', 'Pulmonology / Respiratory Medicine', 'high', 'Asthma needs pulmonology management', 'Chronic conditions'),
  ('K21', 'Gastroenterology', 'high', 'Gastro-esophageal reflux disease requires gastroenterology care', 'Chronic conditions'),
  
  -- Complex Care
  ('F20', 'Psychiatry', 'high', 'Schizophrenia requires psychiatric management', 'Complex, multi-morbid'),
  ('G35', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Multiple sclerosis needs neurological care', 'Complex, multi-morbid'),
  ('M05', 'Rheumatology', 'high', 'Rheumatoid arthritis requires rheumatology management', 'Complex, multi-morbid');

-- Update remaining unmapped encounters
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
        -- Try exact match first
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_care_center_services_mapping
        WHERE icd_code LIKE LEFT(r."icd family code", 3) || '%'
        AND systems_of_care = r."system of care"
        LIMIT 1
        INTO mapping_result;
        
        -- If no exact match, try category match
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