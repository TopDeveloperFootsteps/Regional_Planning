-- Update extended services mapping with OPD services
UPDATE extended_services_mapping
SET 
    service = CASE 
        WHEN LEFT(icd_code, 1) = 'A' OR LEFT(icd_code, 1) = 'B' THEN 'Infectious Diseases'
        WHEN LEFT(icd_code, 1) = 'C' THEN 'Oncology'
        WHEN LEFT(icd_code, 1) = 'D' THEN 'Haematology'
        WHEN LEFT(icd_code, 1) = 'E' THEN 'Endocrinology'
        WHEN LEFT(icd_code, 1) = 'F' THEN 'Psychiatry'
        WHEN LEFT(icd_code, 1) = 'G' THEN 'Neurology (inc. neurophysiology and neuropathology)'
        WHEN LEFT(icd_code, 1) = 'H' THEN 
            CASE 
                WHEN SUBSTRING(icd_code, 1, 2) IN ('H0', 'H1', 'H2', 'H3', 'H4', 'H5') THEN 'Ophthalmology'
                ELSE 'Otolaryngology / ENT'
            END
        WHEN LEFT(icd_code, 1) = 'I' THEN 'Cardiology'
        WHEN LEFT(icd_code, 1) = 'J' THEN 'Pulmonology / Respiratory Medicine'
        WHEN LEFT(icd_code, 1) = 'K' THEN 'Gastroenterology'
        WHEN LEFT(icd_code, 1) = 'L' THEN 'Dermatology'
        WHEN LEFT(icd_code, 1) = 'M' THEN 'Orthopaedics (inc. podiatry)'
        WHEN LEFT(icd_code, 1) = 'N' THEN 'Nephrology'
        WHEN LEFT(icd_code, 1) = 'O' THEN 'Obstetrics & Gynaecology'
        WHEN LEFT(icd_code, 1) = 'P' THEN 'Paediatric Medicine'
        WHEN LEFT(icd_code, 1) = 'Q' THEN 'Medical Genetics'
        WHEN LEFT(icd_code, 1) = 'R' THEN 'Internal Medicine'
        WHEN LEFT(icd_code, 1) IN ('S', 'T') THEN 'Trauma and Emergency Medicine'
        WHEN LEFT(icd_code, 1) IN ('V', 'W', 'X', 'Y') THEN 'Major Emergency'
        WHEN LEFT(icd_code, 1) = 'Z' THEN 'Social, Community and Preventative Medicine'
    END,
    confidence = 'high',
    mapping_logic = CASE 
        WHEN LEFT(icd_code, 1) = 'A' OR LEFT(icd_code, 1) = 'B' THEN 'Infectious disease requiring extended specialist care'
        WHEN LEFT(icd_code, 1) = 'C' THEN 'Cancer requiring extended treatment and care'
        WHEN LEFT(icd_code, 1) = 'D' THEN 'Blood disorder requiring extended specialist care'
        WHEN LEFT(icd_code, 1) = 'E' THEN 'Endocrine disorder requiring extended management'
        WHEN LEFT(icd_code, 1) = 'F' THEN 'Mental health condition requiring extended psychiatric care'
        WHEN LEFT(icd_code, 1) = 'G' THEN 'Neurological condition requiring extended specialist care'
        WHEN LEFT(icd_code, 1) = 'H' THEN 
            CASE 
                WHEN SUBSTRING(icd_code, 1, 2) IN ('H0', 'H1', 'H2', 'H3', 'H4', 'H5') THEN 'Eye condition requiring extended ophthalmology care'
                ELSE 'Ear/throat condition requiring extended ENT care'
            END
        WHEN LEFT(icd_code, 1) = 'I' THEN 'Cardiovascular condition requiring extended specialist care'
        WHEN LEFT(icd_code, 1) = 'J' THEN 'Respiratory condition requiring extended pulmonologist care'
        WHEN LEFT(icd_code, 1) = 'K' THEN 'Digestive condition requiring extended gastroenterology care'
        WHEN LEFT(icd_code, 1) = 'L' THEN 'Skin condition requiring extended dermatology care'
        WHEN LEFT(icd_code, 1) = 'M' THEN 'Musculoskeletal condition requiring extended orthopedic care'
        WHEN LEFT(icd_code, 1) = 'N' THEN 'Kidney condition requiring extended nephrology care'
        WHEN LEFT(icd_code, 1) = 'O' THEN 'Pregnancy/gynecological condition requiring extended specialist care'
        WHEN LEFT(icd_code, 1) = 'P' THEN 'Pediatric condition requiring extended specialist care'
        WHEN LEFT(icd_code, 1) = 'Q' THEN 'Congenital condition requiring extended genetic specialist care'
        WHEN LEFT(icd_code, 1) = 'R' THEN 'General medical condition requiring extended internal medicine'
        WHEN LEFT(icd_code, 1) IN ('S', 'T') THEN 'Trauma/injury requiring extended emergency care'
        WHEN LEFT(icd_code, 1) IN ('V', 'W', 'X', 'Y') THEN 'Major emergency requiring extended specialist care'
        WHEN LEFT(icd_code, 1) = 'Z' THEN 'Health factor requiring extended preventative medicine'
    END
WHERE service = 'Pending Review';

-- Update remaining unmapped codes based on systems of care
UPDATE extended_services_mapping
SET 
    service = CASE 
        WHEN systems_of_care = 'Unplanned care' THEN 'Major Emergency'
        WHEN systems_of_care = 'Planned care' THEN 'Internal Medicine'
        WHEN systems_of_care = 'Children and young people' THEN 'Paediatric Medicine'
        WHEN systems_of_care = 'Complex, multi-morbid' THEN 'Internal Medicine'
        WHEN systems_of_care = 'Chronic conditions' THEN 'Internal Medicine'
        WHEN systems_of_care = 'Palliative care and support' THEN 'Hospice and Palliative Care'
        WHEN systems_of_care = 'Wellness and longevity' THEN 'Social, Community and Preventative Medicine'
    END,
    confidence = 'medium',
    mapping_logic = CASE 
        WHEN systems_of_care = 'Unplanned care' THEN 'Mapped based on unplanned care requirement in extended care setting'
        WHEN systems_of_care = 'Planned care' THEN 'Mapped based on planned care requirement in extended care setting'
        WHEN systems_of_care = 'Children and young people' THEN 'Mapped based on pediatric care requirement in extended care setting'
        WHEN systems_of_care = 'Complex, multi-morbid' THEN 'Mapped based on complex care requirement in extended care setting'
        WHEN systems_of_care = 'Chronic conditions' THEN 'Mapped based on chronic care requirement in extended care setting'
        WHEN systems_of_care = 'Palliative care and support' THEN 'Mapped based on palliative care requirement in extended care setting'
        WHEN systems_of_care = 'Wellness and longevity' THEN 'Mapped based on wellness requirement in extended care setting'
    END
WHERE service = 'Pending Review';

-- Create a view to show mapping statistics by extended service
CREATE OR REPLACE VIEW extended_mapping_by_service AS
SELECT 
    service,
    systems_of_care,
    COUNT(*) as code_count,
    confidence,
    STRING_AGG(DISTINCT LEFT(icd_code, 1), ', ' ORDER BY LEFT(icd_code, 1)) as icd_categories
FROM extended_services_mapping
WHERE service IS NOT NULL
GROUP BY service, systems_of_care, confidence
ORDER BY service, systems_of_care;