-- First: Get current unmapped codes statistics
WITH unmapped_stats AS (
  SELECT 
    "system of care",
    LEFT("icd family code", 3) as icd_prefix,
    COUNT(*) as count
  FROM encounters
  WHERE "care setting" = 'SPECIALTY CARE CENTER'
  AND service IS NULL
  GROUP BY "system of care", LEFT("icd family code", 3)
  ORDER BY COUNT(*) DESC
)
SELECT * FROM unmapped_stats;

-- Get overall mapping statistics
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

-- Show sample of unmapped records
SELECT DISTINCT 
    "system of care",
    "icd family code",
    COUNT(*) as count
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER'
AND service IS NULL
GROUP BY "system of care", "icd family code"
ORDER BY count DESC
LIMIT 20;