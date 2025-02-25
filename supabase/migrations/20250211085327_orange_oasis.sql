-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS validate_proposed_percentages_trigger ON proposed_care_setting_distribution;
DROP TRIGGER IF EXISTS update_proposed_care_setting_distribution_updated_at ON proposed_care_setting_distribution;

-- Drop existing functions
DROP FUNCTION IF EXISTS check_proposed_percentages();
DROP FUNCTION IF EXISTS validate_proposed_percentages(uuid);
DROP FUNCTION IF EXISTS initialize_proposed_distribution(uuid);

-- Create function to initialize proposed distribution
CREATE OR REPLACE FUNCTION initialize_proposed_distribution(p_plan_id uuid)
RETURNS void AS $$
DECLARE
    v_care_setting text;
BEGIN
    -- Get all care settings and their current percentages
    FOR v_care_setting IN 
        SELECT DISTINCT care_setting 
        FROM planning_family_code
    LOOP
        -- Calculate current percentage for this care setting
        WITH total_activity AS (
            SELECT SUM(activity) as total FROM planning_family_code
        ),
        setting_activity AS (
            SELECT 
                SUM(activity) as setting_total,
                (SELECT total FROM total_activity) as grand_total
            FROM planning_family_code
            WHERE care_setting = v_care_setting
        )
        INSERT INTO proposed_care_setting_distribution 
            (plan_id, care_setting, current_percentage, proposed_percentage)
        SELECT 
            p_plan_id,
            v_care_setting,
            ROUND((setting_total * 100.0 / grand_total)::numeric, 2),
            ROUND((setting_total * 100.0 / grand_total)::numeric, 2)
        FROM setting_activity
        ON CONFLICT (plan_id, care_setting) DO UPDATE
        SET 
            current_percentage = EXCLUDED.current_percentage,
            proposed_percentage = EXCLUDED.proposed_percentage;
    END LOOP;

    -- Ensure all care settings exist with default values
    INSERT INTO proposed_care_setting_distribution 
        (plan_id, care_setting, current_percentage, proposed_percentage)
    VALUES 
        (p_plan_id, 'HOME', 15, 15),
        (p_plan_id, 'HEALTH STATION', 20, 20),
        (p_plan_id, 'AMBULATORY SERVICE CENTER', 25, 25),
        (p_plan_id, 'SPECIALTY CARE CENTER', 18, 18),
        (p_plan_id, 'EXTENDED CARE FACILITY', 12, 12),
        (p_plan_id, 'HOSPITAL', 10, 10)
    ON CONFLICT (plan_id, care_setting) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- Create function to validate proposed percentages
CREATE OR REPLACE FUNCTION validate_proposed_percentages(p_plan_id uuid)
RETURNS boolean AS $$
DECLARE
    v_total numeric;
    v_count integer;
BEGIN
    -- Check if we have all required care settings
    SELECT COUNT(*)
    INTO v_count
    FROM proposed_care_setting_distribution
    WHERE plan_id = p_plan_id;

    IF v_count != 6 THEN
        RETURN false;
    END IF;

    -- Check if total equals 100%
    SELECT SUM(proposed_percentage)
    INTO v_total
    FROM proposed_care_setting_distribution
    WHERE plan_id = p_plan_id;

    RETURN ROUND(v_total) = 100;
END;
$$ LANGUAGE plpgsql;

-- Create function to handle distribution updates
CREATE OR REPLACE FUNCTION check_proposed_percentages()
RETURNS trigger AS $$
DECLARE
    v_total numeric;
    v_count integer;
BEGIN
    -- Check if we have all required care settings
    SELECT COUNT(*), SUM(proposed_percentage)
    INTO v_count, v_total
    FROM proposed_care_setting_distribution
    WHERE plan_id = NEW.plan_id;

    IF v_count = 6 AND ROUND(v_total) != 100 THEN
        RAISE EXCEPTION 'Total proposed percentages must equal 100%%';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for distribution validation
CREATE TRIGGER validate_proposed_percentages_trigger
    AFTER INSERT OR UPDATE ON proposed_care_setting_distribution
    FOR EACH ROW
    EXECUTE FUNCTION check_proposed_percentages();

-- Create trigger for updated_at timestamp
CREATE TRIGGER update_proposed_care_setting_distribution_updated_at
    BEFORE UPDATE ON proposed_care_setting_distribution
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

-- Add comments
COMMENT ON FUNCTION initialize_proposed_distribution(uuid) IS 'Initializes proposed distribution percentages for a plan';
COMMENT ON FUNCTION validate_proposed_percentages(uuid) IS 'Validates that proposed percentages sum to 100%';
COMMENT ON FUNCTION check_proposed_percentages() IS 'Trigger function to ensure proposed percentages sum to 100%';