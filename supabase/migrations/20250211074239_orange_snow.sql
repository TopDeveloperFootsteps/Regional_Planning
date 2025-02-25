-- Create view for service care setting distribution
CREATE OR REPLACE VIEW service_care_setting_distribution AS
WITH service_totals AS (
  SELECT 
    service,
    SUM(activity) as total_activity
  FROM planning_family_code
  GROUP BY service
),
care_setting_distribution AS (
  SELECT 
    pfc.service,
    pfc.care_setting,
    SUM(pfc.activity) as setting_activity,
    st.total_activity
  FROM planning_family_code pfc
  JOIN service_totals st ON st.service = pfc.service
  GROUP BY pfc.service, pfc.care_setting, st.total_activity
)
SELECT 
  service,
  care_setting,
  setting_activity,
  ROUND((setting_activity * 100.0 / total_activity), 2) as percentage
FROM care_setting_distribution
ORDER BY service, percentage DESC;

-- Create view for service activity summary
CREATE OR REPLACE VIEW service_activity_summary AS
WITH total_activity AS (
  SELECT SUM(activity) as total
  FROM planning_family_code
),
care_setting_percentages AS (
  SELECT 
    service,
    care_setting,
    SUM(activity) as setting_activity,
    SUM(SUM(activity)) OVER (PARTITION BY service) as service_total
  FROM planning_family_code
  GROUP BY service, care_setting
),
service_totals AS (
  SELECT
    service,
    SUM(activity) as total_activity,
    (SELECT total FROM total_activity) as grand_total
  FROM planning_family_code
  GROUP BY service
),
care_setting_distribution AS (
  SELECT
    service,
    jsonb_object_agg(
      care_setting,
      ROUND((setting_activity * 100.0 / service_total), 2)
    ) as care_setting_distribution
  FROM care_setting_percentages
  GROUP BY service
)
SELECT 
  st.service,
  st.total_activity,
  ROUND((st.total_activity * 100.0 / st.grand_total), 2) as percentage,
  csd.care_setting_distribution
FROM service_totals st
JOIN care_setting_distribution csd ON csd.service = st.service
ORDER BY st.total_activity DESC;