-- Create a temporary table with all valid services
CREATE TEMP TABLE valid_services AS
WITH RECURSIVE service_sources AS (
    -- Get services from home services mapping
    SELECT DISTINCT service FROM home_services_mapping
    UNION
    SELECT DISTINCT service FROM health_station_services_mapping
    UNION
    SELECT DISTINCT service FROM ambulatory_service_center_services_mapping
    UNION
    SELECT DISTINCT service FROM specialty_care_center_services_mapping
    UNION
    SELECT DISTINCT service FROM extended_care_facility_services_mapping
    UNION
    SELECT DISTINCT service FROM hospital_services_mapping
)
SELECT DISTINCT service FROM service_sources;

-- Create view to analyze service mappings
CREATE OR REPLACE VIEW service_mapping_analysis AS
WITH invalid_services AS (
    SELECT DISTINCT 
        pfc.service,
        pfc.care_setting,
        COUNT(*) as occurrence_count,
        array_agg(DISTINCT pfc.icd_family) as example_icd_codes
    FROM planning_family_code pfc
    LEFT JOIN valid_services vs ON vs.service = pfc.service
    WHERE vs.service IS NULL
    GROUP BY pfc.service, pfc.care_setting
),
service_stats AS (
    SELECT 
        COUNT(*) as total_records,
        COUNT(DISTINCT pfc.service) as unique_services,
        SUM(CASE WHEN vs.service IS NULL THEN 1 ELSE 0 END) as invalid_service_records,
        ROUND((SUM(CASE WHEN vs.service IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*)::numeric * 100), 2) as invalid_percentage
    FROM planning_family_code pfc
    LEFT JOIN valid_services vs ON vs.service = pfc.service
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
    WHERE pfc.service NOT IN (SELECT service FROM valid_services);
END;
$$ LANGUAGE plpgsql;

-- Add comment explaining the analysis
COMMENT ON VIEW service_mapping_analysis IS 'Analyzes service mappings in planning_family_code table to identify invalid services';