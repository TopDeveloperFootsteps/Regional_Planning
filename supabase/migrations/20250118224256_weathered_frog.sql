/*
  # Add Extended Care Facility Service Mappings

  1. New Mappings
    - Add comprehensive set of extended care service mappings
    - Focus on chronic conditions, elderly care, and rehabilitation
    - Cover multiple systems of care

  2. Process
    - Insert new extended care mappings
    - Update unmapped encounters
    - Show updated mapping statistics
*/

-- Add extended care facility service mappings
INSERT INTO extended_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Complex Elderly Care
  ('F01', 'Complex condition / Frail elderly', 'high', 'Vascular dementia requires comprehensive long-term care', 'Complex, multi-morbid'),
  ('F02', 'Complex condition / Frail elderly', 'high', 'Dementia in other diseases requires specialized care', 'Complex, multi-morbid'),
  ('F05', 'Complex condition / Frail elderly', 'high', 'Delirium requires careful monitoring and management', 'Complex, multi-morbid'),
  
  -- Rehabilitation Services
  ('Z50', 'Allied Health & Health Promotion', 'high', 'Care involving rehabilitation procedures', 'Complex, multi-morbid'),
  ('Z51', 'Complex condition / Frail elderly', 'high', 'Other medical care including palliative care', 'Palliative care and support'),
  ('Z54', 'Allied Health & Health Promotion', 'high', 'Convalescence and rehabilitation', 'Complex, multi-morbid'),
  
  -- Chronic Conditions
  ('I50', 'Complex condition / Frail elderly', 'high', 'Heart failure requires ongoing monitoring', 'Chronic conditions'),
  ('J44', 'Complex condition / Frail elderly', 'high', 'COPD requires long-term management', 'Chronic conditions'),
  ('E11', 'Complex condition / Frail elderly', 'high', 'Type 2 diabetes requires ongoing care', 'Chronic conditions'),
  
  -- Musculoskeletal Conditions
  ('M16', 'Allied Health & Health Promotion', 'high', 'Osteoarthritis of hip requires rehabilitation', 'Chronic conditions'),
  ('M17', 'Allied Health & Health Promotion', 'high', 'Osteoarthritis of knee needs physical therapy', 'Chronic conditions'),
  ('M80', 'Complex condition / Frail elderly', 'high', 'Osteoporosis with fracture needs comprehensive care', 'Complex, multi-morbid'),
  
  -- Post-Acute Care
  ('I63', 'Complex condition / Frail elderly', 'high', 'Cerebral infarction recovery requires rehabilitation', 'Complex, multi-morbid'),
  ('I69', 'Complex condition / Frail elderly', 'high', 'Sequelae of cerebrovascular disease needs ongoing care', 'Complex, multi-morbid'),
  ('S72', 'Allied Health & Health Promotion', 'high', 'Hip fracture recovery requires rehabilitation', 'Complex, multi-morbid'),
  
  -- Wound Care
  ('L89', 'Complex condition / Frail elderly', 'high', 'Pressure ulcer requires specialized wound care', 'Complex, multi-morbid'),
  ('L97', 'Complex condition / Frail elderly', 'high', 'Non-pressure chronic ulcer needs ongoing care', 'Complex, multi-morbid'),
  ('T81', 'Complex condition / Frail elderly', 'high', 'Complications of procedures need specialized care', 'Complex, multi-morbid'),
  
  -- Respiratory Care
  ('J96', 'Complex condition / Frail elderly', 'high', 'Respiratory failure requires ongoing support', 'Complex, multi-morbid'),
  ('J98', 'Complex condition / Frail elderly', 'high', 'Other respiratory disorders need specialized care', 'Complex, multi-morbid'),
  ('J15', 'Complex condition / Frail elderly', 'high', 'Bacterial pneumonia requires comprehensive care', 'Complex, multi-morbid'),
  
  -- Palliative Care
  ('Z51.5', 'Complex condition / Frail elderly', 'high', 'Palliative care services', 'Palliative care and support'),
  ('C00-C97', 'Complex condition / Frail elderly', 'high', 'Malignant neoplasms requiring palliative care', 'Palliative care and support'),
  ('G12', 'Complex condition / Frail elderly', 'high', 'Spinal muscular atrophy requiring supportive care', 'Palliative care and support'),
  
  -- Neurological Conditions
  ('G20', 'Complex condition / Frail elderly', 'high', 'Parkinsons disease requires ongoing care', 'Complex, multi-morbid'),
  ('G30', 'Complex condition / Frail elderly', 'high', 'Alzheimers disease needs comprehensive care', 'Complex, multi-morbid'),
  ('G35', 'Complex condition / Frail elderly', 'high', 'Multiple sclerosis requires specialized care', 'Complex, multi-morbid'),
  
  -- General Care
  ('R26', 'Allied Health & Health Promotion', 'high', 'Abnormalities of gait and mobility need therapy', 'Complex, multi-morbid'),
  ('R29', 'Allied Health & Health Promotion', 'high', 'Other symptoms involving nervous system need care', 'Complex, multi-morbid'),
  ('R41', 'Complex condition / Frail elderly', 'high', 'Cognitive function symptoms require monitoring', 'Complex, multi-morbid');

-- Map EXTENDED CARE FACILITY encounters
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    -- Loop through unmapped EXTENDED CARE FACILITY encounters
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'EXTENDED CARE FACILITY'
        AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
    LOOP
        -- Get mapping from extended_services_mapping
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM extended_services_mapping
        WHERE icd_code LIKE LEFT(r."icd family code", 3) || '%'
        AND systems_of_care = r."system of care"
        LIMIT 1
        INTO mapping_result;
        
        -- Update encounter if mapping found
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
    'EXTENDED CARE FACILITY' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'EXTENDED CARE FACILITY';