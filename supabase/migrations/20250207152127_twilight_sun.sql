-- Create table for available days per year
CREATE TABLE IF NOT EXISTS available_days_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    working_days_per_week integer NOT NULL CHECK (working_days_per_week BETWEEN 1 AND 7),
    working_weeks_per_year integer NOT NULL CHECK (working_weeks_per_year BETWEEN 1 AND 52),
    available_days_per_year integer NOT NULL CHECK (available_days_per_year BETWEEN 1 AND 366),
    source text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create table for working hours
CREATE TABLE IF NOT EXISTS working_hours_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    working_hours_per_day integer NOT NULL CHECK (working_hours_per_day BETWEEN 1 AND 24),
    source text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE available_days_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE working_hours_settings ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on available_days_settings"
    ON available_days_settings FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on available_days_settings"
    ON available_days_settings FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable read access for all users on working_hours_settings"
    ON working_hours_settings FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on working_hours_settings"
    ON working_hours_settings FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_available_days_settings_updated_at
    BEFORE UPDATE ON available_days_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

CREATE TRIGGER update_working_hours_settings_updated_at
    BEFORE UPDATE ON working_hours_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

-- Insert initial data for available days
INSERT INTO available_days_settings 
(care_setting, working_days_per_week, working_weeks_per_year, available_days_per_year, source)
VALUES
    ('Primary Care', 6, 50, 300, 'Based on NEOM operational decision (to be validated)'),
    ('Specialist Outpatient Care', 6, 50, 300, 'Based on NEOM operational decision (to be validated)'),
    ('Emergency Care', 7, 52, 365, 'Based on NEOM operational decision (to be validated)'),
    ('Major Diagnostic & Treatment', 6, 50, 300, 'Based on NEOM operational decision (to be validated)'),
    ('Day Cases', 6, 50, 300, 'Based on NEOM operational decision (to be validated)'),
    ('Inpatient Care', 7, 52, 365, 'Based on NEOM operational decision (to be validated)');

-- Insert initial data for working hours
INSERT INTO working_hours_settings 
(care_setting, working_hours_per_day, source)
VALUES
    ('Primary Care', 12, 'Based on NEOM operational decision (to be validated)'),
    ('Specialist Outpatient Care', 12, 'Based on NEOM operational decision (to be validated)'),
    ('Emergency Care', 24, 'Based on NEOM operational decision (to be validated)'),
    ('Major Diagnostic & Treatment', 12, 'Based on NEOM operational decision (to be validated)'),
    ('Day Cases', 12, 'Based on NEOM operational decision (to be validated)'),
    ('Inpatient Care', 24, 'Based on NEOM operational decision (to be validated)');