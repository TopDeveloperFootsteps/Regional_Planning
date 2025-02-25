/*
  # Verify Care Settings Encounters Table

  1. Verification
    - Check if table exists
    - Add any missing indexes
    - Create additional views for data analysis
*/

-- Verify table exists and create if not exists (idempotent)
CREATE TABLE IF NOT EXISTS care_settings_encounters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    systems_of_care text NOT NULL,
    icd_family_code text NOT NULL,
    encounters integer NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- Ensure RLS is enabled
ALTER TABLE care_settings_encounters ENABLE ROW LEVEL SECURITY;

-- Ensure policy exists
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_policies 
        WHERE tablename = 'care_settings_encounters' 
        AND policyname = 'Allow public read access on care_settings_encounters'
    ) THEN
        CREATE POLICY "Allow public read access on care_settings_encounters"
            ON care_settings_encounters
            FOR SELECT
            TO public
            USING (true);
    END IF;
END $$;

-- Create additional views for data analysis
CREATE OR REPLACE VIEW encounter_summary_by_care_setting AS
SELECT 
    care_setting,
    COUNT(DISTINCT icd_family_code) as unique_codes,
    COUNT(*) as total_records,
    SUM(encounters) as total_encounters,
    ROUND(AVG(encounters)::numeric, 2) as avg_encounters,
    MAX(encounters) as max_encounters
FROM care_settings_encounters
GROUP BY care_setting
ORDER BY care_setting;

CREATE OR REPLACE VIEW encounter_summary_by_system AS
SELECT 
    systems_of_care,
    COUNT(DISTINCT icd_family_code) as unique_codes,
    COUNT(*) as total_records,
    SUM(encounters) as total_encounters,
    ROUND(AVG(encounters)::numeric, 2) as avg_encounters,
    MAX(encounters) as max_encounters
FROM care_settings_encounters
GROUP BY systems_of_care
ORDER BY systems_of_care;

-- Create a view for top ICD codes by encounters
CREATE OR REPLACE VIEW top_icd_codes_by_encounters AS
SELECT 
    icd_family_code,
    care_setting,
    systems_of_care,
    encounters,
    RANK() OVER (PARTITION BY care_setting ORDER BY encounters DESC) as rank_in_setting
FROM care_settings_encounters
WHERE encounters > 0
ORDER BY encounters DESC, care_setting, icd_family_code
LIMIT 100;