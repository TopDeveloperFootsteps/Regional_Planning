-- Get detailed analysis of remaining unmapped codes
WITH unmapped_stats AS (
  SELECT 
    "care setting",
    "system of care",
    LEFT("icd family code", 3) as icd_prefix,
    COUNT(*) as count,
    array_agg(DISTINCT "icd family code") as icd_codes
  FROM encounters
  WHERE service IS NULL
  GROUP BY "care setting", "system of care", LEFT("icd family code", 3)
  ORDER BY COUNT(*) DESC
)
SELECT 
  "care setting",
  "system of care",
  icd_prefix,
  count,
  icd_codes
FROM unmapped_stats
ORDER BY count DESC;

-- Get summary statistics by care setting
SELECT 
  "care setting",
  COUNT(*) as total_records,
  COUNT(*) FILTER (WHERE service IS NULL) as unmapped_records,
  ROUND((COUNT(*) FILTER (WHERE service IS NULL)::numeric / COUNT(*)::numeric * 100), 2) || '%' as unmapped_percentage,
  array_agg(DISTINCT "system of care") FILTER (WHERE service IS NULL) as affected_systems
FROM encounters
GROUP BY "care setting"
ORDER BY unmapped_records DESC;