-- Create a view of all valid services from mapping tables
CREATE OR REPLACE VIEW valid_services_view AS
SELECT DISTINCT service 
FROM (
    SELECT service FROM home_services_mapping
    UNION ALL
    SELECT service FROM health_station_services_mapping
    UNION ALL
    SELECT service FROM ambulatory_service_center_services_mapping
    UNION ALL
    SELECT service FROM specialty_care_center_services_mapping
    UNION ALL
    SELECT service FROM extended_care_facility_services_mapping
    UNION ALL
    SELECT service FROM hospital_services_mapping
) all_services;

-- Create view for service mapping analysis
CREATE OR REPLACE VIEW service_mapping_analysis AS
WITH invalid_services AS (
    SELECT DISTINCT 
        pfc.service,
        pfc.care_setting,
        COUNT(*) as occurrence_count,
        array_agg(DISTINCT pfc.icd_family) as example_icd_codes
    FROM planning_family_code pfc
    LEFT JOIN valid_services_view vsv ON vsv.service = pfc.service
    WHERE vsv.service IS NULL
    GROUP BY pfc.service, pfc.care_setting
),
service_stats AS (
    SELECT 
        COUNT(*) as total_records,
        COUNT(DISTINCT pfc.service) as unique_services,
        SUM(CASE WHEN vsv.service IS NULL THEN 1 ELSE 0 END) as invalid_service_records,
        ROUND((SUM(CASE WHEN vsv.service IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*)::numeric * 100), 2) as invalid_percentage
    FROM planning_family_code pfc
    LEFT JOIN valid_services_view vsv ON vsv.service = pfc.service
)
SELECT 
    'Summary'::text as analysis_type,
    jsonb_build_object(
        'total_records', total_records,
        'unique_services', unique_services,
        'invalid_records', invalid_service_records,
        'invalid_percentage', invalid_percentage || '%'
    ) as summary_data,
    NULL::text as service,
    NULL::text as care_setting,
    NULL::integer as occurrence_count,
    NULL::text[] as example_icd_codes
FROM service_stats
UNION ALL
SELECT 
    'Invalid Service'::text as analysis_type,
    NULL as summary_data,
    service,
    care_setting,
    occurrence_count,
    example_icd_codes
FROM invalid_services
ORDER BY analysis_type, occurrence_count DESC NULLS LAST;

-- Create function to fix invalid services
CREATE OR REPLACE FUNCTION fix_invalid_services()
RETURNS void AS $$
BEGIN
    -- Update invalid services using the service mapping function
    UPDATE planning_family_code pfc
    SET service = get_service_for_planning(pfc.care_setting, pfc.icd_family, pfc.systems_of_care)
    WHERE pfc.service NOT IN (SELECT service FROM valid_services_view);
END;
$$ LANGUAGE plpgsql;

-- Add comments
COMMENT ON VIEW valid_services_view IS 'View of all valid services from service mapping tables';
COMMENT ON VIEW service_mapping_analysis IS 'Analyzes service mappings in planning_family_code table to identify invalid services';
COMMENT ON FUNCTION fix_invalid_services() IS 'Updates invalid services in planning_family_code table using service mapping function';