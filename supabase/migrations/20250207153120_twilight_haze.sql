-- Create table for specialty-specific occupancy rates
CREATE TABLE IF NOT EXISTS specialty_occupancy_rates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    specialty text NOT NULL,
    virtual_rate decimal(5,4) NOT NULL CHECK (virtual_rate BETWEEN 0 AND 1),
    inperson_rate decimal(5,4) NOT NULL CHECK (inperson_rate BETWEEN 0 AND 1),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(care_setting, specialty)
);

-- Enable RLS
ALTER TABLE specialty_occupancy_rates ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on specialty_occupancy_rates"
    ON specialty_occupancy_rates FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on specialty_occupancy_rates"
    ON specialty_occupancy_rates FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create updated_at trigger
CREATE TRIGGER update_specialty_occupancy_rates_updated_at
    BEFORE UPDATE ON specialty_occupancy_rates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

-- Insert initial data
INSERT INTO specialty_occupancy_rates 
(care_setting, specialty, virtual_rate, inperson_rate)
VALUES
    -- Primary Care
    ('Primary Care', 'Primary dental care', 0.097, 0.903),
    ('Primary Care', 'Routine health checks', 0.57, 0.43),
    ('Primary Care', 'Acute & urgent care', 0.36, 0.64),
    ('Primary Care', 'Chronic metabolic diseases', 0.35, 0.65),
    ('Primary Care', 'Chronic respiratory diseases', 0.35, 0.65),
    ('Primary Care', 'Chronic mental health disorders', 0.516, 0.484),
    ('Primary Care', 'Other chronic diseases', 0.35, 0.65),
    ('Primary Care', 'Complex condition / Frail elderly', 0.35, 0.65),
    ('Primary Care', 'Maternal Care', 0.42, 0.58),
    ('Primary Care', 'Well baby care (0 to 4)', 0.35, 0.65),
    ('Primary Care', 'Paediatric care (5 to 16)', 0.35, 0.65),
    ('Primary Care', 'Allied Health & Health Promotion', 0.35, 0.65),

    -- Specialist Outpatient Care
    ('Specialist Outpatient Care', 'General Surgery', 0.09, 0.91),
    ('Specialist Outpatient Care', 'Urology', 0.13, 0.87),
    ('Specialist Outpatient Care', 'Vascular Surgery', 0.13, 0.87),
    ('Specialist Outpatient Care', 'Otolaryngology / ENT', 0.17, 0.83),
    ('Specialist Outpatient Care', 'Ophthalmology', 0.07, 0.93),
    ('Specialist Outpatient Care', 'Dentistry', 0.13, 0.87),
    ('Specialist Outpatient Care', 'Plastics (incl. Burns and Maxillofacial)', 0.17, 0.83),
    ('Specialist Outpatient Care', 'Paediatric Surgery', 0.25, 0.75),
    ('Specialist Outpatient Care', 'Trauma and Emergency Medicine', 0.25, 0.75),
    ('Specialist Outpatient Care', 'Anesthesiology', 0.35, 0.65),
    ('Specialist Outpatient Care', 'Critical Care Medicine', 0.3, 0.7),
    ('Specialist Outpatient Care', 'Gastroenterology', 0.18, 0.82),
    ('Specialist Outpatient Care', 'Endocrinology', 0.22, 0.78),
    ('Specialist Outpatient Care', 'Haematology', 0.17, 0.83),
    ('Specialist Outpatient Care', 'Medical Genetics', 0.4, 0.6),
    ('Specialist Outpatient Care', 'Neurosurgery', 0.09, 0.91),
    ('Specialist Outpatient Care', 'Cardiothoracic & Cardiovascular Surgery', 0.13, 0.87),
    ('Specialist Outpatient Care', 'Internal Medicine', 0.22, 0.78),
    ('Specialist Outpatient Care', 'Allergy and Immunology', 0.26, 0.74),
    ('Specialist Outpatient Care', 'Physical Medicine and Rehabilitation', 0.14, 0.86),
    ('Specialist Outpatient Care', 'Hospice and Palliative Care', 0.22, 0.78),
    ('Specialist Outpatient Care', 'Cardiology', 0.13, 0.87),
    ('Specialist Outpatient Care', 'Paediatric Medicine', 0.12, 0.88),
    ('Specialist Outpatient Care', 'Dermatology', 0.48, 0.52),
    ('Specialist Outpatient Care', 'Pulmonology / Respiratory Medicine', 0.16, 0.84),
    ('Specialist Outpatient Care', 'Infectious Diseases', 0.14, 0.86),
    ('Specialist Outpatient Care', 'Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 0.12, 0.88),
    ('Specialist Outpatient Care', 'Nephrology', 0.13, 0.87),
    ('Specialist Outpatient Care', 'Oncology', 0.13, 0.87),
    ('Specialist Outpatient Care', 'Neurology (inc. neurophysiology and neuropathology)', 0.18, 0.82),
    ('Specialist Outpatient Care', 'Rheumatology', 0.22, 0.78),
    ('Specialist Outpatient Care', 'Elderly Care / Geriatrics', 0.26, 0.74),
    ('Specialist Outpatient Care', 'Obstetrics & Gynaecology', 0.12, 0.88),
    ('Specialist Outpatient Care', 'Psychiatry', 0.55, 0.45),
    ('Specialist Outpatient Care', 'Social, Community and Preventative Medicine', 0.22, 0.78),
    ('Specialist Outpatient Care', 'Other', 0.22, 0.78),
    ('Specialist Outpatient Care', 'Orthopaedics (inc. podiatry)', 0.07, 0.93),

    -- Emergency Care
    ('Emergency Care', 'Major Emergency', 0.05, 0.95),
    ('Emergency Care', 'Minor Emergency', 0.15, 0.85);