-- Create staging table for initial data load
CREATE TABLE IF NOT EXISTS planning_code_sections_staging (
    systems_of_care text NOT NULL,
    care_setting text NOT NULL,
    icd_sections text NOT NULL,
    activity text NOT NULL
);

-- Enable RLS
ALTER TABLE planning_code_sections_staging ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable all access for all users on planning_code_sections_staging"
    ON planning_code_sections_staging FOR ALL
    TO public
    USING (true)
    WITH CHECK (true);

-- Create function to migrate data from staging to final table
CREATE OR REPLACE FUNCTION migrate_planning_code_sections()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- Clear existing data
    DELETE FROM planning_code_sections;
    
    -- Insert data from staging table with cleaned numeric values
    INSERT INTO planning_code_sections 
    (systems_of_care, care_setting, icd_sections, activity)
    SELECT 
        systems_of_care,
        care_setting,
        icd_sections,
        replace(activity, ',', '')::numeric(20,2)
    FROM planning_code_sections_staging;
    
    -- Clear staging table
    DELETE FROM planning_code_sections_staging;
END;
$$;

-- Add comments
COMMENT ON TABLE planning_code_sections_staging IS 'Temporary staging table for loading planning code sections data';
COMMENT ON FUNCTION migrate_planning_code_sections() IS 'Migrates data from staging table to final table, cleaning numeric values';