-- Create gender distribution baseline table
CREATE TABLE IF NOT EXISTS gender_distribution_baseline (
    id integer PRIMARY KEY,
    male_data jsonb NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE gender_distribution_baseline ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on gender_distribution_baseline"
    ON gender_distribution_baseline FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable insert/update for all users on gender_distribution_baseline"
    ON gender_distribution_baseline FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_gender_baseline_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_gender_baseline_updated_at
    BEFORE UPDATE ON gender_distribution_baseline
    FOR EACH ROW
    EXECUTE FUNCTION update_gender_baseline_updated_at();

-- Add comments
COMMENT ON TABLE gender_distribution_baseline IS 'Stores baseline data for gender distribution across age groups';
COMMENT ON COLUMN gender_distribution_baseline.male_data IS 'JSON array containing male population percentages by age group and year';