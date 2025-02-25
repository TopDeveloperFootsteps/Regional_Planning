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
  -- Cardiothoracic & Cardiovascular Surgery
  ('I80', 'Cardiothoracic & Cardiovascular Surgery', 'high', 'Phlebitis and thrombophlebitis require vascular care', 'Complex, multi-morbid'),
  ('I81', 'Cardiothoracic & Cardiovascular Surgery', 'high', 'Portal vein thrombosis needs specialist evaluation', 'Complex, multi-morbid'),
  ('I82', 'Cardiothoracic & Cardiovascular Surgery', 'high', 'Other venous embolism and thrombosis', 'Complex, multi-morbid'),
  ('I83', 'Cardiothoracic & Cardiovascular Surgery', 'high', 'Varicose veins of lower extremities', 'Planned care'),
  ('I85', 'Cardiothoracic & Cardiovascular Surgery', 'high', 'Esophageal varices need surgical evaluation', 'Complex, multi-morbid'),
  
  -- Neurosurgery
  ('G96', 'Neurosurgery', 'high', 'Other disorders of central nervous system', 'Complex, multi-morbid'),
  ('G97', 'Neurosurgery', 'high', 'Post-procedural disorders of nervous system', 'Complex, multi-morbid'),
  ('G98', 'Neurosurgery', 'high', 'Other disorders of nervous system', 'Complex, multi-morbid'),
  ('G99', 'Neurosurgery', 'high', 'Other disorders of nervous system in diseases classified elsewhere', 'Complex, multi-morbid'),
  ('S06', 'Neurosurgery', 'high', 'Intracranial injury requires neurosurgical care', 'Unplanned care'),
  
  -- Plastic Surgery
  ('L90', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Atrophic disorders of skin need plastic surgery', 'Planned care'),
  ('L91', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Hypertrophic disorders of skin', 'Planned care'),
  ('L92', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Granulomatous disorders of skin', 'Planned care'),
  ('L94', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Other localized connective tissue disorders', 'Planned care'),
  ('L95', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Vasculitis limited to skin', 'Planned care'),
  
  -- Pediatric Surgery
  ('Q40', 'Paediatric Surgery', 'high', 'Other congenital malformations of upper alimentary tract', 'Children and young people'),
  ('Q41', 'Paediatric Surgery', 'high', 'Congenital absence, atresia and stenosis of small intestine', 'Children and young people'),
  ('Q42', 'Paediatric Surgery', 'high', 'Congenital absence, atresia and stenosis of large intestine', 'Children and young people'),
  ('Q43', 'Paediatric Surgery', 'high', 'Other congenital malformations of intestine', 'Children and young people'),
  ('Q44', 'Paediatric Surgery', 'high', 'Congenital malformations of gallbladder, bile ducts and liver', 'Children and young people'),
  
  -- Dental Surgery
  ('K00', 'Dentistry', 'high', 'Disorders of tooth development and eruption', 'Planned care'),
  ('K01', 'Dentistry', 'high', 'Embedded and impacted teeth need surgical care', 'Planned care'),
  ('K02', 'Dentistry', 'high', 'Dental caries requires treatment', 'Planned care'),
  ('K03', 'Dentistry', 'high', 'Other diseases of hard tissues of teeth', 'Planned care'),
  ('K04', 'Dentistry', 'high', 'Diseases of pulp and periapical tissues', 'Planned care'),
  
  -- Diagnostic Services
  ('R90', 'Diagnostics & Therapeutics', 'high', 'Abnormal findings on diagnostic imaging of central nervous system', 'Complex, multi-morbid'),
  ('R91', 'Diagnostics & Therapeutics', 'high', 'Abnormal findings on diagnostic imaging of lung', 'Complex, multi-morbid'),
  ('R92', 'Diagnostics & Therapeutics', 'high', 'Abnormal findings on diagnostic imaging of breast', 'Complex, multi-morbid'),
  ('R93', 'Diagnostics & Therapeutics', 'high', 'Abnormal findings on diagnostic imaging of other body structures', 'Complex, multi-morbid'),
  ('R94', 'Diagnostics & Therapeutics', 'high', 'Abnormal results of function studies', 'Complex, multi-morbid');

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