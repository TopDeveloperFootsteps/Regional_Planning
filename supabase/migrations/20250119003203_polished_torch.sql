-- Drop existing table
DROP TABLE IF EXISTS care_setting_optimization_data;

-- Create updated care setting optimization table
CREATE TABLE IF NOT EXISTS care_setting_optimization_data (
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

-- Insert updated sample data with shift calculations
INSERT INTO care_setting_optimization_data 
(care_setting, current_encounters, current_percentage, shift_potential, shift_direction, potential_shift_percentage, proposed_percentage, potential_encounters_change, optimization_strategy)
VALUES
    ('Home', 25000, 15, 0, 'Receiving', 0, 25, 16500, 'Primary target for care shift - can receive cases from other settings through enhanced home care capabilities'),
    ('Health Station', 35000, 20, 5250, 'Both', 15, 15, -5250, 'Optimize through bidirectional shift - transfer suitable cases to home care while receiving from higher acuity'),
    ('Ambulatory Service Center', 45000, 25, 11250, 'Outward', 25, 15, -11250, 'Focus on identifying cases suitable for lower acuity settings with proper support systems'),
    ('Specialty Care Center', 30000, 18, 3000, 'Outward', 10, 16, -3000, 'Implement specialist oversight programs for cases manageable in primary care settings'),
    ('Extended Care Facility', 20000, 12, 1000, 'Outward', 5, 11, -1000, 'Develop home care transition programs for suitable cases with adequate support'),
    ('Hospital', 15000, 10, 750, 'Outward', 5, 8, -750, 'Create pathways for managing appropriate cases in lower acuity settings with proper monitoring');

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_care_setting_optimization_care_setting
    ON care_setting_optimization_data (care_setting);

CREATE INDEX IF NOT EXISTS idx_care_setting_optimization_current_encounters
    ON care_setting_optimization_data (current_encounters);