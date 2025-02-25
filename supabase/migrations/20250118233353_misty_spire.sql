-- First: Get detailed analysis of remaining unmapped codes
WITH unmapped_stats AS (
  SELECT 
    "system of care",
    LEFT("icd family code", 3) as icd_prefix,
    COUNT(*) as count,
    array_agg(DISTINCT "icd family code") as icd_codes
  FROM encounters
  WHERE "care setting" = 'SPECIALTY CARE CENTER'
  AND service IS NULL
  GROUP BY "system of care", LEFT("icd family code", 3)
  ORDER BY COUNT(*) DESC
)
SELECT 
  "system of care",
  icd_prefix,
  count,
  icd_codes
FROM unmapped_stats
ORDER BY count DESC;

-- Add final mappings for any remaining unmapped codes
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Default mappings for each system of care
  ('DEF', 'Complex condition / Frail elderly', 'medium', 'Default mapping for complex multi-morbid conditions', 'Complex, multi-morbid'),
  ('DEF', 'Chronic metabolic diseases', 'medium', 'Default mapping for chronic conditions', 'Chronic conditions'),
  ('DEF', 'Paediatric Medicine', 'medium', 'Default mapping for pediatric care', 'Children and young people'),
  ('DEF', 'Acute & urgent care', 'medium', 'Default mapping for unplanned care', 'Unplanned care'),
  ('DEF', 'Allied Health & Health Promotion', 'medium', 'Default mapping for planned care', 'Planned care'),
  ('DEF', 'Hospice and Palliative Care', 'medium', 'Default mapping for palliative care', 'Palliative care and support');

-- Update any remaining unmapped encounters with system-of-care based mapping
UPDATE encounters 
SET 
  service = CASE "system of care"
    WHEN 'Complex, multi-morbid' THEN 'Complex condition / Frail elderly'
    WHEN 'Chronic conditions' THEN 'Chronic metabolic diseases'
    WHEN 'Children and young people' THEN 'Paediatric Medicine'
    WHEN 'Unplanned care' THEN 'Acute & urgent care'
    WHEN 'Planned care' THEN 'Allied Health & Health Promotion'
    WHEN 'Palliative care and support' THEN 'Hospice and Palliative Care'
  END,
  confidence = 'medium',
  "mapping logic" = 'Mapped based on system of care category'
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