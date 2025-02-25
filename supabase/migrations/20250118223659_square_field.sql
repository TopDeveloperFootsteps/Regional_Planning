-- Drop existing function
DROP FUNCTION IF EXISTS get_service_mapping;

-- Create updated function with correct table references
CREATE OR REPLACE FUNCTION get_service_mapping(
    p_care_setting text,
    p_icd_code text,
    p_system_of_care text
) RETURNS TABLE (
    service text,
    confidence text,
    mapping_logic text
) AS $$
BEGIN
    CASE p_care_setting
        WHEN 'HEALTH STATION' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM health_station_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'HOME' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM home_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'AMBULATORY SERVICE CENTER' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM ambulatory_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'SPECIALTY CARE CENTER' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM specialty_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'EXTENDED CARE FACILITY' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM extended_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'HOSPITAL' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM hospital_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
    END CASE;
END;
$$ LANGUAGE plpgsql;