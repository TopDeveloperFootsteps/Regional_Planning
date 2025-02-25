-- Drop existing table
DROP TABLE IF EXISTS planning_code_sections;

-- Create table for Planning Code Sections with proper array handling
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
    icd_sections text[] NOT NULL DEFAULT ARRAY[]::text[],
    activity text NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CONSTRAINT valid_icd_sections CHECK (array_length(icd_sections, 1) >= 0)
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

-- Insert sample data with properly formatted ICD sections
INSERT INTO planning_code_sections 
(systems_of_care, care_setting, icd_sections, activity)
VALUES
    -- Planned care
    ('Planned care', 'HEALTH STATION', 
     ARRAY['Z00-Z13', 'Z30-Z39', 'Z40-Z54', 'Z80-Z99'],
     'Preventive Care & Health Maintenance'),

    -- Unplanned care
    ('Unplanned care', 'HOSPITAL', 
     ARRAY['S00-S99', 'T00-T88', 'R00-R99'],
     'Emergency & Trauma Care'),

    -- Chronic conditions
    ('Chronic conditions', 'AMBULATORY SERVICE CENTER', 
     ARRAY['E00-E89', 'I00-I99', 'J30-J99', 'K20-K95'],
     'Chronic Disease Management'),

    -- Children and young people
    ('Children and young people', 'SPECIALTY CARE CENTER', 
     ARRAY['P00-P96', 'Q00-Q99', 'Z00.1', 'Z00.11'],
     'Pediatric Care'),

    -- Complex, multi-morbid
    ('Complex, multi-morbid', 'EXTENDED CARE FACILITY', 
     ARRAY['F00-F99', 'G00-G99', 'M00-M99'],
     'Complex Care Management'),

    -- Palliative care
    ('Palliative care and support', 'HOME', 
     ARRAY['Z51.5', 'C00-D48'],
     'Palliative Care'),

    -- Additional planned care
    ('Planned care', 'AMBULATORY SERVICE CENTER', 
     ARRAY['Z01', 'Z02', 'Z03', 'Z04'],
     'Scheduled Examinations'),

    -- Additional chronic conditions
    ('Chronic conditions', 'SPECIALTY CARE CENTER', 
     ARRAY['E10-E14', 'I10-I15', 'J45-J46'],
     'Specialist Disease Management'),

    -- Additional complex care
    ('Complex, multi-morbid', 'HOSPITAL', 
     ARRAY['F20-F29', 'G20-G26', 'I60-I69'],
     'Complex Inpatient Care'),

    -- Additional children's services
    ('Children and young people', 'HEALTH STATION', 
     ARRAY['Z00.12', 'Z00.121', 'Z00.129'],
     'Child Health Surveillance'),

    -- Wellness services
    ('Wellness and longevity', 'AMBULATORY SERVICE CENTER', 
     ARRAY['Z71', 'Z72', 'Z73'],
     'Health Promotion & Education');

-- Add comments
COMMENT ON TABLE planning_code_sections IS 'Stores planning code sections for healthcare systems';
COMMENT ON COLUMN planning_code_sections.systems_of_care IS 'The system of care category';
COMMENT ON COLUMN planning_code_sections.care_setting IS 'The care setting type';
COMMENT ON COLUMN planning_code_sections.icd_sections IS 'Array of ICD code sections, properly formatted';
COMMENT ON COLUMN planning_code_sections.activity IS 'The associated activity';