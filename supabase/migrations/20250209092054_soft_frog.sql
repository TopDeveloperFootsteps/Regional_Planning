-- Create table for Planning Code Sections
CREATE TABLE IF NOT EXISTS planning_code_sections (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    systems_of_care text NOT NULL,
    care_setting text NOT NULL,
    icd_sections text[] NOT NULL,
    activity text NOT NULL,
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

-- Add comments
COMMENT ON TABLE planning_code_sections IS 'Stores planning code sections for healthcare systems';
COMMENT ON COLUMN planning_code_sections.systems_of_care IS 'The system of care category';
COMMENT ON COLUMN planning_code_sections.care_setting IS 'The care setting type';
COMMENT ON COLUMN planning_code_sections.icd_sections IS 'Array of ICD code sections';
COMMENT ON COLUMN planning_code_sections.activity IS 'The associated activity';