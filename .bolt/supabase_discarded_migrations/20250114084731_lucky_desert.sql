INSERT INTO home_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Complex condition / Frail elderly (70 codes)
  ('R70.0', 'Complex condition / Frail elderly', 'high', 'Elevated erythrocyte sedimentation rate', 'Complex, multi-morbid'),
  ('R70.1', 'Complex condition / Frail elderly', 'high', 'Abnormal plasma viscosity', 'Complex, multi-morbid'),
  ('R71.0', 'Complex condition / Frail elderly', 'high', 'Precipitous drop in hematocrit', 'Complex, multi-morbid'),
  ('R71.8', 'Complex condition / Frail elderly', 'high', 'Other abnormality of red blood cells', 'Complex, multi-morbid'),
  ('R73.01', 'Complex condition / Frail elderly', 'high', 'Impaired fasting glucose', 'Complex, multi-morbid'),
  ('R73.02', 'Complex condition / Frail elderly', 'high', 'Impaired glucose tolerance (oral)', 'Complex, multi-morbid'),
  ('R73.09', 'Complex condition / Frail elderly', 'high', 'Other abnormal glucose', 'Complex, multi-morbid'),
  ('R73.9', 'Complex condition / Frail elderly', 'high', 'Hyperglycemia, unspecified', 'Complex, multi-morbid'),
  ('R74.0', 'Complex condition / Frail elderly', 'high', 'Nonspecific elevation of levels of transaminase and lactic acid dehydrogenase [LDH]', 'Complex, multi-morbid'),
  ('R74.8', 'Complex condition / Frail elderly', 'high', 'Abnormal levels of other serum enzymes', 'Complex, multi-morbid'),
  ('R74.9', 'Complex condition / Frail elderly', 'high', 'Abnormal serum enzyme level, unspecified', 'Complex, multi-morbid');

-- Add corresponding entries to home_codes if they don't exist
INSERT INTO home_codes ("Care Setting", "Systems of Care", "ICD FamilyCode")
SELECT 
    'HOME',
    systems_of_care,
    icd_code
FROM home_services_mapping
WHERE NOT EXISTS (
    SELECT 1 FROM home_codes WHERE "ICD FamilyCode" = home_services_mapping.icd_code
)
ON CONFLICT DO NOTHING;