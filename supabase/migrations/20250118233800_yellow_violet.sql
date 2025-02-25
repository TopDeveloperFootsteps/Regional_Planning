-- First: Get current mapping statistics
WITH mapping_stats AS (
  SELECT 
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) as mapping_percentage,
    COUNT(*) FILTER (WHERE confidence = 'high') as high_confidence,
    COUNT(*) FILTER (WHERE confidence = 'medium') as medium_confidence,
    COUNT(*) FILTER (WHERE confidence = 'low') as low_confidence
  FROM encounters
  WHERE "care setting" = 'SPECIALTY CARE CENTER'
)
SELECT 
  total_records,
  mapped_records,
  unmapped_records,
  mapping_percentage || '%' as mapping_percentage,
  high_confidence as high_confidence_mappings,
  medium_confidence as medium_confidence_mappings,
  low_confidence as low_confidence_mappings
FROM mapping_stats;

-- Get distribution of unmapped codes by system of care
SELECT 
  "system of care",
  COUNT(*) as unmapped_count,
  array_agg(DISTINCT LEFT("icd family code", 3)) as icd_prefixes
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER'
AND service IS NULL
GROUP BY "system of care"
ORDER BY unmapped_count DESC;

-- Update remaining unmapped encounters using ServiceList 2
UPDATE encounters 
SET 
  service = CASE 
    -- Complex, multi-morbid cases
    WHEN "system of care" = 'Complex, multi-morbid' THEN 
      CASE 
        WHEN LEFT("icd family code", 1) = 'C' THEN 'Oncology'
        WHEN LEFT("icd family code", 1) = 'D' THEN 'Haematology'
        WHEN LEFT("icd family code", 1) = 'G' THEN 'Neurology (inc. neurophysiology and neuropathology)'
        WHEN LEFT("icd family code", 1) = 'I' THEN 'Cardiology'
        WHEN LEFT("icd family code", 1) = 'M' THEN 'Rheumatology'
        WHEN LEFT("icd family code", 1) = 'N' THEN 'Nephrology'
        ELSE 'Complex condition / Frail elderly'
      END
    
    -- Chronic conditions
    WHEN "system of care" = 'Chronic conditions' THEN 
      CASE 
        WHEN LEFT("icd family code", 1) = 'E' THEN 'Endocrinology'
        WHEN LEFT("icd family code", 1) = 'J' THEN 'Pulmonology / Respiratory Medicine'
        WHEN LEFT("icd family code", 1) = 'K' THEN 'Gastroenterology'
        WHEN LEFT("icd family code", 1) = 'L' THEN 'Dermatology'
        ELSE 'Internal Medicine'
      END
    
    -- Children and young people
    WHEN "system of care" = 'Children and young people' THEN 
      CASE 
        WHEN LEFT("icd family code", 1) = 'Q' THEN 'Medical Genetics'
        WHEN LEFT("icd family code", 1) = 'P' THEN 'Paediatric Medicine'
        ELSE 'Paediatric Medicine'
      END
    
    -- Unplanned care
    WHEN "system of care" = 'Unplanned care' THEN 
      CASE 
        WHEN LEFT("icd family code", 1) = 'S' THEN 'Trauma and Emergency Medicine'
        WHEN LEFT("icd family code", 1) = 'T' THEN 'Trauma and Emergency Medicine'
        WHEN LEFT("icd family code", 1) = 'R' THEN 'Critical Care Medicine'
        ELSE 'Acute & urgent care'
      END
    
    -- Planned care
    WHEN "system of care" = 'Planned care' THEN 
      CASE 
        WHEN LEFT("icd family code", 1) = 'Z' THEN 'Social, Community and Preventative Medicine'
        WHEN LEFT("icd family code", 1) = 'O' THEN 'Obstetrics & Gynaecology'
        ELSE 'Allied Health & Health Promotion'
      END
    
    -- Palliative care
    WHEN "system of care" = 'Palliative care and support' THEN 'Hospice and Palliative Care'
    
    ELSE 'Internal Medicine'
  END,
  confidence = 'medium',
  "mapping logic" = 'Mapped based on ICD code category and system of care using ServiceList 2'
WHERE "care setting" = 'SPECIALTY CARE CENTER'
AND service IS NULL;

-- Show final mapping statistics
SELECT 
    'SPECIALTY CARE CENTER' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage,
    COUNT(*) FILTER (WHERE confidence = 'high') as high_confidence_count,
    COUNT(*) FILTER (WHERE confidence = 'medium') as medium_confidence_count,
    COUNT(*) FILTER (WHERE confidence = 'low') as low_confidence_count
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';