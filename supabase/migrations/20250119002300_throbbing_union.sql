-- Create a view for care setting optimization analysis
CREATE OR REPLACE VIEW care_setting_optimization AS
WITH current_stats AS (
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
    FLOOR(SUM("number of encounters")) as current_encounters,
    FLOOR(SUM("number of encounters") * 100.0 / (SELECT SUM("number of encounters") FROM encounters)) as current_percentage,
    array_agg(DISTINCT "icd family code") as icd_codes
  FROM encounters
  GROUP BY "care setting"
),
optimization_potential AS (
  SELECT 
    care_setting,
    current_encounters,
    current_percentage,
    CASE care_setting
      WHEN 'Home' THEN 0 -- Already optimal
      WHEN 'Health Station' THEN 
        FLOOR(current_encounters * 0.15) -- 15% potential shift to Home
      WHEN 'Ambulatory Service Center' THEN 
        FLOOR(current_encounters * 0.25) -- 25% potential shift to Home/Health Station
      WHEN 'Specialty Care Center' THEN 
        FLOOR(current_encounters * 0.10) -- 10% potential shift to lower settings
      WHEN 'Extended Care Facility' THEN 
        FLOOR(current_encounters * 0.05) -- 5% potential shift to lower settings
      WHEN 'Hospital' THEN 
        FLOOR(current_encounters * 0.05) -- 5% potential shift to lower settings
      ELSE 0
    END as shift_potential,
    CASE care_setting
      WHEN 'Home' THEN 'Already optimal setting'
      WHEN 'Health Station' THEN 
        'Potential for home-based care through remote monitoring and telehealth'
      WHEN 'Ambulatory Service Center' THEN 
        'Opportunity for care delivery in home or health station settings with proper support'
      WHEN 'Specialty Care Center' THEN 
        'Some cases manageable in primary care settings with specialist oversight'
      WHEN 'Extended Care Facility' THEN 
        'Select cases suitable for home care with support'
      WHEN 'Hospital' THEN 
        'Some cases manageable in lower acuity settings with proper support'
      ELSE 'No specific optimization identified'
    END as optimization_strategy
  FROM current_stats
)
SELECT 
  care_setting,
  current_encounters,
  current_percentage as current_percentage,
  shift_potential,
  CASE 
    WHEN current_encounters > 0 THEN
      FLOOR((shift_potential::numeric / current_encounters) * 100)
    ELSE 0
  END as potential_shift_percentage,
  optimization_strategy
FROM optimization_potential
ORDER BY 
  CASE care_setting
    WHEN 'Home' THEN 1
    WHEN 'Health Station' THEN 2
    WHEN 'Ambulatory Service Center' THEN 3
    WHEN 'Specialty Care Center' THEN 4
    WHEN 'Extended Care Facility' THEN 5
    WHEN 'Hospital' THEN 6
    ELSE 7
  END;