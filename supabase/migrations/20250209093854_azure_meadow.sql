-- Drop existing table
DROP TABLE IF EXISTS planning_code_sections;

-- Create table for Planning Code Sections with numeric activity
CREATE TABLE IF NOT EXISTS planning_code_sections (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    systems_of_care text NOT NULL CHECK (systems_of_care IN (
        'Planned care',
        'Unplanned care',
        'Wellness and longevity',
        'Children and young people',
        'Chronic conditions',
        'Complex, multi-morbid',
        'Palliative care and support'
    )),
    care_setting text NOT NULL CHECK (care_setting IN (
        'HOME',
        'HEALTH STATION',
        'AMBULATORY SERVICE CENTER',
        'SPECIALTY CARE CENTER',
        'EXTENDED CARE FACILITY',
        'HOSPITAL'
    )),
    icd_sections text NOT NULL,
    activity numeric(20,2) NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE planning_code_sections ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on planning_code_sections"
    ON planning_code_sections FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on planning_code_sections"
    ON planning_code_sections FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create updated_at trigger
CREATE TRIGGER update_planning_code_sections_updated_at
    BEFORE UPDATE ON planning_code_sections
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

-- Add indexes for better query performance
CREATE INDEX idx_planning_code_sections_systems_of_care 
ON planning_code_sections(systems_of_care);

CREATE INDEX idx_planning_code_sections_care_setting 
ON planning_code_sections(care_setting);

-- Create function to clean activity value
CREATE OR REPLACE FUNCTION clean_activity_value(activity_str text)
RETURNS numeric
LANGUAGE plpgsql
AS $$
BEGIN
    -- Remove commas and convert to numeric
    RETURN replace(activity_str, ',', '')::numeric(20,2);
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Invalid activity value: %', activity_str;
END;
$$;

-- Add comments
COMMENT ON TABLE planning_code_sections IS 'Stores planning code sections for healthcare systems';
COMMENT ON COLUMN planning_code_sections.systems_of_care IS 'The system of care category';
COMMENT ON COLUMN planning_code_sections.care_setting IS 'The care setting type';
COMMENT ON COLUMN planning_code_sections.icd_sections IS 'ICD code section in format like Z00-Z13';
COMMENT ON COLUMN planning_code_sections.activity IS 'The associated activity value';