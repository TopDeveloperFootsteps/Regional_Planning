-- Clear existing data
DELETE FROM care_setting_optimization_data;

-- Insert updated data with correct current percentages
WITH encounter_stats AS (
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
    SUM("number of encounters") as total_encounters,
    ROUND((SUM("number of encounters") * 100.0 / (SELECT SUM("number of encounters") FROM encounters))::numeric, 0) as current_percentage
  FROM encounters
  GROUP BY "care setting"
)
INSERT INTO care_setting_optimization_data 
(care_setting, current_encounters, current_percentage, shift_potential, shift_direction, 
 potential_shift_percentage, proposed_percentage, potential_encounters_change, optimization_strategy)
SELECT 
    e.care_setting,
    e.total_encounters,
    e.current_percentage,
    -- Calculate shift potential based on current volume
    CASE e.care_setting
        WHEN 'Home' THEN FLOOR(e.total_encounters * 0.0) -- Receiving only
        WHEN 'Health Station' THEN FLOOR(e.total_encounters * 0.15)
        WHEN 'Ambulatory Service Center' THEN FLOOR(e.total_encounters * 0.25)
        WHEN 'Specialty Care Center' THEN FLOOR(e.total_encounters * 0.20)
        WHEN 'Extended Care Facility' THEN FLOOR(e.total_encounters * 0.15)
        WHEN 'Hospital' THEN FLOOR(e.total_encounters * 0.30)
    END as shift_potential,
    -- Direction of shift
    CASE e.care_setting
        WHEN 'Home' THEN 'Receiving'
        WHEN 'Health Station' THEN 'Both'
        ELSE 'Outward'
    END as shift_direction,
    -- Potential shift percentage
    CASE e.care_setting
        WHEN 'Home' THEN 0
        WHEN 'Health Station' THEN 15
        WHEN 'Ambulatory Service Center' THEN 25
        WHEN 'Specialty Care Center' THEN 20
        WHEN 'Extended Care Facility' THEN 15
        WHEN 'Hospital' THEN 30
    END as potential_shift_percentage,
    -- Calculate proposed percentage
    CASE e.care_setting
        WHEN 'Home' THEN e.current_percentage + 15 -- Receive shifted volume
        WHEN 'Health Station' THEN e.current_percentage - 5 -- Net change after shifts
        WHEN 'Ambulatory Service Center' THEN e.current_percentage - 10
        WHEN 'Specialty Care Center' THEN e.current_percentage - 8
        WHEN 'Extended Care Facility' THEN e.current_percentage - 5
        WHEN 'Hospital' THEN e.current_percentage - 7
    END as proposed_percentage,
    -- Calculate encounter changes
    CASE e.care_setting
        WHEN 'Home' THEN FLOOR(e.total_encounters * 0.15) -- Receiving volume
        WHEN 'Health Station' THEN -FLOOR(e.total_encounters * 0.05)
        WHEN 'Ambulatory Service Center' THEN -FLOOR(e.total_encounters * 0.10)
        WHEN 'Specialty Care Center' THEN -FLOOR(e.total_encounters * 0.08)
        WHEN 'Extended Care Facility' THEN -FLOOR(e.total_encounters * 0.05)
        WHEN 'Hospital' THEN -FLOOR(e.total_encounters * 0.07)
    END as potential_encounters_change,
    -- Optimization strategies
    CASE e.care_setting
        WHEN 'Home' THEN 'Primary target for care shift - Increase telemedicine capabilities for chronic condition monitoring, routine follow-ups, and stable patient management. Focus on remote patient monitoring for vital signs and medication adherence.'
        WHEN 'Health Station' THEN 'Optimize through enhanced primary care capabilities - Strengthen telemedicine infrastructure to support remote specialist consultations. Ideal for stable chronic conditions and routine care that requires basic physical examination.'
        WHEN 'Ambulatory Service Center' THEN 'Shift suitable cases to lower acuity settings - Identify stable patients with well-managed conditions for home monitoring. Implement specialist oversight programs for remote management of suitable cases.'
        WHEN 'Specialty Care Center' THEN 'Reduce unnecessary specialty visits - Transfer stable patients to ambulatory care with specialist oversight. Implement clear pathways for remote consultations and telemedicine follow-ups.'
        WHEN 'Extended Care Facility' THEN 'Enhance home care capabilities - Develop comprehensive home care programs with remote monitoring for suitable patients. Focus on family support and telemedicine for ongoing management.'
        WHEN 'Hospital' THEN 'Maximize appropriate outpatient care - Shift suitable post-acute care to lower acuity settings. Implement remote monitoring for early discharge cases with proper support systems.'
    END as optimization_strategy
FROM encounter_stats e;