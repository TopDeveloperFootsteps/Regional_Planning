/*
  # Add initial home services mapping data

  1. Data Population
    - Add 10 sample ICD code mappings for home services
    - Include confidence levels and mapping logic
  2. Mapping Strategy
    - Map codes to relevant home-based services
    - Provide detailed explanations for each mapping
*/

INSERT INTO home_services_mapping (icd_code, service, confidence, mapping_logic) 
VALUES
  ('E11.9', 'Chronic metabolic diseases', 'high', 'Type 2 diabetes without complications is commonly managed through home care with regular monitoring and lifestyle management'),
  ('I10', 'Chronic metabolic diseases', 'high', 'Essential hypertension requires regular monitoring and medication management, ideal for home-based care'),
  ('J44.9', 'Chronic respiratory diseases', 'high', 'Chronic obstructive pulmonary disease requires ongoing monitoring and management at home'),
  ('F32.9', 'Chronic mental health disorders', 'medium', 'Depressive disorder can be managed through home-based care with regular professional support'),
  ('M17.9', 'Allied Health & Health Promotion', 'medium', 'Osteoarthritis of knee requires regular physical therapy and exercise which can be done at home'),
  ('Z71.3', 'Allied Health & Health Promotion', 'high', 'Dietary counseling and surveillance can be effectively delivered through home-based care'),
  ('Z51.89', 'Complex condition / Frail elderly', 'high', 'Other specified aftercare is often best managed through home care for complex conditions'),
  ('I48.91', 'Chronic metabolic diseases', 'medium', 'Atrial fibrillation requires regular monitoring that can be done at home with proper equipment'),
  ('Z74.09', 'Complex condition / Frail elderly', 'high', 'Other reduced mobility requiring care provider can be effectively managed through home care'),
  ('R26.81', 'Allied Health & Health Promotion', 'medium', 'Unsteadiness on feet requires regular physical therapy and exercise guidance at home');