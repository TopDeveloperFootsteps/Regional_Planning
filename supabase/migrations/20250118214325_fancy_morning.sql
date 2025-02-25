/*
  # Fix encounters table column names

  1. Changes
    - Rename columns to match CSV headers exactly
    - Remove sample data since it's not needed

  2. Security
    - Maintain existing RLS policies
*/

-- Drop existing table
DROP TABLE IF EXISTS encounters;

-- Create encounters table with correct column names
CREATE TABLE IF NOT EXISTS encounters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "care setting" text NOT NULL,
    "system of care" text NOT NULL,
    "icd family code" text NOT NULL,
    "number of encounters" integer NOT NULL DEFAULT 0,
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