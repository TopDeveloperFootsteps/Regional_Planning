/*
  # Create encounters table

  1. New Tables
    - `encounters`
      - `id` (uuid, primary key)
      - `care_setting` (text)
      - `system_of_care` (text)
      - `icd_family_code` (text)
      - `number_of_encounters` (integer)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `encounters` table
    - Add policy for public read access
    - Add indexes for better query performance
*/

-- Create encounters table
CREATE TABLE IF NOT EXISTS encounters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    system_of_care text NOT NULL,
    icd_family_code text NOT NULL,
    number_of_encounters integer NOT NULL DEFAULT 0,
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
    ON encounters (care_setting);

CREATE INDEX IF NOT EXISTS idx_encounters_system_of_care
    ON encounters (system_of_care);

CREATE INDEX IF NOT EXISTS idx_encounters_icd_family_code
    ON encounters (icd_family_code);

-- Add some sample data
INSERT INTO encounters (care_setting, system_of_care, icd_family_code, number_of_encounters)
VALUES
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'Z23', 150),
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'Z20', 85),
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'Z00', 200),
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'Z03', 75),
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'M25', 120),
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'J30', 95),
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'Z02', 180),
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'J02', 110),
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'J06', 130),
    ('AMBULATORY SERVICE CENTER', 'Children and young people', 'F80', 90);