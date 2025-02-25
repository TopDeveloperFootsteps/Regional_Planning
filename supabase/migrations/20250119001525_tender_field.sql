-- Drop existing views
DROP VIEW IF EXISTS encounters_statistics;
DROP VIEW IF EXISTS system_of_care_analysis;

-- Create encounters_statistics view with integer numbers
CREATE VIEW encounters_statistics AS
WITH total_encounters AS (
  SELECT FLOOR(SUM("number of encounters")) as total
  FROM encounters
),
stats AS (
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
    FLOOR(COUNT(*)) as total_records,
    FLOOR(SUM("number of encounters")) as total_encounter_count,
    FLOOR(COUNT(DISTINCT "icd family code")) as unique_icd_codes
  FROM encounters
  GROUP BY "care setting"
)
SELECT 
  care_setting,
  total_records as record_count,
  total_encounter_count as encounter_count,
  unique_icd_codes as icd_code_count,
  FLOOR(total_encounter_count::numeric / t.total * 100) as encounter_percentage
FROM stats, total_encounters t
ORDER BY total_encounter_count DESC;

-- Create system_of_care_analysis view with integer numbers
CREATE VIEW system_of_care_analysis AS
WITH care_setting_totals AS (
  SELECT 
    "system of care",
    "care setting",
    FLOOR(SUM("number of encounters")) as setting_encounters,
    FLOOR(SUM(SUM("number of encounters")) OVER (PARTITION BY "system of care")) as total_system_encounters
  FROM encounters
  GROUP BY "system of care", "care setting"
)
SELECT 
  e."system of care" as system_of_care,
  FLOOR(COUNT(*)) as record_count,
  FLOOR(SUM(e."number of encounters")) as total_encounters,
  FLOOR(COUNT(DISTINCT e."icd family code")) as unique_icd_codes,
  jsonb_object_agg(
    CASE cs."care setting"
      WHEN 'HEALTH STATION' THEN 'Health Station'
      WHEN 'HOME' THEN 'Home'
      WHEN 'AMBULATORY SERVICE CENTER' THEN 'Ambulatory Service Center'
      WHEN 'SPECIALTY CARE CENTER' THEN 'Specialty Care Center'
      WHEN 'EXTENDED CARE FACILITY' THEN 'Extended Care Facility'
      WHEN 'HOSPITAL' THEN 'Hospital'
      ELSE cs."care setting"
    END,
    FLOOR(cs.setting_encounters::numeric / cs.total_system_encounters * 100)
  ) as care_setting_percentages
FROM encounters e
LEFT JOIN care_setting_totals cs ON 
  e."system of care" = cs."system of care" AND 
  e."care setting" = cs."care setting"
GROUP BY e."system of care"
ORDER BY total_encounters DESC;