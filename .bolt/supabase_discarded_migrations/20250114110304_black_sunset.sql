/*
  # Rename home_sp table to home_sm

  1. Changes
    - Rename table from home_sp to home_sm
    - Update dependent views to use new table name
*/

-- Rename the table
ALTER TABLE home_sp RENAME TO home_sm;

-- Drop existing views that depend on the old table name
DROP VIEW IF EXISTS home_sp_stats;
DROP VIEW IF EXISTS home_sp_mapping_by_system;
DROP VIEW IF EXISTS home_sp_final_stats;

-- Recreate views with new table name
CREATE OR REPLACE VIEW home_sm_stats AS
SELECT 
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as mapped_rows,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_rows,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapped_percentage
FROM home_sm;

CREATE OR REPLACE VIEW home_sm_mapping_by_system AS
SELECT 
    systems_of_care,
    COUNT(*) as total_codes,
    COUNT(*) FILTER (WHERE service IS NOT NULL) as mapped_codes,
    COUNT(*) FILTER (WHERE service IS NULL) as unmapped_codes,
    ROUND(COUNT(*) FILTER (WHERE service IS NOT NULL)::numeric / COUNT(*)::numeric * 100, 2) as mapped_percentage
FROM home_sm
GROUP BY systems_of_care
ORDER BY systems_of_care;

CREATE OR REPLACE VIEW home_sm_final_stats AS
SELECT 
    service,
    systems_of_care,
    COUNT(*) as code_count,
    confidence,
    STRING_AGG(DISTINCT LEFT(icd_code, 1), ', ') as icd_categories
FROM home_sm
WHERE service IS NOT NULL
GROUP BY service, systems_of_care, confidence
ORDER BY service, systems_of_care;