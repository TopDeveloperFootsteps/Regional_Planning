-- Map encounters for EXTENDED CARE FACILITY and SPECIALTY CARE CENTER
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    -- First: Map EXTENDED CARE FACILITY encounters
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'EXTENDED CARE FACILITY'
        AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
    LOOP
        -- Get mapping from extended_care_facility_services_mapping
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM extended_care_facility_services_mapping
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

    -- Second: Map SPECIALTY CARE CENTER encounters
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'SPECIALTY CARE CENTER'
        AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
    LOOP
        -- Get mapping from specialty_care_center_services_mapping
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_care_center_services_mapping
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

-- Get mapping statistics for EXTENDED CARE FACILITY
SELECT 
    'EXTENDED CARE FACILITY' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'EXTENDED CARE FACILITY'
UNION ALL
-- Get mapping statistics for SPECIALTY CARE CENTER
SELECT 
    'SPECIALTY CARE CENTER' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER'
ORDER BY care_setting;