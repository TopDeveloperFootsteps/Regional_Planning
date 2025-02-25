-- Create a view to identify null service mappings
CREATE OR REPLACE VIEW hospital_null_mappings AS
SELECT 
    icd_code,
    systems_of_care,
    confidence,
    mapping_logic
FROM hospital_services_mapping
WHERE service IS NULL;

-- Update remaining null services with more specific mappings
UPDATE hospital_services_mapping
SET 
    service = CASE 
        -- Diagnostic Services
        WHEN icd_code LIKE 'R7%' THEN 'Laboratory'
        WHEN icd_code LIKE 'R9%' THEN 'Diagnostics & Therapeutics'
        
        -- Specialized Care
        WHEN icd_code LIKE 'I5%' THEN 'Cardiology'
        WHEN icd_code LIKE 'J9%' THEN 'Critical Care Medicine'
        WHEN icd_code LIKE 'K7%' THEN 'Gastroenterology'
        WHEN icd_code LIKE 'M8%' THEN 'Orthopaedics (inc. podiatry)'
        WHEN icd_code LIKE 'N1%' THEN 'Nephrology'
        WHEN icd_code LIKE 'C7%' THEN 'Oncology'
        WHEN icd_code LIKE 'G4%' THEN 'Neurology (inc. neurophysiology and neuropathology)'
        WHEN icd_code LIKE 'F4%' THEN 'Psychiatry'
        
        -- Age-specific Care
        WHEN icd_code LIKE 'P0%' THEN 'Paediatric Medicine'
        WHEN icd_code LIKE 'P9%' THEN 'Paediatric Medicine'
        
        -- Default mappings based on systems of care
        ELSE CASE 
            WHEN systems_of_care = 'Unplanned care' THEN 'Major Emergency'
            WHEN systems_of_care = 'Planned care' THEN 'Internal Medicine'
            WHEN systems_of_care = 'Children and young people' THEN 'Paediatric Medicine'
            WHEN systems_of_care = 'Complex, multi-morbid' THEN 'Critical Care Medicine'
            WHEN systems_of_care = 'Chronic conditions' THEN 'Internal Medicine'
            WHEN systems_of_care = 'Palliative care and support' THEN 'Hospice and Palliative Care'
            WHEN systems_of_care = 'Wellness and longevity' THEN 'Social, Community and Preventative Medicine'
            ELSE 'Internal Medicine' -- Fallback mapping
        END
    END,
    confidence = CASE 
        WHEN icd_code ~ '^[RIJKNMCGF][0-9]' THEN 'high'
        ELSE 'medium'
    END,
    mapping_logic = CASE 
        WHEN icd_code LIKE 'R7%' THEN 'Laboratory findings requiring specialized testing'
        WHEN icd_code LIKE 'R9%' THEN 'Abnormal findings requiring diagnostic investigation'
        WHEN icd_code LIKE 'I5%' THEN 'Heart failure conditions requiring cardiology care'
        WHEN icd_code LIKE 'J9%' THEN 'Respiratory conditions requiring critical care'
        WHEN icd_code LIKE 'K7%' THEN 'Liver conditions requiring gastroenterology care'
        WHEN icd_code LIKE 'M8%' THEN 'Bone conditions requiring orthopedic care'
        WHEN icd_code LIKE 'N1%' THEN 'Kidney conditions requiring nephrology care'
        WHEN icd_code LIKE 'C7%' THEN 'Secondary malignant neoplasms requiring oncology care'
        WHEN icd_code LIKE 'G4%' THEN 'Episodic disorders requiring neurology care'
        WHEN icd_code LIKE 'F4%' THEN 'Anxiety disorders requiring psychiatric care'
        WHEN icd_code LIKE 'P0%' THEN 'Newborn affected by maternal factors requiring pediatric care'
        WHEN icd_code LIKE 'P9%' THEN 'Other conditions originating in perinatal period requiring pediatric care'
        ELSE 'Mapped based on systems of care and general medical requirements'
    END
WHERE service IS NULL;

-- Create a view to verify no remaining null mappings
CREATE OR REPLACE VIEW hospital_mapping_verification AS
SELECT 
    COUNT(*) as total_mappings,
    COUNT(*) FILTER (WHERE service IS NULL) as null_mappings,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as valid_mappings,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapping_completion_percentage
FROM hospital_services_mapping;