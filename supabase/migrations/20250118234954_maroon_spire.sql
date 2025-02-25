/*
  # Update encounters analysis views

  1. Changes
    - Create views for encounters statistics
    - Add indexes for better performance
    - Create analysis functions
*/

-- Create or replace view for encounters statistics
CREATE OR REPLACE VIEW encounters_statistics AS
WITH stats AS (
  SELECT 
    "care setting",
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

-- Create view for system of care analysis
CREATE OR REPLACE VIEW system_of_care_analysis AS
SELECT 
  "system of care",
  COUNT(*) as record_count,
  SUM("number of encounters") as total_encounters,
  COUNT(DISTINCT "icd family code") as unique_icd_codes,
  array_agg(DISTINCT "care setting") as care_settings
FROM encounters
GROUP BY "system of care"
ORDER BY total_encounters DESC;

-- Create view for ICD code analysis
CREATE OR REPLACE VIEW icd_code_analysis AS
SELECT 
  "icd family code",
  COUNT(*) as record_count,
  SUM("number of encounters") as total_encounters,
  COUNT(DISTINCT "care setting") as unique_settings,
  COUNT(DISTINCT "system of care") as unique_systems,
  array_agg(DISTINCT "system of care") as systems_of_care
FROM encounters
GROUP BY "icd family code"
ORDER BY total_encounters DESC;

-- Add additional indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_encounters_number_of_encounters
    ON encounters ("number of encounters");

CREATE INDEX IF NOT EXISTS idx_encounters_composite_analysis
    ON encounters ("care setting", "system of care", "icd family code");