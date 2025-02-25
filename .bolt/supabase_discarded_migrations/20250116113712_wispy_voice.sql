-- Drop existing table and related objects
DROP TABLE IF EXISTS care_settings_encounters CASCADE;

-- Create new table with specified structure
CREATE TABLE care_settings_encounters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting VARCHAR(255) NOT NULL,
    systems_of_care VARCHAR(255) NOT NULL,
    icd_family_code VARCHAR(50) NOT NULL,
    encounters INTEGER NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE care_settings_encounters ENABLE ROW LEVEL SECURITY;

-- Drop any existing policies
DROP POLICY IF EXISTS "Allow public read access on care_settings_encounters" ON care_settings_encounters;

-- Create policies for authenticated users
CREATE POLICY "Allow select for authenticated users"
    ON care_settings_encounters
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow insert for authenticated users"
    ON care_settings_encounters
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Allow update for authenticated users"
    ON care_settings_encounters
    FOR UPDATE
    TO authenticated
    USING (true);

CREATE POLICY "Allow delete for authenticated users"
    ON care_settings_encounters
    FOR DELETE
    TO authenticated
    USING (true);

-- Create indexes for better performance
CREATE INDEX idx_care_settings_encounters_care_setting 
ON care_settings_encounters (care_setting);

CREATE INDEX idx_care_settings_encounters_systems_of_care 
ON care_settings_encounters (systems_of_care);

CREATE INDEX idx_care_settings_encounters_icd_family_code 
ON care_settings_encounters (icd_family_code);

-- Add table comments
COMMENT ON TABLE care_settings_encounters IS 'Stores encounter data for ICD codes across different care settings';
COMMENT ON COLUMN care_settings_encounters.care_setting IS 'The healthcare setting where the encounter occurred';
COMMENT ON COLUMN care_settings_encounters.systems_of_care IS 'The system of care category';
COMMENT ON COLUMN care_settings_encounters.icd_family_code IS 'The ICD-10 family code';
COMMENT ON COLUMN care_settings_encounters.encounters IS 'Number of encounters for this combination';