-- Analyze unmapped encounters
WITH unmapped_analysis AS (
  SELECT 
    "system of care",
    LEFT("icd family code", 3) as icd_prefix,
    COUNT(*) as count,
    array_agg(DISTINCT "icd family code") as icd_codes
  FROM encounters
  WHERE service IS NULL
  GROUP BY "system of care", LEFT("icd family code", 3)
  ORDER BY count DESC
)
SELECT 
  "system of care",
  icd_prefix,
  count,
  icd_codes
FROM unmapped_analysis
ORDER BY count DESC;

-- Get overall statistics
SELECT 
  COUNT(*) as total_encounters,
  COUNT(*) FILTER (WHERE service IS NULL) as unmapped_encounters,
  ROUND((COUNT(*) FILTER (WHERE service IS NULL)::numeric / COUNT(*)::numeric * 100), 2) as unmapped_percentage,
  COUNT(DISTINCT "system of care") FILTER (WHERE service IS NULL) as affected_systems_of_care
FROM encounters;