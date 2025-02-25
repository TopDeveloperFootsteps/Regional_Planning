-- Create table for Planning Family Code
CREATE TABLE IF NOT EXISTS planning_family_code (
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
    icd_family text NOT NULL,
    activity numeric(20,2) NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE planning_family_code ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on planning_family_code"
    ON planning_family_code FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on planning_family_code"
    ON planning_family_code FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create updated_at trigger
CREATE TRIGGER update_planning_family_code_updated_at
    BEFORE UPDATE ON planning_family_code
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

-- Add indexes for better query performance
CREATE INDEX idx_planning_family_code_systems_of_care 
ON planning_family_code(systems_of_care);

CREATE INDEX idx_planning_family_code_care_setting 
ON planning_family_code(care_setting);

CREATE INDEX idx_planning_family_code_icd_family
ON planning_family_code(icd_family);

-- Add comments
COMMENT ON TABLE planning_family_code IS 'Stores planning code families for healthcare systems';
COMMENT ON COLUMN planning_family_code.systems_of_care IS 'The system of care category';
COMMENT ON COLUMN planning_family_code.care_setting IS 'The care setting type';
COMMENT ON COLUMN planning_family_code.icd_family IS 'ICD family code';
COMMENT ON COLUMN planning_family_code.activity IS 'The associated activity value';