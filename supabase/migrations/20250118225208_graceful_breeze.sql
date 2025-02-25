/*
  # Phase 2: Comprehensive Specialty Care Mappings

  1. Focus Areas
    - Map remaining ICD codes
    - Cover additional specialties
    - Address edge cases

  2. Approach
    - Add remaining specialty mappings
    - Update encounters table
    - Generate final statistics
*/

-- Phase 2: Add remaining specialty mappings
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Diagnostic/Therapeutic Services
  ('Z01', 'Diagnostics & Therapeutics', 'high', 'Special examinations and investigations', 'Planned care'),
  ('Z08', 'Oncology', 'high', 'Follow-up examination after treatment for malignant neoplasms', 'Planned care'),
  ('Z09', 'Diagnostics & Therapeutics', 'high', 'Follow-up examination after treatment for conditions other than malignant neoplasms', 'Planned care'),

  -- Anesthesiology
  ('T88.2', 'Anesthesiology', 'high', 'Shock due to anesthesia requires specialist care', 'Unplanned care'),
  ('T88.3', 'Anesthesiology', 'high', 'Malignant hyperthermia due to anesthesia', 'Unplanned care'),
  ('T88.5', 'Anesthesiology', 'high', 'Other complications of anesthesia', 'Unplanned care'),

  -- Critical Care Medicine
  ('R57', 'Critical Care Medicine', 'high', 'Shock requires intensive care management', 'Unplanned care'),
  ('R58', 'Critical Care Medicine', 'high', 'Hemorrhage requires critical care', 'Unplanned care'),
  ('R65', 'Critical Care Medicine', 'high', 'Inflammatory response syndrome needs intensive care', 'Unplanned care'),

  -- Physical Medicine and Rehabilitation
  ('Z50.1', 'Physical Medicine and Rehabilitation', 'high', 'Other physical therapy', 'Planned care'),
  ('Z50.8', 'Physical Medicine and Rehabilitation', 'high', 'Care involving use of rehabilitation procedures', 'Planned care'),
  ('Z50.9', 'Physical Medicine and Rehabilitation', 'high', 'Care involving use of rehabilitation procedure, unspecified', 'Planned care');

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
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_care_center_services_mapping
        WHERE icd_code LIKE LEFT(r."icd family code", 3) || '%'
        AND systems_of_care = r."system of care"
        LIMIT 1
        INTO mapping_result;
        
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
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';