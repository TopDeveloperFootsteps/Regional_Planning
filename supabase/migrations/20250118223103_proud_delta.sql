-- Create a view to show row counts for all service mapping tables
CREATE OR REPLACE VIEW table_row_counts AS
SELECT
    'ambulatory_service_center_services_mapping' as table_name,
    COUNT(*) as row_count
FROM ambulatory_service_center_services_mapping
UNION ALL
SELECT
    'extended_care_facility_services_mapping' as table_name,
    COUNT(*) 
FROM extended_care_facility_services_mapping
UNION ALL
SELECT
    'specialty_care_center_services_mapping' as table_name,
    COUNT(*) 
FROM specialty_care_center_services_mapping
UNION ALL
SELECT
    'health_station_services_mapping' as table_name,
    COUNT(*) 
FROM health_station_services_mapping
UNION ALL
SELECT
    'home_services_mapping' as table_name,
    COUNT(*) 
FROM home_services_mapping
UNION ALL
SELECT
    'hospital_services_mapping' as table_name,
    COUNT(*) 
FROM hospital_services_mapping
UNION ALL
SELECT
    'encounters' as table_name,
    COUNT(*) 
FROM encounters;

-- Get the counts
SELECT * FROM table_row_counts ORDER BY table_name;