/*
  # Copy health station codes to services mapping

  1. Changes
    - Insert data from health_station_codes to health_station_services_mapping
    - Set initial service, confidence and mapping logic values
    - Create monitoring view
*/

-- Insert data from health_station_codes to health_station_services_mapping
INSERT INTO health_station_services_mapping 
(icd_code, systems_of_care, service, confidence, mapping_logic)
SELECT 
    codes."ICD FamilyCode",
    codes."Systems of Care",
    'Pending Review',  -- Default service
    'medium',         -- Default confidence
    'Initial mapping from health_station_codes' -- Default mapping logic
FROM health_station_codes codes;

-- Create a view to monitor the data transfer
CREATE OR REPLACE VIEW health_station_mapping_status AS
SELECT 
    COUNT(DISTINCT codes."ICD FamilyCode") as total_source_codes,
    COUNT(DISTINCT mapping.icd_code) as total_mapped_codes,
    ROUND((COUNT(DISTINCT mapping.icd_code)::numeric / NULLIF(COUNT(DISTINCT codes."ICD FamilyCode"), 0)::numeric) * 100, 2) as transfer_percentage
FROM health_station_codes codes
LEFT JOIN health_station_services_mapping mapping ON codes."ICD FamilyCode" = mapping.icd_code;