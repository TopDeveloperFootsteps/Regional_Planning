-- First: Remove duplicates from the target table
DELETE FROM specialty_care_center_services_mapping a
WHERE a.ctid <> (
    SELECT min(b.ctid)
    FROM specialty_care_center_services_mapping b
    WHERE a.icd_code = b.icd_code 
    AND a.systems_of_care = b.systems_of_care
);

-- Now create the unique constraint
ALTER TABLE specialty_care_center_services_mapping
DROP CONSTRAINT IF EXISTS unique_specialty_care_icd_system_constraint;

ALTER TABLE specialty_care_center_services_mapping
ADD CONSTRAINT unique_specialty_care_icd_system_constraint UNIQUE (icd_code, systems_of_care);

-- Copy records from specialty_services_mapping
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care)
SELECT DISTINCT ON (icd_code, systems_of_care)
    icd_code,
    service,
    confidence,
    mapping_logic,
    systems_of_care
FROM specialty_services_mapping
ON CONFLICT (icd_code, systems_of_care) DO UPDATE 
SET 
    service = EXCLUDED.service,
    confidence = EXCLUDED.confidence,
    mapping_logic = EXCLUDED.mapping_logic;

-- Create an index to improve query performance
CREATE INDEX IF NOT EXISTS idx_specialty_care_center_icd_system
ON specialty_care_center_services_mapping (icd_code, systems_of_care);

-- Show the count after copying
SELECT COUNT(*) as record_count 
FROM specialty_care_center_services_mapping;