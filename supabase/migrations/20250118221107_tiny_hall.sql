/*
  # Check Mapping Progress Statistics

  This migration creates a view to analyze the mapping progress and returns statistics about:
  1. Total number of records
  2. Number of mapped records
  3. Number of unmapped records
  4. Mapping percentage by care setting
*/

-- Create a view for mapping statistics
CREATE OR REPLACE VIEW mapping_statistics AS
WITH stats AS (
  SELECT 
    "care setting",
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) as mapping_percentage
  FROM encounters
  GROUP BY "care setting"
)
SELECT 
  "care setting",
  total_records,
  mapped_records,
  unmapped_records,
  mapping_percentage || '%' as mapping_percentage
FROM stats
ORDER BY "care setting";

-- Get overall statistics
SELECT 
  COUNT(*) as total_records,
  COUNT(service) as mapped_records,
  COUNT(*) - COUNT(service) as unmapped_records,
  ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as overall_mapping_percentage
FROM encounters;