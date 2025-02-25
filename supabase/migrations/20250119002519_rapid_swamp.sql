-- Create care setting optimization table
CREATE TABLE IF NOT EXISTS care_setting_optimization_data (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    current_encounters integer NOT NULL,
    current_percentage integer NOT NULL,
    shift_potential integer NOT NULL,
    potential_shift_percentage integer NOT NULL,
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

-- Insert sample data
INSERT INTO care_setting_optimization_data 
(care_setting, current_encounters, current_percentage, shift_potential, potential_shift_percentage, optimization_strategy)
VALUES
    ('Home', 25000, 15, 0, 0, 'Already optimal setting - focus on maintaining and enhancing home care capabilities'),
    ('Health Station', 35000, 20, 5250, 15, 'Potential for home-based care through remote monitoring and telehealth'),
    ('Ambulatory Service Center', 45000, 25, 11250, 25, 'Opportunity for care delivery in home or health station settings with proper support'),
    ('Specialty Care Center', 30000, 18, 3000, 10, 'Some cases manageable in primary care settings with specialist oversight'),
    ('Extended Care Facility', 20000, 12, 1000, 5, 'Select cases suitable for home care with support'),
    ('Hospital', 15000, 10, 750, 5, 'Some cases manageable in lower acuity settings with proper support');

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_care_setting_optimization_care_setting
    ON care_setting_optimization_data (care_setting);

CREATE INDEX IF NOT EXISTS idx_care_setting_optimization_current_encounters
    ON care_setting_optimization_data (current_encounters);