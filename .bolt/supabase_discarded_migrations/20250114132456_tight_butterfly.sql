-- Create a view to analyze current mappings
CREATE OR REPLACE VIEW hospital_service_type_analysis AS
SELECT 
    service,
    COUNT(*) as code_count,
    STRING_AGG(DISTINCT LEFT(icd_code, 1), ', ') as icd_categories,
    CASE 
        WHEN service = ANY(ARRAY[
            'Major Emergency',
            'Minor Emergency',
            'Anesthesiology',
            'Social, Community and Preventative Medicine'
        ]) THEN 'OPD'
        WHEN service = ANY(ARRAY[
            'Critical Care Medicine',
            'Skilled Nursing',
            'Diagnostics & Therapeutics'
        ]) THEN 'Inpatient'
        ELSE 'Mixed'
    END as current_type
FROM hospital_services_mapping
GROUP BY service;

-- Update mappings based on common admission patterns
UPDATE hospital_services_mapping
SET 
    service = CASE 
        -- Clear Inpatient Cases
        WHEN icd_code LIKE 'S%' AND SUBSTRING(icd_code FROM '\\.([0-9])') = '1' THEN 'Trauma and Emergency Medicine'
        WHEN icd_code LIKE 'T%' AND SUBSTRING(icd_code FROM '\\.([0-9])') = '1' THEN 'Critical Care Medicine'
        WHEN icd_code LIKE 'I21%' OR icd_code LIKE 'I22%' THEN 'Cardiology'
        WHEN icd_code LIKE 'J96%' THEN 'Critical Care Medicine'
        WHEN icd_code LIKE 'K35%' OR icd_code LIKE 'K36%' OR icd_code LIKE 'K37%' OR icd_code LIKE 'K38%' THEN 'General Surgery'
        WHEN icd_code LIKE 'O80%' OR icd_code LIKE 'O81%' OR icd_code LIKE 'O82%' OR icd_code LIKE 'O83%' OR icd_code LIKE 'O84%' THEN 'Obstetrics & Gynaecology'
        WHEN icd_code LIKE 'F20%' OR icd_code LIKE 'F21%' OR icd_code LIKE 'F22%' OR icd_code LIKE 'F23%' OR icd_code LIKE 'F24%' OR icd_code LIKE 'F25%' OR icd_code LIKE 'F26%' OR icd_code LIKE 'F27%' OR icd_code LIKE 'F28%' OR icd_code LIKE 'F29%' THEN 'Psychiatry'
        WHEN icd_code LIKE 'C%' THEN 'Oncology'
        
        -- Clear OPD Cases
        WHEN icd_code LIKE 'Z%' THEN 'Internal Medicine'
        WHEN icd_code LIKE 'L%' AND SUBSTRING(icd_code FROM '\\.([0-9])') != '3' THEN 'Dermatology'
        WHEN icd_code LIKE 'H%' AND SUBSTRING(icd_code FROM '\\.([0-9])') != '3' THEN 
            CASE 
                WHEN LEFT(icd_code, 2) IN ('H0', 'H1', 'H2', 'H3', 'H4', 'H5') THEN 'Ophthalmology'
                ELSE 'Otolaryngology / ENT'
            END
        WHEN icd_code LIKE 'M%' AND SUBSTRING(icd_code FROM '\\.([0-9])') != '2' THEN 'Orthopaedics (inc. podiatry)'
        
        -- Mixed Cases - Default to Inpatient for severity indicators
        WHEN SUBSTRING(icd_code FROM '\\.([0-9])') = '3' THEN 
            CASE 
                WHEN icd_code LIKE 'J%' THEN 'Pulmonology / Respiratory Medicine'
                WHEN icd_code LIKE 'K%' THEN 'Gastroenterology'
                WHEN icd_code LIKE 'N%' THEN 'Nephrology'
                ELSE 'Internal Medicine'
            END
        
        -- Keep existing mapping if not matching specific patterns
        ELSE service
    END,
    confidence = CASE 
        WHEN SUBSTRING(icd_code FROM '\\.([0-9])') IN ('1', '2', '3') THEN 'high'
        ELSE confidence
    END,
    mapping_logic = CASE 
        WHEN icd_code LIKE 'S%' AND SUBSTRING(icd_code FROM '\\.([0-9])') = '1' THEN 'Major trauma requiring inpatient trauma care'
        WHEN icd_code LIKE 'T%' AND SUBSTRING(icd_code FROM '\\.([0-9])') = '1' THEN 'Severe injury/poisoning requiring critical care'
        WHEN icd_code LIKE 'I21%' OR icd_code LIKE 'I22%' THEN 'Acute cardiac condition requiring inpatient cardiology care'
        WHEN icd_code LIKE 'J96%' THEN 'Respiratory failure requiring critical care'
        WHEN icd_code LIKE 'K35%' OR icd_code LIKE 'K36%' OR icd_code LIKE 'K37%' OR icd_code LIKE 'K38%' THEN 'Acute surgical condition requiring inpatient care'
        WHEN icd_code LIKE 'O80%' OR icd_code LIKE 'O81%' OR icd_code LIKE 'O82%' OR icd_code LIKE 'O83%' OR icd_code LIKE 'O84%' THEN 'Delivery complications requiring inpatient obstetric care'
        WHEN icd_code LIKE 'F2%' THEN 'Severe psychiatric condition requiring inpatient care'
        WHEN icd_code LIKE 'C%' THEN 'Active cancer requiring inpatient oncology care'
        WHEN icd_code LIKE 'Z%' THEN 'Health examination suitable for outpatient care'
        WHEN icd_code LIKE 'L%' AND SUBSTRING(icd_code FROM '\\.([0-9])') != '3' THEN 'Skin condition manageable in outpatient setting'
        WHEN icd_code LIKE 'H%' AND SUBSTRING(icd_code FROM '\\.([0-9])') != '3' THEN 'Sensory condition suitable for outpatient care'
        WHEN icd_code LIKE 'M%' AND SUBSTRING(icd_code FROM '\\.([0-9])') != '2' THEN 'Musculoskeletal condition manageable in outpatient setting'
        WHEN SUBSTRING(icd_code FROM '\\.([0-9])') = '3' THEN 'Condition with complications requiring inpatient care'
        ELSE mapping_logic
    END
WHERE service IS NOT NULL;

-- Create a view to show inpatient vs OPD distribution
CREATE OR REPLACE VIEW hospital_service_distribution AS
SELECT 
    CASE 
        WHEN service = ANY(ARRAY[
            'Major Emergency',
            'Minor Emergency',
            'Anesthesiology',
            'Social, Community and Preventative Medicine'
        ]) THEN 'OPD'
        WHEN service = ANY(ARRAY[
            'Critical Care Medicine',
            'Skilled Nursing',
            'Diagnostics & Therapeutics',
            'Trauma and Emergency Medicine'
        ]) THEN 'Inpatient'
        ELSE 'Mixed'
    END as service_type,
    COUNT(*) as code_count,
    ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER() * 100, 2) as percentage
FROM hospital_services_mapping
GROUP BY 
    CASE 
        WHEN service = ANY(ARRAY[
            'Major Emergency',
            'Minor Emergency',
            'Anesthesiology',
            'Social, Community and Preventative Medicine'
        ]) THEN 'OPD'
        WHEN service = ANY(ARRAY[
            'Critical Care Medicine',
            'Skilled Nursing',
            'Diagnostics & Therapeutics',
            'Trauma and Emergency Medicine'
        ]) THEN 'Inpatient'
        ELSE 'Mixed'
    END
ORDER BY service_type;