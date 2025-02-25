/*
  # Map Ambulatory Service Center Encounters

  This migration updates the encounters table with service mappings for the AMBULATORY SERVICE CENTER care setting.
  It uses the ambulatory_service_center_services_mapping table as the source for mappings.

  1. Updates
    - Maps service, confidence, and mapping logic for AMBULATORY SERVICE CENTER encounters
    - Only updates unmapped records
    - Matches on ICD code prefix and system of care
*/

-- Update encounters for AMBULATORY SERVICE CENTER
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    -- Loop through unmapped AMBULATORY SERVICE CENTER encounters
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'AMBULATORY SERVICE CENTER'
        AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
    LOOP
        -- Get mapping from ambulatory_service_center_services_mapping
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM ambulatory_service_center_services_mapping
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

-- Get mapping statistics for AMBULATORY SERVICE CENTER
SELECT 
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'AMBULATORY SERVICE CENTER';