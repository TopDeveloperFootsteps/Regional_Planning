-- Create assets table
CREATE TABLE IF NOT EXISTS assets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    region_id text REFERENCES regions(id) ON DELETE CASCADE,
    asset_id text NOT NULL UNIQUE,
    name text NOT NULL,
    type text NOT NULL CHECK (type IN ('Permanent', 'Temporary')),
    owner text NOT NULL CHECK (owner = 'PPP'),
    archetype text NOT NULL CHECK (
        archetype IN (
            'Family Health Center',
            'Resort',
            'Spoke',
            'Field Hospital',
            'N/A',
            'Advance Health Ceter',
            'Hub',
            'First Aid Point',
            'Clinic',
            'Hospital'
        )
    ),
    population_types text[] NOT NULL,
    start_date date NOT NULL CHECK (start_date >= '2017-01-01'),
    end_date date,
    latitude decimal(10,6) NOT NULL,
    longitude decimal(10,6) NOT NULL,
    gfa decimal(10,2) NOT NULL CHECK (gfa > 0),
    status text NOT NULL CHECK (
        status IN (
            'Design',
            'Planning', 
            'Operational',
            'Closed',
            'Not Started',
            'Partially Operational'
        )
    ),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CONSTRAINT valid_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT valid_population_types CHECK (
        array_length(population_types, 1) > 0 AND
        array_length(population_types, 1) <= 4 AND
        population_types <@ ARRAY[
            'Residents',
            'Staff',
            'Visitors/Tourists',
            'Construction Workers'
        ]::text[]
    )
);

-- Enable RLS
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on assets"
    ON assets FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable insert for all users on assets"
    ON assets FOR INSERT
    TO public
    WITH CHECK (true);

CREATE POLICY "Enable update for all users on assets"
    ON assets FOR UPDATE
    TO public
    USING (true)
    WITH CHECK (true);

-- Create indexes
CREATE INDEX idx_assets_region_id ON assets(region_id);
CREATE INDEX idx_assets_asset_id ON assets(asset_id);
CREATE INDEX idx_assets_type ON assets(type);
CREATE INDEX idx_assets_archetype ON assets(archetype);
CREATE INDEX idx_assets_status ON assets(status);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_assets_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_assets_updated_at
    BEFORE UPDATE ON assets
    FOR EACH ROW
    EXECUTE FUNCTION update_assets_updated_at();