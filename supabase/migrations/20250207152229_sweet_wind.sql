-- Create table for primary care visit times
CREATE TABLE IF NOT EXISTS primary_care_visit_times (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL DEFAULT 'Primary Care',
    reason_for_visit text NOT NULL,
    new_visit_duration integer NOT NULL CHECK (new_visit_duration > 0),
    follow_up_visit_duration integer NOT NULL CHECK (follow_up_visit_duration > 0),
    percent_new_visits integer NOT NULL CHECK (percent_new_visits BETWEEN 0 AND 100),
    average_visit_duration numeric GENERATED ALWAYS AS (
        (new_visit_duration * percent_new_visits + 
         follow_up_visit_duration * (100 - percent_new_visits)) / 100.0
    ) STORED,
    source text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create table for specialist outpatient visit times
CREATE TABLE IF NOT EXISTS specialist_visit_times (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL DEFAULT 'Specialist Outpatient Care',
    reason_for_visit text NOT NULL,
    new_visit_duration integer NOT NULL CHECK (new_visit_duration > 0),
    follow_up_visit_duration integer NOT NULL CHECK (follow_up_visit_duration > 0),
    percent_new_visits integer NOT NULL CHECK (percent_new_visits BETWEEN 0 AND 100),
    source text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create table for occupancy rates
CREATE TABLE IF NOT EXISTS occupancy_rates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    inperson_rate integer NOT NULL CHECK (inperson_rate BETWEEN 0 AND 100),
    virtual_rate integer CHECK (virtual_rate BETWEEN 0 AND 100),
    source text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(care_setting)
);

-- Enable RLS
ALTER TABLE primary_care_visit_times ENABLE ROW LEVEL SECURITY;
ALTER TABLE specialist_visit_times ENABLE ROW LEVEL SECURITY;
ALTER TABLE occupancy_rates ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on primary_care_visit_times"
    ON primary_care_visit_times FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on primary_care_visit_times"
    ON primary_care_visit_times FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable read access for all users on specialist_visit_times"
    ON specialist_visit_times FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on specialist_visit_times"
    ON specialist_visit_times FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable read access for all users on occupancy_rates"
    ON occupancy_rates FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on occupancy_rates"
    ON occupancy_rates FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create updated_at triggers
CREATE TRIGGER update_primary_care_visit_times_updated_at
    BEFORE UPDATE ON primary_care_visit_times
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

CREATE TRIGGER update_specialist_visit_times_updated_at
    BEFORE UPDATE ON specialist_visit_times
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

CREATE TRIGGER update_occupancy_rates_updated_at
    BEFORE UPDATE ON occupancy_rates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

-- Insert initial data for primary care visit times
INSERT INTO primary_care_visit_times 
(reason_for_visit, new_visit_duration, follow_up_visit_duration, percent_new_visits, source)
VALUES
    ('Primary dental care', 30, 20, 10, 'BMJ'),
    ('Routine health checks', 30, 20, 15, 'BMJ'),
    ('Acute & urgent care', 30, 20, 20, 'BMJ'),
    ('Chronic metabolic diseases', 30, 20, 25, 'BMJ'),
    ('Chronic respiratory diseases', 30, 20, 30, 'BMJ'),
    ('Chronic mental health disorders', 30, 20, 35, 'BMJ'),
    ('Other chronic diseases', 30, 20, 40, 'BMJ'),
    ('Complex condition / Frail elderly', 30, 20, 45, 'BMJ'),
    ('Maternal Care', 30, 20, 50, 'BMJ'),
    ('Well baby care (0 to 4)', 30, 20, 55, 'BMJ'),
    ('Paediatric care (5 to 16)', 30, 20, 60, 'BMJ'),
    ('Allied Health & Health Promotion', 30, 20, 65, 'BMJ');

-- Insert initial data for specialist visit times
INSERT INTO specialist_visit_times 
(reason_for_visit, new_visit_duration, follow_up_visit_duration, percent_new_visits, source)
VALUES
    ('General Surgery', 30, 20, 45, 'BMJ'),
    ('Urology', 30, 20, 31, 'BMJ'),
    ('Vascular Surgery', 30, 20, 47, 'BMJ'),
    ('Otolaryngology / ENT', 30, 20, 43, 'BMJ'),
    ('Ophthalmology', 30, 20, 26, 'BMJ'),
    ('Dentistry', 60, 60, 8, 'BMJ'),
    ('Plastics (incl. Burns and Maxillofacial)', 30, 20, 33, 'BMJ'),
    ('Paediatric Surgery', 30, 20, 38, 'BMJ'),
    ('Trauma and Emergency Medicine', 30, 20, 73, 'BMJ'),
    ('Anesthesiology', 30, 20, 36, 'BMJ'),
    ('Critical Care Medicine', 30, 20, 38, 'BMJ'),
    ('Gastroenterology', 30, 20, 34, 'BMJ'),
    ('Endocrinology', 30, 20, 21, 'BMJ'),
    ('Haematology', 30, 20, 10, 'BMJ'),
    ('Medical Genetics', 30, 20, 61, 'BMJ'),
    ('Neurosurgery', 30, 20, 32, 'BMJ'),
    ('Cardiothoracic & Cardiovascular Surgery', 30, 20, 28, 'BMJ'),
    ('Internal Medicine', 30, 20, 58, 'BMJ'),
    ('Allergy and Immunology', 30, 20, 42, 'BMJ'),
    ('Physical Medicine and Rehabilitation', 60, 60, 35, 'BMJ'),
    ('Hospice and Palliative Care', 30, 20, 19, 'BMJ'),
    ('Cardiology', 30, 20, 42, 'BMJ'),
    ('Paediatric Medicine', 30, 20, 37, 'BMJ'),
    ('Dermatology', 30, 20, 57, 'BMJ'),
    ('Pulmonology / Respiratory Medicine', 30, 20, 31, 'BMJ'),
    ('Infectious Diseases', 30, 20, 48, 'BMJ'),
    ('Sexual & Reproductive Health / Genitourinary Medicine (GUM)', 30, 20, 14, 'BMJ'),
    ('Nephrology', 30, 20, 10, 'BMJ'),
    ('Oncology', 30, 20, 11, 'BMJ'),
    ('Nuclear Medicine', 30, 20, 52, 'BMJ'),
    ('Neurology (inc. neurophysiology and neuropathology)', 30, 20, 33, 'BMJ'),
    ('Rheumatology', 30, 20, 17, 'BMJ'),
    ('Elderly Care / Geriatrics', 30, 20, 49, 'BMJ'),
    ('Obstetrics & Gynaecology', 30, 20, 35, 'BMJ'),
    ('Psychiatry', 60, 60, 17, 'BMJ'),
    ('Social, Community and Preventative Medicine', 30, 20, 39, 'BMJ'),
    ('Other', 25, 25, 31, 'BMJ'),
    ('Orthopaedics (inc. podiatry)', 30, 20, 36, 'BMJ');

-- Insert initial data for occupancy rates
INSERT INTO occupancy_rates 
(care_setting, inperson_rate, virtual_rate, source)
VALUES
    ('Primary Care', 70, 90, 'BMJ'),
    ('Specialist Outpatient Care', 70, 90, 'BMJ'),
    ('Emergency Care', 90, 90, 'BMJ'),
    ('Major Diagnostic & Treatment', 70, NULL, 'No source available'),
    ('Day Cases', 70, 90, 'No source available'),
    ('Medical Inpatients', 85, 90, 'BMJ'),
    ('Elective Inpatients', 85, 90, 'BMJ'),
    ('Surgical Emergencies', 85, 90, 'BMJ');