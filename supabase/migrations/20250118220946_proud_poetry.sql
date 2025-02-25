/*
  # Add More Service Mappings for Care Settings

  1. New Mappings
    - Add service mappings for:
      - Health Station Services (primary care focus)
      - Ambulatory Service Center Services (outpatient focus)
      - Extended Care Facility Services (long-term care focus)
      - Hospital Services (acute care focus)
      - Specialty Care Center Services (specialized care focus)
    - Each mapping includes:
      - ICD code
      - Service
      - Confidence level
      - Mapping logic
      - System of care

  2. Updates
    - Update encounters table with new mappings
*/

-- Health Station Services Mappings (Primary Care Focus)
INSERT INTO health_station_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('J04', 'Acute & urgent care', 'high', 'Acute respiratory conditions requiring prompt evaluation', 'Unplanned care'),
  ('J20', 'Acute & urgent care', 'high', 'Acute bronchitis needs assessment and treatment', 'Unplanned care'),
  ('K29', 'Acute & urgent care', 'high', 'Gastritis requires evaluation and management', 'Unplanned care'),
  ('L20', 'Acute & urgent care', 'medium', 'Atopic dermatitis needs assessment and treatment', 'Chronic conditions'),
  ('N39', 'Acute & urgent care', 'high', 'Urinary system disorders need prompt evaluation', 'Unplanned care');

-- Ambulatory Service Center Services Mappings (Outpatient Focus)
INSERT INTO ambulatory_service_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('H52', 'Ophthalmology', 'high', 'Disorders of refraction require specialist evaluation', 'Planned care'),
  ('H61', 'Otolaryngology / ENT', 'high', 'Disorders of external ear need specialist care', 'Planned care'),
  ('L70', 'Dermatology', 'medium', 'Acne requires dermatological treatment', 'Planned care'),
  ('M54', 'Orthopaedics (inc. podiatry)', 'high', 'Dorsalgia requires proper evaluation', 'Planned care'),
  ('R51', 'Neurology', 'high', 'Headache needs proper evaluation and management', 'Unplanned care');

-- Extended Care Facility Services Mappings (Long-term Care Focus)
INSERT INTO extended_care_facility_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('G30', 'Complex condition / Frail elderly', 'high', 'Alzheimers disease requires long-term care', 'Complex, multi-morbid'),
  ('I69', 'Complex condition / Frail elderly', 'high', 'Sequelae of cerebrovascular disease needs ongoing care', 'Complex, multi-morbid'),
  ('L89', 'Complex condition / Frail elderly', 'high', 'Pressure ulcer requires specialized wound care', 'Complex, multi-morbid'),
  ('R26', 'Allied Health & Health Promotion', 'high', 'Abnormalities of gait need physical therapy', 'Complex, multi-morbid'),
  ('R41', 'Complex condition / Frail elderly', 'high', 'Cognitive function disorders need ongoing support', 'Complex, multi-morbid');

-- Hospital Services Mappings (Acute Care Focus)
INSERT INTO hospital_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('A41', 'Critical Care Medicine', 'high', 'Sepsis requires immediate hospital care', 'Unplanned care'),
  ('I46', 'Cardiology', 'high', 'Cardiac arrest needs emergency intervention', 'Unplanned care'),
  ('K65', 'General Surgery', 'high', 'Peritonitis requires surgical evaluation', 'Unplanned care'),
  ('R57', 'Critical Care Medicine', 'high', 'Shock requires immediate intensive care', 'Unplanned care'),
  ('T81', 'General Surgery', 'high', 'Complications of procedures need hospital care', 'Unplanned care');

-- Specialty Care Center Services Mappings (Specialized Care Focus)
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('C34', 'Oncology', 'high', 'Lung cancer requires specialized oncology care', 'Complex, multi-morbid'),
  ('E10', 'Endocrinology', 'high', 'Type 1 diabetes needs specialist management', 'Chronic conditions'),
  ('I48', 'Cardiology', 'high', 'Atrial fibrillation requires cardiology care', 'Chronic conditions'),
  ('K51', 'Gastroenterology', 'high', 'Ulcerative colitis needs specialist care', 'Chronic conditions'),
  ('M32', 'Rheumatology', 'high', 'Systemic lupus requires specialist management', 'Complex, multi-morbid');

-- Update encounters table with new mappings
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    FOR r IN SELECT * FROM encounters 
    WHERE service IS NULL 
    OR confidence IS NULL 
    OR "mapping logic" IS NULL
    LOOP
        -- Get mapping for each unmapped record
        SELECT * FROM get_service_mapping(
            r."care setting",
            r."icd family code",
            r."system of care"
        ) INTO mapping_result;
        
        -- Update record if mapping found
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