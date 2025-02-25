-- Create function to map service based on care setting and ICD code
CREATE OR REPLACE FUNCTION get_service_for_planning(
    p_care_setting text,
    p_icd_code text,
    p_system_of_care text
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    v_service text;
BEGIN
    CASE p_care_setting
        WHEN 'HOME' THEN
            SELECT service INTO v_service
            FROM home_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'HEALTH STATION' THEN
            SELECT service INTO v_service
            FROM health_station_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'AMBULATORY SERVICE CENTER' THEN
            SELECT service INTO v_service
            FROM ambulatory_service_center_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'SPECIALTY CARE CENTER' THEN
            SELECT service INTO v_service
            FROM specialty_care_center_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'EXTENDED CARE FACILITY' THEN
            SELECT service INTO v_service
            FROM extended_care_facility_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'HOSPITAL' THEN
            SELECT service INTO v_service
            FROM hospital_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
    END CASE;

    -- If no specific mapping found, use a default based on system of care
    IF v_service IS NULL THEN
        v_service := CASE p_system_of_care
            WHEN 'Planned care' THEN 'Allied Health & Health Promotion'
            WHEN 'Unplanned care' THEN 'Acute & urgent care'
            WHEN 'Wellness and longevity' THEN 'Allied Health & Health Promotion'
            WHEN 'Children and young people' THEN 'Paediatric Medicine'
            WHEN 'Chronic conditions' THEN 'Internal Medicine'
            WHEN 'Complex, multi-morbid' THEN 'Complex condition / Frail elderly'
            WHEN 'Palliative care and support' THEN 'Hospice and Palliative Care'
            ELSE 'Other'
        END;
    END IF;

    RETURN v_service;
END;
$$;

-- Add service column with a default value
ALTER TABLE planning_family_code
ADD COLUMN service text DEFAULT 'Other' NOT NULL;

-- Update existing records with mapped services
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT id, care_setting, icd_family, systems_of_care FROM planning_family_code
    LOOP
        UPDATE planning_family_code
        SET service = get_service_for_planning(r.care_setting, r.icd_family, r.systems_of_care)
        WHERE id = r.id;
    END LOOP;
END $$;

-- Remove the default value constraint now that all records are updated
ALTER TABLE planning_family_code 
ALTER COLUMN service DROP DEFAULT;

-- Create trigger to automatically set service for new records
CREATE OR REPLACE FUNCTION set_planning_family_service()
RETURNS TRIGGER AS $$
BEGIN
    NEW.service := get_service_for_planning(NEW.care_setting, NEW.icd_family, NEW.systems_of_care);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_planning_family_service_trigger
    BEFORE INSERT ON planning_family_code
    FOR EACH ROW
    EXECUTE FUNCTION set_planning_family_service();

-- Add index for service column
CREATE INDEX idx_planning_family_code_service
ON planning_family_code(service);

-- Add comment
COMMENT ON COLUMN planning_family_code.service IS 'The mapped healthcare service based on care setting and ICD code';