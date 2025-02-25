-- Update divisor for Tourists/Visit to 270
UPDATE population_data 
SET divisor = 270
WHERE population_type = 'Tourists/Visit';

-- Ensure default_factor is 3.7 for Tourists/Visit
UPDATE population_data
SET default_factor = 3.7
WHERE population_type = 'Tourists/Visit';