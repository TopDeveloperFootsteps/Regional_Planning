-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Enable read access for all users on population_summary" ON population_summary;
DROP POLICY IF EXISTS "Enable all access for all users on population_summary" ON population_summary;

-- Create function to calculate population summary
CREATE OR REPLACE FUNCTION calculate_population_summary(
    p_region_id text,
    p_year integer
)
RETURNS void AS $$
DECLARE
    v_age_group text;
    v_total numeric;
    v_male_ratio numeric;
    v_female_ratio numeric;
    v_male_pop numeric;
    v_female_pop numeric;
    v_working_age_groups text[] := ARRAY['20 to 29', '30 to 44', '45 to 64'];
    v_year_column text;
BEGIN
    -- Construct the year column name
    v_year_column := 'year_' || p_year;

    -- Delete existing summary for this region and year
    DELETE FROM population_summary 
    WHERE region_id = p_region_id 
    AND year = p_year;

    -- Process each age group
    FOR v_age_group IN 
        SELECT unnest(ARRAY['0 to 4', '5 to 19', '20 to 29', '30 to 44', '45 to 64', '65 to 125'])
    LOOP
        -- Get gender distribution for this age group and year
        SELECT 
            male_ratio,
            1 - male_ratio INTO v_male_ratio, v_female_ratio
        FROM (
            SELECT (jsonb_array_elements(male_data)->>'ageGroup')::text as age_group,
                   (jsonb_array_elements(male_data)->>p_year::text)::numeric as male_ratio
            FROM gender_distribution_baseline
        ) gd
        WHERE gd.age_group = v_age_group;

        -- Calculate total population for this age group
        EXECUTE format('
            SELECT COALESCE(SUM(
                CASE 
                    WHEN population_type IN (''Staff'', ''Construction Worker'') THEN
                        CASE 
                            WHEN $1 = ANY($2) THEN
                                %I::numeric * default_factor / divisor *
                                CASE 
                                    WHEN $1 = ''20 to 29'' THEN 0.27
                                    WHEN $1 = ''30 to 44'' THEN 0.45
                                    WHEN $1 = ''45 to 64'' THEN 0.28
                                    ELSE 0
                                END
                            ELSE 0
                        END
                    ELSE 
                        %I::numeric * default_factor / divisor *
                        CASE 
                            WHEN $1 = ''0 to 4'' THEN 0.08
                            WHEN $1 = ''5 to 19'' THEN 0.20
                            WHEN $1 = ''20 to 29'' THEN 0.18
                            WHEN $1 = ''30 to 44'' THEN 0.30
                            WHEN $1 = ''45 to 64'' THEN 0.19
                            WHEN $1 = ''65 to 125'' THEN 0.05
                        END
                END
            ), 0)
            FROM population_data
            WHERE region_id = $3',
            v_year_column,
            v_year_column
        )
        INTO v_total
        USING v_age_group, v_working_age_groups, p_region_id;

        -- Calculate male and female populations
        v_male_pop := v_total * v_male_ratio;
        v_female_pop := v_total * v_female_ratio;

        -- Insert summary record
        INSERT INTO population_summary (
            region_id,
            age_group,
            year,
            total_population,
            male_population,
            female_population
        ) VALUES (
            p_region_id,
            v_age_group,
            p_year,
            v_total,
            v_male_pop,
            v_female_pop
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create function to calculate population summary for all regions
CREATE OR REPLACE FUNCTION calculate_all_population_summaries(p_year integer)
RETURNS void AS $$
DECLARE
    v_region record;
BEGIN
    FOR v_region IN SELECT id FROM regions WHERE status = 'active'
    LOOP
        PERFORM calculate_population_summary(v_region.id, p_year);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to automatically update summaries
CREATE OR REPLACE FUNCTION update_population_summary_trigger()
RETURNS trigger AS $$
BEGIN
    -- Calculate summaries for all years for the affected region
    FOR i IN 2025..2040 LOOP
        PERFORM calculate_population_summary(NEW.region_id, i);
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on population_data
DROP TRIGGER IF EXISTS update_population_summary ON population_data;
CREATE TRIGGER update_population_summary
    AFTER INSERT OR UPDATE ON population_data
    FOR EACH ROW
    EXECUTE FUNCTION update_population_summary_trigger();

-- Calculate initial summaries for all regions and years
DO $$
DECLARE
    v_year integer;
BEGIN
    FOR v_year IN 2025..2040 LOOP
        PERFORM calculate_all_population_summaries(v_year);
    END LOOP;
END $$;

-- Create new policies
CREATE POLICY "Enable read access for all users on population_summary"
    ON population_summary FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on population_summary"
    ON population_summary FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);