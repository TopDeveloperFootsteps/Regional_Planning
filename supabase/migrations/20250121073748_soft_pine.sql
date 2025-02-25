-- First: Clear existing optimization data
DELETE FROM care_setting_optimization_data;

-- Insert updated optimization data with new analysis
INSERT INTO care_setting_optimization_data 
(care_setting, current_encounters, current_percentage, shift_potential, shift_direction, 
 potential_shift_percentage, proposed_percentage, potential_encounters_change, optimization_strategy)
VALUES
    -- Home (Receiving setting)
    ('Home', 25000, 15, 16500, 'Receiving', 66, 25, 16500, 
    'Primary target for care shift - Increase telemedicine capabilities for chronic condition monitoring, routine follow-ups, and stable patient management. Focus on remote patient monitoring for vital signs and medication adherence. Potential to receive up to 66% more cases through telemedicine and remote monitoring initiatives.'),

    -- Health Station (Both directions)
    ('Health Station', 35000, 20, 5250, 'Both', 15, 23, 5250,
    'Optimize through enhanced primary care capabilities - Strengthen telemedicine infrastructure to support remote specialist consultations. Ideal for stable chronic conditions and routine care that requires basic physical examination.'),

    -- Ambulatory Service Center (Outward)
    ('Ambulatory Service Center', 45000, 25, 11250, 'Outward', 25, 22, -11250,
    'Shift suitable cases to lower acuity settings - Identify stable patients with well-managed conditions for home monitoring. Implement specialist oversight programs for remote management of suitable cases.'),

    -- Specialty Care Center (Outward)
    ('Specialty Care Center', 30000, 18, 6000, 'Outward', 20, 14, -6000,
    'Reduce unnecessary specialty visits - Transfer stable patients to ambulatory care with specialist oversight. Implement clear pathways for remote consultations and telemedicine follow-ups.'),

    -- Extended Care Facility (Outward)
    ('Extended Care Facility', 20000, 12, 3000, 'Outward', 15, 10, -3000,
    'Enhance home care capabilities - Develop comprehensive home care programs with remote monitoring for suitable patients. Focus on family support and telemedicine for ongoing management.'),

    -- Hospital (Outward)
    ('Hospital', 15000, 10, 4500, 'Outward', 30, 6, -4500,
    'Maximize appropriate outpatient care - Shift suitable post-acute care to lower acuity settings. Implement remote monitoring for early discharge cases with proper support systems.');

-- Create view for ICD code severity analysis
CREATE OR REPLACE VIEW icd_severity_analysis AS
WITH all_mappings AS (
    SELECT icd_code, systems_of_care FROM home_services_mapping
    UNION ALL
    SELECT icd_code, systems_of_care FROM health_station_services_mapping
    UNION ALL
    SELECT icd_code, systems_of_care FROM ambulatory_service_center_services_mapping
    UNION ALL
    SELECT icd_code, systems_of_care FROM specialty_care_center_services_mapping
    UNION ALL
    SELECT icd_code, systems_of_care FROM extended_care_facility_services_mapping
    UNION ALL
    SELECT icd_code, systems_of_care FROM hospital_services_mapping
),
severity_categories AS (
    SELECT 
        LEFT(icd_code, 1) as icd_category,
        CASE
            -- Conditions suitable for home care
            WHEN LEFT(icd_code, 1) IN ('Z') THEN 'Low'
            -- Conditions requiring basic medical supervision
            WHEN LEFT(icd_code, 1) IN ('F', 'L', 'M', 'R') THEN 'Low-Medium'
            -- Conditions requiring regular medical attention
            WHEN LEFT(icd_code, 1) IN ('E', 'G', 'H', 'J', 'K', 'N') THEN 'Medium'
            -- Conditions requiring specialist care
            WHEN LEFT(icd_code, 1) IN ('A', 'B', 'C', 'D', 'I') THEN 'High'
            -- Acute conditions
            WHEN LEFT(icd_code, 1) IN ('S', 'T') THEN 'Very High'
            ELSE 'Medium'
        END as severity_level,
        COUNT(*) as code_count
    FROM all_mappings
    GROUP BY LEFT(icd_code, 1)
)
SELECT 
    severity_level,
    COUNT(*) as total_codes,
    array_agg(DISTINCT icd_category) as icd_categories,
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM severity_categories) * 100, 1) as percentage
FROM severity_categories
GROUP BY severity_level
ORDER BY 
    CASE severity_level
        WHEN 'Low' THEN 1
        WHEN 'Low-Medium' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'High' THEN 4
        WHEN 'Very High' THEN 5
    END;