-- Update default factors and divisors for all population types
UPDATE population_data 
SET default_factor = 365,
    divisor = 365
WHERE population_type IN ('Staff', 'Residents', 'Construction Worker');

-- Update Tourists/Visit separately to maintain its special values
UPDATE population_data 
SET default_factor = 3.7,
    divisor = 270
WHERE population_type = 'Tourists/Visit';

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS set_population_defaults_trigger ON population_data;
DROP FUNCTION IF EXISTS set_population_defaults();

-- Create updated function to set default values for new population data entries
CREATE OR REPLACE FUNCTION set_population_defaults()
RETURNS TRIGGER AS $$
BEGIN
    -- Set default factor and divisor based on population type
    IF NEW.population_type IN ('Staff', 'Residents', 'Construction Worker') THEN
        NEW.default_factor := 365;
        NEW.divisor := 365;
    ELSIF NEW.population_type = 'Tourists/Visit' THEN
        NEW.default_factor := 3.7;
        NEW.divisor := 270;
    ELSE -- Same day Visitor
        NEW.default_factor := 1;
        NEW.divisor := 365;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set defaults
CREATE TRIGGER set_population_defaults_trigger
    BEFORE INSERT ON population_data
    FOR EACH ROW
    EXECUTE FUNCTION set_population_defaults();

-- Add comment explaining the updated defaults
COMMENT ON FUNCTION set_population_defaults() IS 'Sets default factor and divisor values for population data based on population type:
- Staff, Residents, Construction Worker: factor=365, divisor=365
- Tourists/Visit: factor=3.7, divisor=270
- Same day Visitor: factor=1, divisor=365';