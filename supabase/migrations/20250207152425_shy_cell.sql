-- First: Create a temporary table to store current values
CREATE TEMP TABLE temp_occupancy_rates AS
SELECT * FROM occupancy_rates;

-- Drop existing occupancy_rates table
DROP TABLE occupancy_rates;

-- Recreate occupancy_rates table with decimal percentage values
CREATE TABLE occupancy_rates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    care_setting text NOT NULL,
    inperson_rate decimal(5,4) NOT NULL CHECK (inperson_rate BETWEEN 0 AND 1),
    virtual_rate decimal(5,4) CHECK (virtual_rate BETWEEN 0 AND 1),
    source text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(care_setting)
);

-- Enable RLS
ALTER TABLE occupancy_rates ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on occupancy_rates"
    ON occupancy_rates FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on occupancy_rates"
    ON occupancy_rates FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create updated_at trigger
CREATE TRIGGER update_occupancy_rates_updated_at
    BEFORE UPDATE ON occupancy_rates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

-- Reinsert data with converted percentage values
INSERT INTO occupancy_rates 
(care_setting, inperson_rate, virtual_rate, source)
SELECT 
    care_setting,
    inperson_rate / 100.0,
    CASE 
        WHEN virtual_rate IS NOT NULL THEN virtual_rate / 100.0
        ELSE NULL
    END,
    source
FROM temp_occupancy_rates;

-- Drop temporary table
DROP TABLE temp_occupancy_rates;

-- Add comment explaining the percentage storage
COMMENT ON TABLE occupancy_rates IS 'Stores occupancy rates as decimal values between 0 and 1 (e.g., 0.7 = 70%)';
COMMENT ON COLUMN occupancy_rates.inperson_rate IS 'In-person occupancy rate stored as decimal (0-1)';
COMMENT ON COLUMN occupancy_rates.virtual_rate IS 'Virtual occupancy rate stored as decimal (0-1), NULL if not applicable';