-- Drop existing constraints and triggers
DROP TRIGGER IF EXISTS set_population_defaults_trigger ON population_data;
DROP FUNCTION IF EXISTS set_population_defaults();
ALTER TABLE population_data DROP CONSTRAINT IF EXISTS check_fixed_values;

-- Create updated function to set default values for new population data entries
CREATE OR REPLACE FUNCTION set_population_defaults()
RETURNS TRIGGER AS $$
BEGIN
    -- Set default factor and divisor based on population type
    IF NEW.population_type IN ('Staff', 'Residents', 'Construction Worker') THEN
        -- Fixed values for these types
        NEW.default_factor := 365;
        NEW.divisor := 365;
    ELSIF NEW.population_type = 'Tourists/Visit' THEN
        -- Only set defaults if values are NULL (allow modification of existing values)
        IF NEW.default_factor IS NULL THEN
            NEW.default_factor := 3.7;
        END IF;
        IF NEW.divisor IS NULL THEN
            NEW.divisor := 270;
        END IF;
    ELSE -- Same day Visitor
        NEW.default_factor := 1;
        NEW.divisor := 365;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set defaults only for new records
CREATE TRIGGER set_population_defaults_trigger
    BEFORE INSERT ON population_data
    FOR EACH ROW
    EXECUTE FUNCTION set_population_defaults();

-- Add comment explaining the updated defaults
COMMENT ON FUNCTION set_population_defaults() IS 'Sets default factor and divisor values for population data based on population type:
- Staff, Residents, Construction Worker: fixed at factor=365, divisor=365
- Tourists/Visit: initial defaults factor=3.7, divisor=270 (fully editable)
- Same day Visitor: factor=1, divisor=365';

-- Add constraint only for fixed-value population types
ALTER TABLE population_data ADD CONSTRAINT check_fixed_values
    CHECK (
        (population_type IN ('Staff', 'Residents', 'Construction Worker') AND default_factor = 365 AND divisor = 365)
        OR population_type NOT IN ('Staff', 'Residents', 'Construction Worker')
    );