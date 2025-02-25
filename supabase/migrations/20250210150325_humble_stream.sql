-- Create view for care setting activity summary
CREATE OR REPLACE VIEW care_setting_activity_summary AS
WITH total_activity AS (
  SELECT SUM(activity) as total
  FROM planning_family_code
)
SELECT 
  care_setting,
  SUM(activity) as total_activity,
  ROUND((SUM(activity) * 100.0 / total), 2) as percentage
FROM planning_family_code, total_activity
GROUP BY care_setting, total
ORDER BY percentage DESC;

-- Create view for care setting activity details
CREATE OR REPLACE VIEW care_setting_activity_details AS
SELECT 
  care_setting,
  service,
  systems_of_care,
  COUNT(*) as code_count,
  SUM(activity) as total_activity,
  ROUND(AVG(activity), 2) as avg_activity_per_code
FROM planning_family_code
GROUP BY care_setting, service, systems_of_care
ORDER BY total_activity DESC;