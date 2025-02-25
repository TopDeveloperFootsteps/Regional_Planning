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

-- Add mappings for remaining common unmapped codes
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Pediatric Surgery
  ('Q35', 'Paediatric Surgery', 'high', 'Cleft palate requires pediatric surgical care', 'Children and young people'),
  ('Q36', 'Paediatric Surgery', 'high', 'Cleft lip needs surgical intervention', 'Children and young people'),
  ('Q37', 'Paediatric Surgery', 'high', 'Cleft palate with cleft lip requires surgery', 'Children and young people'),
  ('Q38', 'Paediatric Surgery', 'high', 'Other congenital malformations of tongue, mouth and pharynx', 'Children and young people'),
  ('Q39', 'Paediatric Surgery', 'high', 'Congenital malformations of esophagus need surgery', 'Children and young people'),
  
  -- Trauma and Emergency Medicine
  ('S00', 'Trauma and Emergency Medicine', 'high', 'Superficial injury of head needs urgent care', 'Unplanned care'),
  ('S01', 'Trauma and Emergency Medicine', 'high', 'Open wound of head requires emergency treatment', 'Unplanned care'),
  ('S02', 'Trauma and Emergency Medicine', 'high', 'Fracture of skull and facial bones needs urgent care', 'Unplanned care'),
  ('S03', 'Trauma and Emergency Medicine', 'high', 'Dislocation of joints of head requires treatment', 'Unplanned care'),
  ('S04', 'Trauma and Emergency Medicine', 'high', 'Injury of cranial nerves needs emergency care', 'Unplanned care'),
  
  -- Plastics and Burns
  ('T20', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Burn of head and neck requires specialist care', 'Unplanned care'),
  ('T21', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Burn of trunk needs burn unit care', 'Unplanned care'),
  ('T22', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Burn of upper limb requires specialist treatment', 'Unplanned care'),
  ('T23', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Burn of wrist and hand needs specialist care', 'Unplanned care'),
  ('T24', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Burn of lower limb requires burn unit treatment', 'Unplanned care'),
  
  -- Vascular Surgery
  ('I70', 'Vascular Surgery', 'high', 'Atherosclerosis requires vascular surgical care', 'Complex, multi-morbid'),
  ('I71', 'Vascular Surgery', 'high', 'Aortic aneurysm needs surgical evaluation', 'Complex, multi-morbid'),
  ('I72', 'Vascular Surgery', 'high', 'Other aneurysm requires vascular surgery', 'Complex, multi-morbid'),
  ('I73', 'Vascular Surgery', 'high', 'Other peripheral vascular diseases need care', 'Complex, multi-morbid'),
  ('I74', 'Vascular Surgery', 'high', 'Arterial embolism and thrombosis needs urgent care', 'Unplanned care'),
  
  -- Sexual & Reproductive Health
  ('N91', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Absent/rare/scanty menstruation needs care', 'Planned care'),
  ('N92', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Excessive/frequent menstruation requires treatment', 'Planned care'),
  ('N93', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Other abnormal uterine bleeding needs evaluation', 'Planned care'),
  ('N94', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Pain associated with female genital organs', 'Planned care'),
  ('N95', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 'high', 'Menopausal disorders require management', 'Planned care'),
  
  -- Hospice and Palliative Care
  ('Z51.5', 'Hospice and Palliative Care', 'high', 'Palliative care services', 'Palliative care and support'),
  ('Z51.1', 'Hospice and Palliative Care', 'high', 'Chemotherapy session for neoplasm', 'Palliative care and support'),
  ('Z51.8', 'Hospice and Palliative Care', 'high', 'Other specified medical care', 'Palliative care and support'),
  ('Z51.9', 'Hospice and Palliative Care', 'high', 'Medical care, unspecified', 'Palliative care and support'),
  ('Z54.0', 'Hospice and Palliative Care', 'high', 'Convalescence following surgery', 'Palliative care and support');

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