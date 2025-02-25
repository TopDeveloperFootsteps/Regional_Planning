-- Create population_data table
CREATE TABLE IF NOT EXISTS population_data (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    region_id text REFERENCES regions(id) ON DELETE CASCADE,
    population_type text NOT NULL CHECK (
        population_type IN (
            'Staff',
            'Residents',
            'Tourists/Visit',
            'Same day Visitor',
            'Construction Worker'
        )
    ),
    default_factor numeric NOT NULL CHECK (default_factor > 0),
    year_2025 integer,
    year_2026 integer,
    year_2027 integer,
    year_2028 integer,
    year_2029 integer,
    year_2030 integer,
    year_2031 integer,
    year_2032 integer,
    year_2033 integer,
    year_2034 integer,
    year_2035 integer,
    year_2036 integer,
    year_2037 integer,
    year_2038 integer,
    year_2039 integer,
    year_2040 integer,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE (region_id, population_type)
);

-- Enable RLS
ALTER TABLE population_data ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on population_data"
    ON population_data FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable insert for all users on population_data"
    ON population_data FOR INSERT
    TO public
    WITH CHECK (true);

CREATE POLICY "Enable update for all users on population_data"
    ON population_data FOR UPDATE
    TO public
    USING (true)
    WITH CHECK (true);

-- Create indexes
CREATE INDEX idx_population_data_region_id ON population_data(region_id);
CREATE INDEX idx_population_data_population_type ON population_data(population_type);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_population_data_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_population_data_updated_at
    BEFORE UPDATE ON population_data
    FOR EACH ROW
    EXECUTE FUNCTION update_population_data_updated_at();

-- Add comments for documentation
COMMENT ON TABLE population_data IS 'Stores population projections and calculations for each region';
COMMENT ON COLUMN population_data.region_id IS 'Reference to the region this population data belongs to';
COMMENT ON COLUMN population_data.population_type IS 'Type of population (Staff, Residents, etc.)';
COMMENT ON COLUMN population_data.default_factor IS 'Default factor used for population calculations';