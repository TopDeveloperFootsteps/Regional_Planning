/*
  # Check Specialty Care Center Mapping Status

  1. Analysis
    - Show total mapping statistics
    - List unmapped ICD codes
    - Group by systems of care
*/

-- First: Show overall mapping statistics
WITH mapping_stats AS (
  SELECT 
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) as mapping_percentage
  FROM encounters
  WHERE "care setting" = 'SPECIALTY CARE CENTER'
)
SELECT 
  total_records,
  mapped_records,
  unmapped_records,
  mapping_percentage || '%' as mapping_percentage
FROM mapping_stats;

-- Second: Show unmapped codes grouped by system of care
SELECT 
  "system of care",
  "icd family code",
  COUNT(*) as encounter_count
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER'
  AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
GROUP BY "system of care", "icd family code"
ORDER BY "system of care", "icd family code";

-- Third: Show unmapped codes distribution by system of care
SELECT 
  "system of care",
  COUNT(*) as total_unmapped,
  COUNT(DISTINCT "icd family code") as unique_icd_codes,
  ROUND((COUNT(*)::numeric / (
    SELECT COUNT(*)::numeric 
    FROM encounters 
    WHERE "care setting" = 'SPECIALTY CARE CENTER' 
    AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
  ) * 100), 2) || '%' as percentage_of_unmapped
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER'
  AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
GROUP BY "system of care"
ORDER BY total_unmapped DESC;