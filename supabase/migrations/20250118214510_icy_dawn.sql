/*
  # Update encounters table to use decimal type

  1. Changes
    - Change "number of encounters" column type from integer to numeric
    - Keep all other columns and settings the same

  2. Security
    - Maintain existing RLS policies
*/

-- Drop existing table
DROP TABLE IF EXISTS encounters;

-- Create encounters table with decimal type for encounters
CREATE TABLE IF NOT EXISTS encounters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "care setting" text NOT NULL,
    "system of care" text NOT NULL,
    "icd family code" text NOT NULL,
    "number of encounters" numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE encounters ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access on encounters"
    ON encounters
    FOR SELECT
    TO public
    USING (true);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_encounters_care_setting
    ON encounters ("care setting");

CREATE INDEX IF NOT EXISTS idx_encounters_system_of_care
    ON encounters ("system of care");

CREATE INDEX IF NOT EXISTS idx_encounters_icd_family_code
    ON encounters ("icd family code");