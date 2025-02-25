/*
  # Map Specialty Care Center Encounters

  1. Changes
    - Map encounters for SPECIALTY CARE CENTER using specialty_services_mapping table
    - Update service, confidence, and mapping logic for each encounter
    - Add mapping statistics view

  2. Process
    - Loop through unmapped SPECIALTY CARE CENTER encounters
    - Match ICD codes using prefix matching
    - Update encounters with mapped services
*/

-- Map SPECIALTY CARE CENTER encounters
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    -- Loop through unmapped SPECIALTY CARE CENTER encounters
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'SPECIALTY CARE CENTER'
        AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
    LOOP
        -- Get mapping from specialty_services_mapping
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_services_mapping
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

-- Create or replace view for specialty care mapping statistics
CREATE OR REPLACE VIEW specialty_care_mapping_stats AS
SELECT 
    'SPECIALTY CARE CENTER' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';

-- Show mapping statistics
SELECT * FROM specialty_care_mapping_stats;