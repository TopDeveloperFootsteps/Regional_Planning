-- Create table for primary care capacity calculations
CREATE TABLE IF NOT EXISTS primary_care_capacity (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service text NOT NULL,
    total_minutes_per_year integer NOT NULL,
    total_slots_per_year integer NOT NULL,
    average_visit_duration numeric(10,2) NOT NULL,
    new_visits_per_year integer NOT NULL,
    follow_up_visits_per_year integer NOT NULL,
    slots_per_day integer NOT NULL,
    year integer NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(service, year)
);

-- Create table for specialist OPD capacity calculations
CREATE TABLE IF NOT EXISTS specialist_opd_capacity (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    specialty text NOT NULL,
    total_minutes_per_year integer NOT NULL,
    total_slots_per_year integer NOT NULL,
    average_visit_duration numeric(10,2) NOT NULL,
    new_visits_per_year integer NOT NULL,
    follow_up_visits_per_year integer NOT NULL,
    slots_per_day integer NOT NULL,
    year integer NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(specialty, year)
);

-- Enable RLS
ALTER TABLE primary_care_capacity ENABLE ROW LEVEL SECURITY;
ALTER TABLE specialist_opd_capacity ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on primary_care_capacity"
    ON primary_care_capacity FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on primary_care_capacity"
    ON primary_care_capacity FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable read access for all users on specialist_opd_capacity"
    ON specialist_opd_capacity FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on specialist_opd_capacity"
    ON specialist_opd_capacity FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create updated_at triggers
CREATE TRIGGER update_primary_care_capacity_updated_at
    BEFORE UPDATE ON primary_care_capacity
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

CREATE TRIGGER update_specialist_opd_capacity_updated_at
    BEFORE UPDATE ON specialist_opd_capacity
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

-- Add comments
COMMENT ON TABLE primary_care_capacity IS 'Stores capacity calculations for primary care services';
COMMENT ON TABLE specialist_opd_capacity IS 'Stores capacity calculations for specialist outpatient services';

-- Create indexes
CREATE INDEX idx_primary_care_capacity_year ON primary_care_capacity(year);
CREATE INDEX idx_specialist_opd_capacity_year ON specialist_opd_capacity(year);