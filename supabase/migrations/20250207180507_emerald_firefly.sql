-- Create table for population totals by gender
CREATE TABLE IF NOT EXISTS population_totals (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    region_id text REFERENCES regions(id),
    year integer NOT NULL CHECK (year BETWEEN 2025 AND 2040),
    total_population numeric NOT NULL DEFAULT 0,
    male_population numeric NOT NULL DEFAULT 0,
    female_population numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(region_id, year)
);

-- Enable RLS
ALTER TABLE population_totals ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on population_totals"
    ON population_totals FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on population_totals"
    ON population_totals FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create function to calculate population totals
CREATE OR REPLACE FUNCTION calculate_population_totals(
    p_region_id text,
    p_year integer
)
RETURNS void AS $$
DECLARE
    v_total_population numeric;
    v_male_population numeric;
    v_female_population numeric;
BEGIN
    -- Get totals from population_summary
    SELECT 
        SUM(total_population),
        SUM(male_population),
        SUM(female_population)
    INTO 
        v_total_population,
        v_male_population,
        v_female_population
    FROM population_summary
    WHERE region_id = p_region_id 
    AND year = p_year;

    -- Insert or update totals
    INSERT INTO population_totals (
        region_id,
        year,
        total_population,
        male_population,
        female_population
    ) VALUES (
        p_region_id,
        p_year,
        COALESCE(v_total_population, 0),
        COALESCE(v_male_population, 0),
        COALESCE(v_female_population, 0)
    )
    ON CONFLICT (region_id, year) DO UPDATE
    SET 
        total_population = COALESCE(v_total_population, 0),
        male_population = COALESCE(v_male_population, 0),
        female_population = COALESCE(v_female_population, 0),
        updated_at = now();
END;
$$ LANGUAGE plpgsql;

-- Create function to calculate totals for all regions
CREATE OR REPLACE FUNCTION calculate_all_population_totals(p_year integer)
RETURNS void AS $$
DECLARE
    v_region record;
BEGIN
    FOR v_region IN SELECT id FROM regions WHERE status = 'active'
    LOOP
        PERFORM calculate_population_totals(v_region.id, p_year);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to automatically update totals
CREATE OR REPLACE FUNCTION update_population_totals_trigger()
RETURNS trigger AS $$
BEGIN
    -- Calculate totals for all years for the affected region
    FOR i IN 2025..2040 LOOP
        PERFORM calculate_population_totals(NEW.region_id, i);
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on population_summary
CREATE TRIGGER update_population_totals
    AFTER INSERT OR UPDATE ON population_summary
    FOR EACH ROW
    EXECUTE FUNCTION update_population_totals_trigger();

-- Calculate initial totals for all regions and years
DO $$
DECLARE
    v_year integer;
BEGIN
    FOR v_year IN 2025..2040 LOOP
        PERFORM calculate_all_population_totals(v_year);
    END LOOP;
END $$;