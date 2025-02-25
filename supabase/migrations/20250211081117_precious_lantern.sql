-- Create table for proposed care setting distribution
CREATE TABLE IF NOT EXISTS proposed_care_setting_distribution (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id uuid REFERENCES dc_plans(id) ON DELETE CASCADE,
    care_setting text NOT NULL CHECK (care_setting IN (
        'HOME',
        'HEALTH STATION',
        'AMBULATORY SERVICE CENTER',
        'SPECIALTY CARE CENTER',
        'EXTENDED CARE FACILITY',
        'HOSPITAL'
    )),
    current_percentage numeric(5,2) NOT NULL CHECK (current_percentage >= 0 AND current_percentage <= 100),
    proposed_percentage numeric(5,2) NOT NULL CHECK (proposed_percentage >= 0 AND proposed_percentage <= 100),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(plan_id, care_setting)
);

-- Enable RLS
ALTER TABLE proposed_care_setting_distribution ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on proposed_care_setting_distribution"
    ON proposed_care_setting_distribution FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Enable all access for all users on proposed_care_setting_distribution"
    ON proposed_care_setting_distribution FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create trigger for updated_at
CREATE TRIGGER update_proposed_care_setting_distribution_updated_at
    BEFORE UPDATE ON proposed_care_setting_distribution
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_timestamp();

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
END;
$$ LANGUAGE plpgsql;

-- Create function to validate proposed percentages
CREATE OR REPLACE FUNCTION validate_proposed_percentages(p_plan_id uuid)
RETURNS boolean AS $$
DECLARE
    v_total numeric;
BEGIN
    SELECT SUM(proposed_percentage)
    INTO v_total
    FROM proposed_care_setting_distribution
    WHERE plan_id = p_plan_id;

    RETURN ROUND(v_total) = 100;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to validate total equals 100%
CREATE OR REPLACE FUNCTION check_proposed_percentages()
RETURNS trigger AS $$
BEGIN
    IF NOT validate_proposed_percentages(NEW.plan_id) THEN
        RAISE EXCEPTION 'Total proposed percentages must equal 100%%';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_proposed_percentages_trigger
    AFTER INSERT OR UPDATE ON proposed_care_setting_distribution
    FOR EACH ROW
    EXECUTE FUNCTION check_proposed_percentages();

-- Add comments
COMMENT ON TABLE proposed_care_setting_distribution IS 'Stores proposed distribution percentages for care settings';
COMMENT ON COLUMN proposed_care_setting_distribution.current_percentage IS 'Current percentage of activity for this care setting';
COMMENT ON COLUMN proposed_care_setting_distribution.proposed_percentage IS 'Proposed percentage of activity for this care setting (must be multiple of 5)';