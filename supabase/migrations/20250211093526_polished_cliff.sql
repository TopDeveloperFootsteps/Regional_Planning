-- First remove any duplicate records
DELETE FROM planning_family_code a
WHERE a.ctid <> (
    SELECT min(b.ctid)
    FROM planning_family_code b
    WHERE a.care_setting = b.care_setting 
    AND a.icd_family = b.icd_family
);

-- Now add the unique constraint
ALTER TABLE planning_family_code 
ADD CONSTRAINT planning_family_code_care_setting_icd_family_key 
UNIQUE (care_setting, icd_family);

-- Insert dental codes into planning_family_code
INSERT INTO planning_family_code 
(systems_of_care, care_setting, icd_family, activity, service)
VALUES
    ('Planned care', 'AMBULATORY SERVICE CENTER', 'K00', 150, 'Primary dental care'),  -- Disorders of tooth development
    ('Planned care', 'AMBULATORY SERVICE CENTER', 'K01', 120, 'Primary dental care'),  -- Embedded and impacted teeth
    ('Planned care', 'AMBULATORY SERVICE CENTER', 'K02', 200, 'Primary dental care'),  -- Dental caries
    ('Planned care', 'AMBULATORY SERVICE CENTER', 'K03', 100, 'Primary dental care'),  -- Other diseases of hard tissues of teeth
    ('Planned care', 'AMBULATORY SERVICE CENTER', 'K04', 180, 'Primary dental care'),  -- Diseases of pulp and periapical tissues
    ('Planned care', 'AMBULATORY SERVICE CENTER', 'K05', 160, 'Primary dental care'),  -- Gingivitis and periodontal diseases
    ('Planned care', 'AMBULATORY SERVICE CENTER', 'K06', 90, 'Primary dental care'),   -- Other disorders of gingiva and edentulous alveolar ridge
    ('Planned care', 'AMBULATORY SERVICE CENTER', 'K07', 110, 'Primary dental care'),  -- Dentofacial anomalies
    ('Planned care', 'AMBULATORY SERVICE CENTER', 'K08', 140, 'Primary dental care')   -- Other disorders of teeth and supporting structures
ON CONFLICT (care_setting, icd_family) DO UPDATE
SET 
    service = EXCLUDED.service,
    activity = EXCLUDED.activity,
    systems_of_care = EXCLUDED.systems_of_care;

-- Update service mapping function to ensure dental codes are properly mapped
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
    v_icd_prefix text;
BEGIN
    -- Get first character/prefix of ICD code
    v_icd_prefix := LEFT(p_icd_code, 1);

    -- First check for dental codes
    IF LEFT(p_icd_code, 2) IN ('K0') THEN
        RETURN 'Primary dental care';
    END IF;

    -- Rest of the function remains the same...
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

-- Update any existing dental codes to ensure proper service mapping
UPDATE planning_family_code
SET service = 'Primary dental care'
WHERE LEFT(icd_family, 2) = 'K0'
AND care_setting = 'AMBULATORY SERVICE CENTER';