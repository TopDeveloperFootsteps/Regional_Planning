-- Drop existing function
DROP FUNCTION IF EXISTS get_service_for_planning;

-- Create updated function with correct service name
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

    -- First try to get exact mapping from appropriate table
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

    -- If no specific mapping found, use smart defaults based on ICD code and system of care
    IF v_service IS NULL THEN
        -- Handle Z40-Z44 codes
        IF v_icd_prefix = 'Z' AND LEFT(p_icd_code, 2) = 'Z4' THEN
            CASE LEFT(p_icd_code, 3)
                WHEN 'Z40' THEN v_service := 'General Surgery';
                WHEN 'Z41' THEN v_service := 'Plastics (incl. Burns and Maxillofacial)';
                WHEN 'Z42' THEN v_service := 'Plastics (incl. Burns and Maxillofacial)';
                WHEN 'Z43' THEN v_service := 'General Surgery';
                WHEN 'Z44' THEN v_service := 'Physical Medicine and Rehabilitation';
                ELSE v_service := 'Allied Health & Health Promotion';
            END CASE;
        ELSE
            -- Map other ICD codes
            CASE v_icd_prefix
                WHEN 'A', 'B' THEN v_service := 'Infectious Diseases';
                WHEN 'C' THEN v_service := 'Oncology';
                WHEN 'D' THEN
                    IF LEFT(p_icd_code, 2) < 'D5' THEN 
                        v_service := 'Oncology';
                    ELSE 
                        v_service := 'Haematology';
                    END IF;
                WHEN 'E' THEN v_service := 'Endocrinology';
                WHEN 'F' THEN v_service := 'Psychiatry';
                WHEN 'G' THEN v_service := 'Neurology (inc. neurophysiology and neuropathology)';
                WHEN 'H' THEN
                    IF LEFT(p_icd_code, 2) < 'H6' THEN 
                        v_service := 'Ophthalmology';
                    ELSE 
                        v_service := 'Otolaryngology / ENT';
                    END IF;
                WHEN 'I' THEN v_service := 'Cardiology';
                WHEN 'J' THEN v_service := 'Pulmonology / Respiratory Medicine';
                WHEN 'K' THEN v_service := 'Gastroenterology';
                WHEN 'L' THEN v_service := 'Dermatology';
                WHEN 'M' THEN v_service := 'Rheumatology';
                WHEN 'N' THEN v_service := 'Nephrology';
                WHEN 'O' THEN v_service := 'Obstetrics & Gynaecology';
                WHEN 'P' THEN v_service := 'Paediatric Medicine';
                WHEN 'Q' THEN v_service := 'Medical Genetics';
                WHEN 'R' THEN v_service := 'Internal Medicine';
                WHEN 'S', 'T' THEN v_service := 'Trauma and Emergency Medicine';
                WHEN 'Z' THEN
                    CASE p_system_of_care
                        WHEN 'Planned care' THEN v_service := 'Allied Health & Health Promotion';
                        WHEN 'Unplanned care' THEN v_service := 'Acute & urgent care';
                        WHEN 'Children and young people' THEN v_service := 'Paediatric Medicine';
                        WHEN 'Complex, multi-morbid' THEN v_service := 'Complex condition / Frail elderly';
                        WHEN 'Chronic conditions' THEN v_service := 'Internal Medicine';
                        WHEN 'Palliative care and support' THEN v_service := 'Hospice and Palliative Care';
                        WHEN 'Wellness and longevity' THEN v_service := 'Allied Health & Health Promotion';
                        ELSE v_service := 'Allied Health & Health Promotion';
                    END CASE;
                ELSE v_service := 'Other';
            END CASE;
        END IF;
    END IF;

    -- If still no mapping found, use a final fallback based on system of care
    IF v_service IS NULL THEN
        CASE p_system_of_care
            WHEN 'Planned care' THEN v_service := 'Allied Health & Health Promotion';
            WHEN 'Unplanned care' THEN v_service := 'Acute & urgent care';
            WHEN 'Children and young people' THEN v_service := 'Paediatric Medicine';
            WHEN 'Complex, multi-morbid' THEN v_service := 'Complex condition / Frail elderly';
            WHEN 'Chronic conditions' THEN v_service := 'Internal Medicine';
            WHEN 'Palliative care and support' THEN v_service := 'Hospice and Palliative Care';
            WHEN 'Wellness and longevity' THEN v_service := 'Allied Health & Health Promotion';
            ELSE v_service := 'Other';
        END CASE;
    END IF;

    RETURN v_service;
END;
$$;

-- Update any records that might have the incorrect service name
UPDATE planning_family_code
SET service = get_service_for_planning(care_setting, icd_family, systems_of_care)
WHERE service = 'Truma and Emergency Medicine';

-- Add comment explaining the fix
COMMENT ON FUNCTION get_service_for_planning IS 'Maps ICD codes to services based on care setting and system of care. Fixed typo in Trauma and Emergency Medicine service name.';