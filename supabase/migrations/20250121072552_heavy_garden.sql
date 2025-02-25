-- First: Create a unique constraint for icd_code and systems_of_care
ALTER TABLE ambulatory_service_center_services_mapping
DROP CONSTRAINT IF EXISTS unique_icd_system_constraint;

ALTER TABLE ambulatory_service_center_services_mapping
ADD CONSTRAINT unique_icd_system_constraint UNIQUE (icd_code, systems_of_care);

-- Now we can safely copy the records
INSERT INTO ambulatory_service_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care)
SELECT 
    icd_code,
    service,
    confidence,
    mapping_logic,
    systems_of_care
FROM ambulatory_services_mapping
ON CONFLICT (icd_code, systems_of_care) DO UPDATE 
SET 
    service = EXCLUDED.service,
    confidence = EXCLUDED.confidence,
    mapping_logic = EXCLUDED.mapping_logic;

-- Create an index to improve query performance
CREATE INDEX IF NOT EXISTS idx_ambulatory_service_center_icd_system
ON ambulatory_service_center_services_mapping (icd_code, systems_of_care);

-- Show the count after copying
SELECT COUNT(*) as record_count 
FROM ambulatory_service_center_services_mapping;