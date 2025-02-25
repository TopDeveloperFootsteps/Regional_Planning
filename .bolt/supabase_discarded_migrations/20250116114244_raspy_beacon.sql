-- First add the systems_of_care column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'home_services_mapping' 
        AND column_name = 'systems_of_care'
    ) THEN
        ALTER TABLE home_services_mapping ADD COLUMN systems_of_care text;
    END IF;
END $$;

-- Update existing mappings with appropriate systems_of_care
UPDATE home_services_mapping
SET systems_of_care = 
  CASE icd_code
    WHEN 'E11.9' THEN 'Chronic conditions'
    WHEN 'I10' THEN 'Chronic conditions'
    WHEN 'J44.9' THEN 'Chronic conditions'
    WHEN 'F32.9' THEN 'Complex, multi-morbid'
    WHEN 'M17.9' THEN 'Complex, multi-morbid'
    WHEN 'Z71.3' THEN 'Wellness and longevity'
    WHEN 'Z51.89' THEN 'Complex, multi-morbid'
    WHEN 'I48.91' THEN 'Chronic conditions'
    WHEN 'Z74.09' THEN 'Complex, multi-morbid'
    WHEN 'R26.81' THEN 'Complex, multi-morbid'
  END
WHERE icd_code IN (
  'E11.9', 'I10', 'J44.9', 'F32.9', 'M17.9', 'Z71.3', 
  'Z51.89', 'I48.91', 'Z74.09', 'R26.81'
);

-- Create a view to identify unmapped codes
CREATE OR REPLACE VIEW unmapped_home_codes AS
SELECT 
    hc."ICD FamilyCode" as icd_code,
    hc."Systems of Care" as systems_of_care,
    'Not mapped' as status
FROM 
    home_codes hc
LEFT JOIN 
    home_services_mapping hsm 
    ON hc."ICD FamilyCode" = hsm.icd_code 
    AND hc."Systems of Care" = hsm.systems_of_care
WHERE 
    hsm.id IS NULL;

-- Add more mappings with system of care consideration
INSERT INTO home_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('I11.9', 'Chronic metabolic diseases', 'high', 'Hypertensive heart disease without heart failure requires regular monitoring and management', 'Chronic conditions'),
  ('I11.9', 'Complex condition / Frail elderly', 'medium', 'When part of multiple conditions in elderly patients, requires comprehensive care approach', 'Complex, multi-morbid'),
  ('E78.5', 'Chronic metabolic diseases', 'high', 'Dyslipidemia requires regular monitoring and lifestyle management', 'Chronic conditions'),
  ('M54.5', 'Allied Health & Health Promotion', 'high', 'Low back pain can be effectively managed through home-based physical therapy', 'Planned care'),
  ('G47.00', 'Complex condition / Frail elderly', 'medium', 'Insomnia requires comprehensive sleep hygiene and lifestyle interventions', 'Complex, multi-morbid'),
  ('K21.9', 'Allied Health & Health Promotion', 'medium', 'GERD can be managed through dietary modifications and lifestyle changes', 'Chronic conditions'),
  ('N39.0', 'Complex condition / Frail elderly', 'high', 'Urinary tract infection in elderly requires careful monitoring and management', 'Complex, multi-morbid'),
  ('Z96.651', 'Complex condition / Frail elderly', 'high', 'Presence of joint implant requires ongoing monitoring and care', 'Complex, multi-morbid'),
  ('R26.2', 'Allied Health & Health Promotion', 'high', 'Difficulty in walking requires regular physical therapy and exercise guidance', 'Planned care'),
  ('I73.9', 'Chronic metabolic diseases', 'medium', 'Peripheral vascular disease requires regular monitoring and management', 'Chronic conditions');