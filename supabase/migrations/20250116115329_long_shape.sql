/*
  # Create care settings encounters table

  1. New Table
    - care_settings_encounters
      - id (uuid, primary key)
      - care_setting (text)
      - systems_of_care (text)
      - icd_family_code (text)
      - encounters (integer)
      - created_at (timestamptz)

  2. Security
    - Enable RLS
    - Add public read access policy
*/

-- Create care_settings_encounters table
CREATE TABLE IF NOT EXISTS care_settings_encounters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    systems_of_care text NOT NULL,
    icd_family_code text NOT NULL,
    encounters integer NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE care_settings_encounters ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access on care_settings_encounters"
    ON care_settings_encounters
    FOR SELECT
    TO public
    USING (true);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_care_settings_encounters_care_setting
    ON care_settings_encounters (care_setting);

CREATE INDEX IF NOT EXISTS idx_care_settings_encounters_icd_code
    ON care_settings_encounters (icd_family_code);

CREATE INDEX IF NOT EXISTS idx_care_settings_encounters_systems_of_care
    ON care_settings_encounters (systems_of_care);