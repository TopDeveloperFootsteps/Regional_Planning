-- First update all existing records to match required values
UPDATE population_data 
SET default_factor = 365,
    divisor = 365
WHERE population_type IN ('Staff', 'Residents', 'Construction Worker');

UPDATE population_data 
SET divisor = 270
WHERE population_type = 'Tourists/Visit';

UPDATE population_data 
SET default_factor = 1,
    divisor = 365
WHERE population_type = 'Same day Visitor';

-- Drop existing constraints and triggers
DROP TRIGGER IF EXISTS set_population_defaults_trigger ON population_data;
DROP FUNCTION IF EXISTS set_population_defaults();
ALTER TABLE population_data DROP CONSTRAINT IF EXISTS check_fixed_values;
ALTER TABLE population_data DROP CONSTRAINT IF EXISTS check_population_values;

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
        -- For Tourists/Visit, only set defaults if values are NULL
        -- This allows custom values to be set and modified
        IF NEW.default_factor IS NULL THEN
            NEW.default_factor := 3.7;
        END IF;
        -- Always use fixed divisor for Tourists/Visit
        NEW.divisor := 270;
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
- Tourists/Visit: customizable factor (default 3.7 if not specified), fixed divisor=270
- Same day Visitor: factor=1, divisor=365';

-- Add constraint that enforces fixed values for specific population types
-- while allowing Tourists/Visit to have custom default_factor
ALTER TABLE population_data ADD CONSTRAINT check_population_values
    CHECK (
        (population_type IN ('Staff', 'Residents', 'Construction Worker') 
         AND default_factor = 365 
         AND divisor = 365)
        OR
        (population_type = 'Tourists/Visit' 
         AND divisor = 270 
         AND default_factor > 0)
        OR
        (population_type = 'Same day Visitor' 
         AND default_factor = 1 
         AND divisor = 365)
    );