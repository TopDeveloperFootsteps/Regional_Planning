/*
  # Update hospital immunization code mappings

  1. Changes
    - Update immunization codes (Z23) to map to Social, Community and Preventative Medicine for:
      - hospital_services_mapping
  
  2. Affected Tables
    - hospital_services_mapping
*/

-- Update hospital_services_mapping table
UPDATE hospital_services_mapping
SET 
    service = 'Social, Community and Preventative Medicine',
    confidence = 'high',
    mapping_logic = 'Immunization services in hospital setting are handled by preventative medicine department'
WHERE icd_code LIKE 'Z23%';