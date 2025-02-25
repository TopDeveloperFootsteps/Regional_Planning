-- First: Create a function to get the appropriate service based on ICD code and care setting
CREATE OR REPLACE FUNCTION get_appropriate_service(
    p_icd_code text,
    p_care_setting text,
    p_systems_of_care text
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    v_service text;
BEGIN
    -- Check care setting and get service from appropriate mapping table
    CASE p_care_setting
        WHEN 'HOME' THEN
            SELECT service INTO v_service
            FROM home_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_systems_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'HEALTH STATION' THEN
            SELECT service INTO v_service
            FROM health_station_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_systems_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'AMBULATORY SERVICE CENTER' THEN
            SELECT service INTO v_service
            FROM ambulatory_service_center_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_systems_of_care
            ORDER BY confidence DESC
            LIMIT 1;
    END CASE;

    RETURN v_service;
END;
$$;

-- Phase 1: Update HOME services
UPDATE planning_family_code pfc
SET service = (
    SELECT service 
    FROM home_services_mapping hsm
    WHERE hsm.icd_code LIKE LEFT(pfc.icd_family, 3) || '%'
    AND hsm.systems_of_care = pfc.systems_of_care
    ORDER BY hsm.confidence DESC
    LIMIT 1
)
WHERE pfc.care_setting = 'HOME'
AND EXISTS (
    SELECT 1 
    FROM home_services_mapping hsm
    WHERE hsm.icd_code LIKE LEFT(pfc.icd_family, 3) || '%'
    AND hsm.systems_of_care = pfc.systems_of_care
);

-- Phase 2: Update AMBULATORY SERVICE CENTER services
UPDATE planning_family_code pfc
SET service = (
    SELECT service 
    FROM ambulatory_service_center_services_mapping asm
    WHERE asm.icd_code LIKE LEFT(pfc.icd_family, 3) || '%'
    AND asm.systems_of_care = pfc.systems_of_care
    ORDER BY asm.confidence DESC
    LIMIT 1
)
WHERE pfc.care_setting = 'AMBULATORY SERVICE CENTER'
AND EXISTS (
    SELECT 1 
    FROM ambulatory_service_center_services_mapping asm
    WHERE asm.icd_code LIKE LEFT(pfc.icd_family, 3) || '%'
    AND asm.systems_of_care = pfc.systems_of_care
);

-- Phase 3: Update HEALTH STATION services
UPDATE planning_family_code pfc
SET service = (
    SELECT service 
    FROM health_station_services_mapping hsm
    WHERE hsm.icd_code LIKE LEFT(pfc.icd_family, 3) || '%'
    AND hsm.systems_of_care = pfc.systems_of_care
    ORDER BY hsm.confidence DESC
    LIMIT 1
)
WHERE pfc.care_setting = 'HEALTH STATION'
AND EXISTS (
    SELECT 1 
    FROM health_station_services_mapping hsm
    WHERE hsm.icd_code LIKE LEFT(pfc.icd_family, 3) || '%'
    AND hsm.systems_of_care = pfc.systems_of_care
);

-- Create a view to analyze the mapping results
CREATE OR REPLACE VIEW planning_service_mapping_analysis AS
WITH mapping_stats AS (
    SELECT 
        care_setting,
        COUNT(*) as total_records,
        COUNT(service) as mapped_records,
        COUNT(*) - COUNT(service) as unmapped_records,
        ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) as mapping_percentage
    FROM planning_family_code
    GROUP BY care_setting
)
SELECT 
    care_setting,
    total_records,
    mapped_records,
    unmapped_records,
    mapping_percentage || '%' as mapping_percentage
FROM mapping_stats
ORDER BY mapping_percentage DESC;