-- Add divisor column to population_data table
ALTER TABLE population_data
ADD COLUMN divisor integer NOT NULL DEFAULT 365;

-- Update existing records for Tourists/Visit and Same day Visitor to use 365 as divisor
UPDATE population_data 
SET divisor = 365
WHERE population_type IN ('Tourists/Visit', 'Same day Visitor');