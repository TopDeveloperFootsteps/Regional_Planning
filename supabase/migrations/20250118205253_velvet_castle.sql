/*
  # Add pediatric services mapping data

  1. New Data
    - Add pediatric-focused service mappings for the ambulatory service center
    - All mappings are for the "Children and young people" system of care
    - Include common pediatric ICD-10 codes with their appropriate services

  2. Data Structure
    - ICD codes are stored without descriptions for efficient matching
    - Services are mapped based on pediatric care requirements
    - Confidence levels reflect standard of care guidelines
*/

-- Insert pediatric service mappings
INSERT INTO ambulatory_service_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  ('Z23', 'Well baby care (0 to 4)', 'high', 'Immunization services are a core component of pediatric preventive care', 'Children and young people'),
  
  ('Z20', 'Acute & urgent care', 'high', 'Assessment and management of potential communicable disease exposure requires prompt evaluation', 'Children and young people'),
  
  ('Z00', 'Routine health checks', 'high', 'Regular health examinations are essential for monitoring child growth and development', 'Children and young people'),
  
  ('Z03', 'Acute & urgent care', 'medium', 'Medical observation for suspected conditions requires appropriate monitoring and assessment', 'Children and young people'),
  
  ('M25', 'Allied Health & Health Promotion', 'high', 'Joint disorders in children often require physical therapy and rehabilitation services', 'Children and young people'),
  
  ('J30', 'Acute & urgent care', 'high', 'Allergic conditions require proper evaluation and management in an ambulatory setting', 'Children and young people'),
  
  ('Z02', 'Routine health checks', 'high', 'Administrative examinations are part of routine pediatric care services', 'Children and young people'),
  
  ('J02', 'Acute & urgent care', 'high', 'Acute throat infections require prompt evaluation and treatment', 'Children and young people'),
  
  ('J06', 'Acute & urgent care', 'high', 'Upper respiratory infections need appropriate assessment and management', 'Children and young people'),
  
  ('F80', 'Allied Health & Health Promotion', 'high', 'Speech and language disorders require specialized therapeutic intervention', 'Children and young people'),
  
  ('B07', 'Acute & urgent care', 'medium', 'Viral warts may require dermatological treatment in an ambulatory setting', 'Children and young people'),
  
  ('F84', 'Allied Health & Health Promotion', 'high', 'Developmental disorders require comprehensive evaluation and ongoing therapy', 'Children and young people'),
  
  ('R10', 'Acute & urgent care', 'high', 'Abdominal pain requires proper evaluation and diagnosis', 'Children and young people'),
  
  ('M79', 'Allied Health & Health Promotion', 'medium', 'Soft tissue disorders may require physical therapy and rehabilitation', 'Children and young people'),
  
  ('Z01', 'Routine health checks', 'high', 'Special examinations are part of comprehensive pediatric care', 'Children and young people'),
  
  ('Z11', 'Routine health checks', 'high', 'Screening for infectious diseases is essential for preventive pediatric care', 'Children and young people');

-- Create index for faster searches on systems_of_care
CREATE INDEX IF NOT EXISTS idx_ambulatory_service_center_services_mapping_systems_of_care
ON ambulatory_service_center_services_mapping (systems_of_care);