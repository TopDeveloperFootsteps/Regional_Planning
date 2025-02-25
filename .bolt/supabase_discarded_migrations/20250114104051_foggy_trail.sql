/*
  # Update home_sp mappings

  1. Updates
    - Update service, confidence, and mapping_logic in home_sp table
    - Match based on icd_code and systems_of_care from home_services_mapping
*/

-- Update home_sp with matching values from home_services_mapping
UPDATE home_sp
SET 
    service = hsm.service,
    confidence = hsm.confidence,
    mapping_logic = hsm.mapping_logic
FROM home_services_mapping hsm
WHERE home_sp.icd_code = hsm.icd_code
AND home_sp.systems_of_care = hsm.systems_of_care;

-- Create a view to show mapping status by system of care
CREATE OR REPLACE VIEW home_sp_mapping_by_system AS
SELECT 
    systems_of_care,
    COUNT(*) as total_codes,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as mapped_codes,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_codes,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapped_percentage
FROM home_sp
GROUP BY systems_of_care
ORDER BY systems_of_care;