-- Drop existing view if it exists
DROP VIEW IF EXISTS encounters_statistics;

-- Create view with properly formatted care settings while preserving column names
CREATE VIEW encounters_statistics AS
WITH stats AS (
  SELECT 
    CASE "care setting"
      WHEN 'HEALTH STATION' THEN 'Health Station'
      WHEN 'HOME' THEN 'Home'
      WHEN 'AMBULATORY SERVICE CENTER' THEN 'Ambulatory Service Center'
      WHEN 'SPECIALTY CARE CENTER' THEN 'Specialty Care Center'
      WHEN 'EXTENDED CARE FACILITY' THEN 'Extended Care Facility'
      WHEN 'HOSPITAL' THEN 'Hospital'
      ELSE "care setting"
    END as "care setting",
    COUNT(*) as total_encounters,
    SUM("number of encounters") as total_encounter_count,
    COUNT(DISTINCT "system of care") as unique_systems,
    COUNT(DISTINCT "icd family code") as unique_icd_codes,
    array_agg(DISTINCT "system of care") as systems_of_care
  FROM encounters
  GROUP BY "care setting"
)
SELECT 
  "care setting",
  total_encounters as record_count,
  total_encounter_count as encounter_count,
  unique_systems as systems_count,
  unique_icd_codes as icd_code_count,
  systems_of_care
FROM stats
ORDER BY total_encounter_count DESC;