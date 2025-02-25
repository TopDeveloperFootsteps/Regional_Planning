/*
  # Create home_sm table

  1. New Table
    - home_sm
      - id (uuid, primary key)
      - icd_code (text)
      - systems_of_care (text)
      - service (text)
      - confidence (text)
      - mapping_logic (text)
      - created_at (timestamptz)

  2. Security
    - Enable RLS
    - Add public read access policy
*/

-- Create home_sm table
CREATE TABLE IF NOT EXISTS home_sm (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    icd_code text NOT NULL,
    systems_of_care text NOT NULL,
    service text NOT NULL,
    confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
    mapping_logic text NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE home_sm ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access on home_sm"
    ON home_sm
    FOR SELECT
    TO public
    USING (true);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_home_sm_icd_code 
ON home_sm (icd_code);

CREATE INDEX IF NOT EXISTS idx_home_sm_systems_of_care
ON home_sm (systems_of_care);