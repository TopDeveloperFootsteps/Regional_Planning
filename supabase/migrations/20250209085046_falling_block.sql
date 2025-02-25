-- Create table for D&C Output Analysis plans
CREATE TABLE IF NOT EXISTS dc_plans (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    population integer NOT NULL CHECK (population > 0),
    date date NOT NULL,
    capacity_data jsonb NOT NULL,
    activity_data jsonb NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE dc_plans ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on dc_plans"
    ON dc_plans FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on dc_plans"
    ON dc_plans FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create updated_at trigger
CREATE TRIGGER update_dc_plans_updated_at
    BEFORE UPDATE ON dc_plans
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

-- Add indexes
CREATE INDEX idx_dc_plans_name ON dc_plans(name);
CREATE INDEX idx_dc_plans_date ON dc_plans(date);