-- First: Create a unique constraint for icd_code and systems_of_care
ALTER TABLE extended_care_facility_services_mapping
DROP CONSTRAINT IF EXISTS unique_extended_care_icd_system_constraint;

ALTER TABLE extended_care_facility_services_mapping
ADD CONSTRAINT unique_extended_care_icd_system_constraint UNIQUE (icd_code, systems_of_care);

-- Now we can safely copy the records
INSERT INTO extended_care_facility_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care)
SELECT 
    icd_code,
    service,
    confidence,
    mapping_logic,
    systems_of_care
FROM extended_services_mapping
ON CONFLICT (icd_code, systems_of_care) DO UPDATE 
SET 
    service = EXCLUDED.service,
    confidence = EXCLUDED.confidence,
    mapping_logic = EXCLUDED.mapping_logic;

-- Create an index to improve query performance
CREATE INDEX IF NOT EXISTS idx_extended_care_facility_icd_system
ON extended_care_facility_services_mapping (icd_code, systems_of_care);

-- Show the count after copying
SELECT COUNT(*) as record_count 
FROM extended_care_facility_services_mapping;