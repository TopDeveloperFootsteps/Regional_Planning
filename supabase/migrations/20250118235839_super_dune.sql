-- Drop existing views if they exist
DROP VIEW IF EXISTS encounters_statistics;
DROP VIEW IF EXISTS system_of_care_analysis;
DROP VIEW IF EXISTS icd_code_analysis;

-- Create encounters_statistics view with properly formatted care settings
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
    END as care_setting,
    COUNT(*) as total_encounters,
    SUM("number of encounters") as total_encounter_count,
    COUNT(DISTINCT "system of care") as unique_systems,
    COUNT(DISTINCT "icd family code") as unique_icd_codes,
    array_agg(DISTINCT "system of care") as systems_of_care
  FROM encounters
  GROUP BY "care setting"
)
SELECT 
  care_setting,
  total_encounters as record_count,
  total_encounter_count as encounter_count,
  unique_systems as systems_count,
  unique_icd_codes as icd_code_count,
  systems_of_care
FROM stats
ORDER BY total_encounter_count DESC;

-- Create system_of_care_analysis view
CREATE VIEW system_of_care_analysis AS
SELECT 
  "system of care" as system_of_care,
  COUNT(*) as record_count,
  SUM("number of encounters") as total_encounters,
  COUNT(DISTINCT "icd family code") as unique_icd_codes,
  array_agg(DISTINCT CASE "care setting"
    WHEN 'HEALTH STATION' THEN 'Health Station'
    WHEN 'HOME' THEN 'Home'
    WHEN 'AMBULATORY SERVICE CENTER' THEN 'Ambulatory Service Center'
    WHEN 'SPECIALTY CARE CENTER' THEN 'Specialty Care Center'
    WHEN 'EXTENDED CARE FACILITY' THEN 'Extended Care Facility'
    WHEN 'HOSPITAL' THEN 'Hospital'
    ELSE "care setting"
  END) as care_settings
FROM encounters
GROUP BY "system of care"
ORDER BY total_encounters DESC;

-- Create icd_code_analysis view
CREATE VIEW icd_code_analysis AS
SELECT 
  "icd family code" as icd_family_code,
  COUNT(*) as record_count,
  SUM("number of encounters") as total_encounters,
  COUNT(DISTINCT "care setting") as unique_settings,
  COUNT(DISTINCT "system of care") as unique_systems,
  array_agg(DISTINCT "system of care") as systems_of_care
FROM encounters
GROUP BY "icd family code"
ORDER BY total_encounters DESC;

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_encounters_number_of_encounters
    ON encounters ("number of encounters");

CREATE INDEX IF NOT EXISTS idx_encounters_composite_analysis
    ON encounters ("care setting", "system of care", "icd family code");