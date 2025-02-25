/*
  # Update immunization code mappings

  1. Changes
    - Update immunization codes (Z23) to map to Well baby care (0 to 4) for:
      - home_sm
      - health_station_services_mapping
      - ambulatory_services_mapping
  
  2. Affected Tables
    - home_sm
    - health_station_services_mapping
    - ambulatory_services_mapping
*/

-- Update home_sm table
UPDATE home_sm
SET 
    service = 'Well baby care (0 to 4)',
    confidence = 'high',
    mapping_logic = 'Immunization services are part of well baby care program'
WHERE icd_code LIKE 'Z23%';

-- Update health_station_services_mapping table
UPDATE health_station_services_mapping
SET 
    service = 'Well baby care (0 to 4)',
    confidence = 'high',
    mapping_logic = 'Immunization services are part of well baby care program'
WHERE icd_code LIKE 'Z23%';

-- Update ambulatory_services_mapping table
UPDATE ambulatory_services_mapping
SET 
    service = 'Well baby care (0 to 4)',
    confidence = 'high',
    mapping_logic = 'Immunization services are part of well baby care program'
WHERE icd_code LIKE 'Z23%';