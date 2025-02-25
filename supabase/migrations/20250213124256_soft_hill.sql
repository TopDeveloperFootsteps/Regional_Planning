-- Create view for service ICD code analysis
CREATE OR REPLACE VIEW service_icd_analysis AS
WITH service_totals AS (
  SELECT 
    service,
    SUM(activity) as total_service_activity
  FROM planning_family_code
  GROUP BY service
),
icd_activity AS (
  SELECT 
    service,
    icd_family,
    SUM(activity) as total_activity,
    COUNT(*) as occurrence_count,
    array_agg(DISTINCT care_setting) as care_settings,
    array_agg(DISTINCT systems_of_care) as systems_of_care
  FROM planning_family_code
  GROUP BY service, icd_family
)
SELECT 
  ia.service,
  ia.icd_family,
  ia.total_activity,
  ROUND((ia.total_activity * 100.0 / st.total_service_activity), 2) as percentage_of_service,
  ia.occurrence_count,
  ia.care_settings,
  ia.systems_of_care
FROM icd_activity ia
JOIN service_totals st ON st.service = ia.service;

-- Add comment
COMMENT ON VIEW service_icd_analysis IS 'Analyzes ICD code distribution within each service';