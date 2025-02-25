/*
  # Add Service Mappings for Care Settings

  1. New Mappings
    - Add service mappings for:
      - Health Station Services
      - Extended Care Facility Services
      - Hospital Services
      - Specialty Care Center Services
    - Each mapping includes:
      - ICD code
      - Service
      - Confidence level
      - Mapping logic
      - System of care

  2. Updates
    - Update encounters table with new mappings
*/

-- Health Station Services Mappings
INSERT INTO health_station_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('Z23', 'Well baby care (0 to 4)', 'high', 'Immunization services are essential for preventive care', 'Children and young people'),
  ('Z00', 'Routine health checks', 'high', 'Regular health screenings are fundamental to primary care', 'Planned care'),
  ('J06', 'Acute & urgent care', 'high', 'Upper respiratory infections need prompt evaluation', 'Unplanned care'),
  ('E11', 'Chronic metabolic diseases', 'high', 'Diabetes monitoring and management', 'Chronic conditions'),
  ('I10', 'Chronic metabolic diseases', 'high', 'Hypertension monitoring and management', 'Chronic conditions');

-- Extended Care Facility Services Mappings
INSERT INTO extended_care_facility_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('Z74', 'Complex condition / Frail elderly', 'high', 'Care for reduced mobility and dependence', 'Complex, multi-morbid'),
  ('F03', 'Complex condition / Frail elderly', 'high', 'Dementia care and support', 'Complex, multi-morbid'),
  ('I63', 'Complex condition / Frail elderly', 'high', 'Post-stroke care and rehabilitation', 'Complex, multi-morbid'),
  ('M17', 'Allied Health & Health Promotion', 'high', 'Joint disorders requiring ongoing therapy', 'Chronic conditions'),
  ('G20', 'Complex condition / Frail elderly', 'high', 'Parkinsons disease management', 'Complex, multi-morbid');

-- Hospital Services Mappings
INSERT INTO hospital_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('I21', 'Cardiology', 'high', 'Acute myocardial infarction requires immediate hospital care', 'Unplanned care'),
  ('J18', 'Pulmonology / Respiratory Medicine', 'high', 'Pneumonia requiring hospital admission', 'Unplanned care'),
  ('K35', 'General Surgery', 'high', 'Acute appendicitis requiring surgical intervention', 'Unplanned care'),
  ('S72', 'Orthopaedics (inc. podiatry)', 'high', 'Hip fracture requiring surgical treatment', 'Unplanned care'),
  ('O60', 'Obstetrics & Gynaecology', 'high', 'Preterm labor requiring hospital care', 'Unplanned care');

-- Specialty Care Center Services Mappings
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('C50', 'Oncology', 'high', 'Breast cancer requiring specialized oncology care', 'Complex, multi-morbid'),
  ('M05', 'Rheumatology', 'high', 'Rheumatoid arthritis requiring specialist care', 'Chronic conditions'),
  ('G35', 'Neurology (inc. neurophysiology and neuropathology)', 'high', 'Multiple sclerosis management', 'Complex, multi-morbid'),
  ('J45', 'Pulmonology / Respiratory Medicine', 'high', 'Severe asthma requiring specialist care', 'Chronic conditions'),
  ('K50', 'Gastroenterology', 'high', 'Crohns disease management', 'Chronic conditions');

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