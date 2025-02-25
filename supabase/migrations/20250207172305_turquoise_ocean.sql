-- First update existing data to match new requirements
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

-- Drop existing constraints
ALTER TABLE population_data DROP CONSTRAINT IF EXISTS population_type_rules;
ALTER TABLE population_data DROP CONSTRAINT IF EXISTS check_fixed_values;
ALTER TABLE population_data DROP CONSTRAINT IF EXISTS check_population_values;

-- Add new constraint with NULL checks
ALTER TABLE population_data ADD CONSTRAINT population_type_rules
    CHECK (
        (population_type = 'Staff' AND default_factor = 365 AND divisor = 365)
        OR 
        (population_type = 'Residents' AND default_factor = 365 AND divisor = 365)
        OR 
        (population_type = 'Construction Worker' AND default_factor = 365 AND divisor = 365)
        OR 
        (population_type = 'Tourists/Visit' AND divisor = 270 AND default_factor > 0)
        OR
        (population_type = 'Same day Visitor' AND default_factor = 1 AND divisor = 365)
    );

-- Add comment explaining the validation
COMMENT ON CONSTRAINT population_type_rules ON population_data IS 
'Enforces population type rules:
- Staff: factor=365, divisor=365
- Residents: factor=365, divisor=365
- Construction Worker: factor=365, divisor=365
- Tourists/Visit: divisor=270, factor>0 (customizable)
- Same day Visitor: factor=1, divisor=365';