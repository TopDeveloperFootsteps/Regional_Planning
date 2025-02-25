-- First: Get detailed analysis of remaining unmapped codes for SPECIALTY CARE CENTER
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

-- Get summary statistics
SELECT 
  COUNT(*) as total_records,
  COUNT(*) FILTER (WHERE service IS NULL) as unmapped_records,
  ROUND((COUNT(*) FILTER (WHERE service IS NULL)::numeric / COUNT(*)::numeric * 100), 2) || '%' as unmapped_percentage,
  COUNT(*) FILTER (WHERE confidence = 'high') as high_confidence_count,
  COUNT(*) FILTER (WHERE confidence = 'medium') as medium_confidence_count,
  COUNT(*) FILTER (WHERE confidence = 'low') as low_confidence_count,
  array_agg(DISTINCT "system of care") FILTER (WHERE service IS NULL) as affected_systems
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';