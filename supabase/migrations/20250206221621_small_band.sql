-- Create visit_rates table to store rates from assumptions
CREATE TABLE IF NOT EXISTS visit_rates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service text NOT NULL,
    age_group text NOT NULL,
    assumption_type text NOT NULL CHECK (assumption_type IN ('model', 'enhanced', 'high_risk')),
    male_rate numeric NOT NULL,
    female_rate numeric NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(service, age_group, assumption_type)
);

-- Enable RLS
ALTER TABLE visit_rates ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on visit_rates"
    ON visit_rates FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable insert/update for all users on visit_rates"
    ON visit_rates FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_visit_rates_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_visit_rates_updated_at
    BEFORE UPDATE ON visit_rates
    FOR EACH ROW
    EXECUTE FUNCTION update_visit_rates_updated_at();

-- Add comments
COMMENT ON TABLE visit_rates IS 'Stores visit rates for different services by age group and assumption type';
COMMENT ON COLUMN visit_rates.service IS 'The healthcare service';
COMMENT ON COLUMN visit_rates.age_group IS 'The age group for the rate';
COMMENT ON COLUMN visit_rates.assumption_type IS 'The type of assumption (model, enhanced, high_risk)';
COMMENT ON COLUMN visit_rates.male_rate IS 'Visit rate per 1000 for males';
COMMENT ON COLUMN visit_rates.female_rate IS 'Visit rate per 1000 for females';