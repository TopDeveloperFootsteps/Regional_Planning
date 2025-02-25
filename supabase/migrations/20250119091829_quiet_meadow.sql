-- Drop existing table
DROP TABLE IF EXISTS care_setting_optimization_data;

-- Create new table
CREATE TABLE care_setting_optimization_data (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    current_encounters integer NOT NULL,
    current_percentage integer NOT NULL,
    shift_potential integer NOT NULL,
    shift_direction text NOT NULL,
    potential_shift_percentage integer NOT NULL,
    proposed_percentage integer NOT NULL,
    potential_encounters_change integer NOT NULL,
    optimization_strategy text NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE care_setting_optimization_data ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access on care_setting_optimization_data"
    ON care_setting_optimization_data
    FOR SELECT
    TO public
    USING (true);

-- Insert updated data based on actual encounter statistics
WITH encounter_stats AS (
  SELECT 
    "care setting",
    FLOOR(SUM("number of encounters")) as total_encounters,
    FLOOR(SUM("number of encounters") * 100.0 / (SELECT SUM("number of encounters") FROM encounters)) as current_percentage
  FROM encounters
  GROUP BY "care setting"
),
shift_calculations AS (
  SELECT 
    e."care setting",
    e.total_encounters,
    e.current_percentage,
    CASE 
      WHEN e."care setting" = 'HOME' THEN 0
      WHEN e."care setting" = 'HEALTH STATION' THEN FLOOR(e.total_encounters * 0.15)
      WHEN e."care setting" = 'AMBULATORY SERVICE CENTER' THEN FLOOR(e.total_encounters * 0.25)
      WHEN e."care setting" = 'SPECIALTY CARE CENTER' THEN FLOOR(e.total_encounters * 0.10)
      WHEN e."care setting" = 'EXTENDED CARE FACILITY' THEN FLOOR(e.total_encounters * 0.05)
      WHEN e."care setting" = 'HOSPITAL' THEN FLOOR(e.total_encounters * 0.05)
      ELSE 0
    END as shift_potential,
    CASE 
      WHEN e."care setting" = 'HOME' THEN 'Receiving'
      WHEN e."care setting" = 'HEALTH STATION' THEN 'Both'
      ELSE 'Outward'
    END as shift_direction
  FROM encounter_stats e
),
total_shifts AS (
  SELECT SUM(shift_potential) as total_shifted_encounters
  FROM shift_calculations
  WHERE shift_direction = 'Outward'
)
INSERT INTO care_setting_optimization_data 
(care_setting, current_encounters, current_percentage, shift_potential, shift_direction, 
 potential_shift_percentage, proposed_percentage, potential_encounters_change, optimization_strategy)
SELECT 
    CASE sc."care setting"
        WHEN 'HEALTH STATION' THEN 'Health Station'
        WHEN 'HOME' THEN 'Home'
        WHEN 'AMBULATORY SERVICE CENTER' THEN 'Ambulatory Service Center'
        WHEN 'SPECIALTY CARE CENTER' THEN 'Specialty Care Center'
        WHEN 'EXTENDED CARE FACILITY' THEN 'Extended Care Facility'
        WHEN 'HOSPITAL' THEN 'Hospital'
        ELSE sc."care setting"
    END as care_setting,
    sc.total_encounters as current_encounters,
    sc.current_percentage as current_percentage,
    sc.shift_potential,
    sc.shift_direction,
    CASE 
        WHEN sc."care setting" = 'HOME' THEN 0
        WHEN sc."care setting" = 'HEALTH STATION' THEN 15
        WHEN sc."care setting" = 'AMBULATORY SERVICE CENTER' THEN 25
        WHEN sc."care setting" = 'SPECIALTY CARE CENTER' THEN 10
        WHEN sc."care setting" = 'EXTENDED CARE FACILITY' THEN 5
        WHEN sc."care setting" = 'HOSPITAL' THEN 5
        ELSE 0
    END as potential_shift_percentage,
    -- Calculate proposed percentage ensuring total equals 100%
    CASE 
        WHEN sc.shift_direction = 'Receiving' THEN 
            sc.current_percentage + FLOOR(100.0 * ts.total_shifted_encounters / (SELECT SUM(total_encounters) FROM encounter_stats))
        WHEN sc.shift_direction = 'Both' THEN 
            sc.current_percentage
        ELSE 
            sc.current_percentage - FLOOR(100.0 * sc.shift_potential / (SELECT SUM(total_encounters) FROM encounter_stats))
    END as proposed_percentage,
    CASE 
        WHEN sc.shift_direction = 'Receiving' THEN sc.shift_potential
        WHEN sc.shift_direction = 'Both' THEN 0
        ELSE -sc.shift_potential
    END as potential_encounters_change,
    CASE 
        WHEN sc."care setting" = 'HOME' THEN 'Primary target for care shift - can receive cases from other settings through enhanced home care capabilities'
        WHEN sc."care setting" = 'HEALTH STATION' THEN 'Optimize through bidirectional shift - transfer suitable cases to home care while receiving from higher acuity'
        WHEN sc."care setting" = 'AMBULATORY SERVICE CENTER' THEN 'Focus on identifying cases suitable for lower acuity settings with proper support systems'
        WHEN sc."care setting" = 'SPECIALTY CARE CENTER' THEN 'Implement specialist oversight programs for cases manageable in primary care settings'
        WHEN sc."care setting" = 'EXTENDED CARE FACILITY' THEN 'Develop home care transition programs for suitable cases with adequate support'
        WHEN sc."care setting" = 'HOSPITAL' THEN 'Create pathways for managing appropriate cases in lower acuity settings with proper monitoring'
        ELSE 'Standard optimization approach'
    END as optimization_strategy
FROM shift_calculations sc, total_shifts ts;