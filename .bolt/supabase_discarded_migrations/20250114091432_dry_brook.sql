/*
  # Add 150 more home service mappings

  1. New Mappings
    - Adding 150 new ICD-10 code mappings for home services
    - Focus on common conditions suitable for home care
    - Covers multiple service types and systems of care

  2. Data Consistency
    - Maintains consistent mapping logic with existing entries
    - Ensures proper systems of care alignment
*/

INSERT INTO home_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Chronic metabolic diseases (30 codes)
  ('E31.0', 'Chronic metabolic diseases', 'high', 'Autoimmune polyglandular failure requires regular monitoring', 'Chronic conditions'),
  ('E31.1', 'Chronic metabolic diseases', 'high', 'Polyglandular hyperfunction needs ongoing care', 'Chronic conditions'),
  ('E31.2', 'Chronic metabolic diseases', 'high', 'Multiple endocrine neoplasia requires monitoring', 'Chronic conditions'),
  ('E31.8', 'Chronic metabolic diseases', 'high', 'Other polyglandular dysfunction needs regular care', 'Chronic conditions'),
  ('E31.9', 'Chronic metabolic diseases', 'high', 'Polyglandular dysfunction, unspecified requires monitoring', 'Chronic conditions'),
  ('E32.0', 'Chronic metabolic diseases', 'high', 'Persistent hyperplasia of thymus needs care', 'Chronic conditions'),
  ('E32.1', 'Chronic metabolic diseases', 'high', 'Abscess of thymus requires monitoring', 'Chronic conditions'),
  ('E32.8', 'Chronic metabolic diseases', 'high', 'Other diseases of thymus need regular care', 'Chronic conditions'),
  ('E32.9', 'Chronic metabolic diseases', 'high', 'Disease of thymus, unspecified requires monitoring', 'Chronic conditions'),
  ('E34.0', 'Chronic metabolic diseases', 'high', 'Carcinoid syndrome needs ongoing care', 'Chronic conditions'),
  ('E34.1', 'Chronic metabolic diseases', 'high', 'Other hypersecretion of intestinal hormones requires monitoring', 'Chronic conditions'),
  ('E34.2', 'Chronic metabolic diseases', 'high', 'Ectopic hormone secretion, not elsewhere classified', 'Chronic conditions'),
  ('E34.3', 'Chronic metabolic diseases', 'high', 'Short stature, not elsewhere classified', 'Chronic conditions'),
  ('E34.4', 'Chronic metabolic diseases', 'high', 'Constitutional tall stature requires monitoring', 'Chronic conditions'),
  ('E34.50', 'Chronic metabolic diseases', 'high', 'Androgen insensitivity syndrome, unspecified', 'Chronic conditions'),
  ('E34.51', 'Chronic metabolic diseases', 'high', 'Complete androgen insensitivity syndrome', 'Chronic conditions'),
  ('E34.52', 'Chronic metabolic diseases', 'high', 'Partial androgen insensitivity syndrome', 'Chronic conditions'),
  ('E34.8', 'Chronic metabolic diseases', 'high', 'Other specified endocrine disorders', 'Chronic conditions'),
  ('E34.9', 'Chronic metabolic diseases', 'high', 'Endocrine disorder, unspecified', 'Chronic conditions'),
  ('E35', 'Chronic metabolic diseases', 'high', 'Disorders of endocrine glands in diseases classified elsewhere', 'Chronic conditions'),
  ('E40', 'Chronic metabolic diseases', 'high', 'Kwashiorkor requires nutritional management', 'Chronic conditions'),
  ('E41', 'Chronic metabolic diseases', 'high', 'Nutritional marasmus needs ongoing care', 'Chronic conditions'),
  ('E42', 'Chronic metabolic diseases', 'high', 'Marasmic kwashiorkor requires monitoring', 'Chronic conditions'),
  ('E43', 'Chronic metabolic diseases', 'high', 'Unspecified severe protein-calorie malnutrition', 'Chronic conditions'),
  ('E44.0', 'Chronic metabolic diseases', 'high', 'Moderate protein-calorie malnutrition', 'Chronic conditions'),
  ('E44.1', 'Chronic metabolic diseases', 'high', 'Mild protein-calorie malnutrition', 'Chronic conditions'),
  ('E45', 'Chronic metabolic diseases', 'high', 'Retarded development following protein-calorie malnutrition', 'Chronic conditions'),
  ('E46', 'Chronic metabolic diseases', 'high', 'Unspecified protein-calorie malnutrition', 'Chronic conditions'),
  ('E50.0', 'Chronic metabolic diseases', 'high', 'Vitamin A deficiency with conjunctival xerosis', 'Chronic conditions'),
  ('E50.1', 'Chronic metabolic diseases', 'high', 'Vitamin A deficiency with Bitots spot and conjunctival xerosis', 'Chronic conditions'),

  -- Chronic respiratory diseases (30 codes)
  ('J95.0', 'Chronic respiratory diseases', 'high', 'Tracheostomy malfunction requires regular care', 'Chronic conditions'),
  ('J95.1', 'Chronic respiratory diseases', 'high', 'Acute pulmonary insufficiency following thoracic surgery', 'Chronic conditions'),
  ('J95.2', 'Chronic respiratory diseases', 'high', 'Acute pulmonary insufficiency following nonthoracic surgery', 'Chronic conditions'),
  ('J95.3', 'Chronic respiratory diseases', 'high', 'Chronic pulmonary insufficiency following surgery', 'Chronic conditions'),
  ('J95.4', 'Chronic respiratory diseases', 'high', 'Chemical pneumonitis due to anesthesia', 'Chronic conditions'),
  ('J95.5', 'Chronic respiratory diseases', 'high', 'Postprocedural subglottic stenosis', 'Chronic conditions'),
  ('J95.60', 'Chronic respiratory diseases', 'high', 'Postprocedural respiratory failure, unspecified', 'Chronic conditions'),
  ('J95.61', 'Chronic respiratory diseases', 'high', 'Postprocedural acute respiratory failure', 'Chronic conditions'),
  ('J95.62', 'Chronic respiratory diseases', 'high', 'Postprocedural acute and chronic respiratory failure', 'Chronic conditions'),
  ('J95.71', 'Chronic respiratory diseases', 'high', 'Accidental puncture and laceration of respiratory organ during procedure', 'Chronic conditions'),
  ('J95.72', 'Chronic respiratory diseases', 'high', 'Postprocedural respiratory failure', 'Chronic conditions'),
  ('J95.811', 'Chronic respiratory diseases', 'high', 'Postprocedural pneumothorax', 'Chronic conditions'),
  ('J95.812', 'Chronic respiratory diseases', 'high', 'Postprocedural air leak', 'Chronic conditions'),
  ('J95.821', 'Chronic respiratory diseases', 'high', 'Acute postprocedural respiratory failure', 'Chronic conditions'),
  ('J95.822', 'Chronic respiratory diseases', 'high', 'Acute and chronic postprocedural respiratory failure', 'Chronic conditions'),
  ('J95.83', 'Chronic respiratory diseases', 'high', 'Postprocedural hemorrhage of respiratory system', 'Chronic conditions'),
  ('J95.84', 'Chronic respiratory diseases', 'high', 'Transfusion-related acute lung injury (TRALI)', 'Chronic conditions'),
  ('J95.851', 'Chronic respiratory diseases', 'high', 'Ventilator associated pneumonia', 'Chronic conditions'),
  ('J95.859', 'Chronic respiratory diseases', 'high', 'Other postprocedural complications of respiratory system', 'Chronic conditions'),
  ('J95.89', 'Chronic respiratory diseases', 'high', 'Other postprocedural complications and disorders of respiratory system', 'Chronic conditions'),
  ('J95.9', 'Chronic respiratory diseases', 'high', 'Postprocedural respiratory complication, unspecified', 'Chronic conditions'),
  ('J96.00', 'Chronic respiratory diseases', 'high', 'Acute respiratory failure, unspecified with hypoxia or hypercapnia', 'Chronic conditions'),
  ('J96.01', 'Chronic respiratory diseases', 'high', 'Acute respiratory failure with hypoxia', 'Chronic conditions'),
  ('J96.02', 'Chronic respiratory diseases', 'high', 'Acute respiratory failure with hypercapnia', 'Chronic conditions'),
  ('J96.10', 'Chronic respiratory diseases', 'high', 'Chronic respiratory failure, unspecified with hypoxia or hypercapnia', 'Chronic conditions'),
  ('J96.11', 'Chronic respiratory diseases', 'high', 'Chronic respiratory failure with hypoxia', 'Chronic conditions'),
  ('J96.12', 'Chronic respiratory diseases', 'high', 'Chronic respiratory failure with hypercapnia', 'Chronic conditions'),
  ('J96.20', 'Chronic respiratory diseases', 'high', 'Acute and chronic respiratory failure, unspecified with hypoxia or hypercapnia', 'Chronic conditions'),
  ('J96.21', 'Chronic respiratory diseases', 'high', 'Acute and chronic respiratory failure with hypoxia', 'Chronic conditions'),
  ('J96.22', 'Chronic respiratory diseases', 'high', 'Acute and chronic respiratory failure with hypercapnia', 'Chronic conditions'),

  -- Complex condition / Frail elderly (30 codes)
  ('R75', 'Complex condition / Frail elderly', 'high', 'Inconclusive laboratory evidence of HIV', 'Complex, multi-morbid'),
  ('R76.0', 'Complex condition / Frail elderly', 'high', 'Raised antibody titer', 'Complex, multi-morbid'),
  ('R76.11', 'Complex condition / Frail elderly', 'high', 'Nonspecific reaction to tuberculin skin test without active tuberculosis', 'Complex, multi-morbid'),
  ('R76.12', 'Complex condition / Frail elderly', 'high', 'False positive tuberculin skin test', 'Complex, multi-morbid'),
  ('R76.8', 'Complex condition / Frail elderly', 'high', 'Other specified abnormal immunological findings in serum', 'Complex, multi-morbid'),
  ('R76.9', 'Complex condition / Frail elderly', 'high', 'Abnormal immunological finding in serum, unspecified', 'Complex, multi-morbid'),
  ('R77.0', 'Complex condition / Frail elderly', 'high', 'Abnormality of albumin', 'Complex, multi-morbid'),
  ('R77.1', 'Complex condition / Frail elderly', 'high', 'Abnormality of globulin', 'Complex, multi-morbid'),
  ('R77.2', 'Complex condition / Frail elderly', 'high', 'Abnormality of alphafetoprotein', 'Complex, multi-morbid'),
  ('R77.8', 'Complex condition / Frail elderly', 'high', 'Other specified abnormalities of plasma proteins', 'Complex, multi-morbid'),
  ('R77.9', 'Complex condition / Frail elderly', 'high', 'Abnormality of plasma protein, unspecified', 'Complex, multi-morbid'),
  ('R78.0', 'Complex condition / Frail elderly', 'high', 'Finding of alcohol in blood', 'Complex, multi-morbid'),
  ('R78.1', 'Complex condition / Frail elderly', 'high', 'Finding of opiate drug in blood', 'Complex, multi-morbid'),
  ('R78.2', 'Complex condition / Frail elderly', 'high', 'Finding of cocaine in blood', 'Complex, multi-morbid'),
  ('R78.3', 'Complex condition / Frail elderly', 'high', 'Finding of hallucinogen in blood', 'Complex, multi-morbid'),
  ('R78.4', 'Complex condition / Frail elderly', 'high', 'Finding of other drugs of addictive potential in blood', 'Complex, multi-morbid'),
  ('R78.5', 'Complex condition / Frail elderly', 'high', 'Finding of psychotropic drug in blood', 'Complex, multi-morbid'),
  ('R78.6', 'Complex condition / Frail elderly', 'high', 'Finding of steroid agent in blood', 'Complex, multi-morbid'),
  ('R78.71', 'Complex condition / Frail elderly', 'high', 'Abnormal lead level in blood', 'Complex, multi-morbid'),
  ('R78.79', 'Complex condition / Frail elderly', 'high', 'Finding of abnormal level of heavy metals in blood', 'Complex, multi-morbid'),
  ('R78.81', 'Complex condition / Frail elderly', 'high', 'Bacteremia', 'Complex, multi-morbid'),
  ('R78.89', 'Complex condition / Frail elderly', 'high', 'Finding of other specified substances, not normally found in blood', 'Complex, multi-morbid'),
  ('R78.9', 'Complex condition / Frail elderly', 'high', 'Finding of unspecified substance, not normally found in blood', 'Complex, multi-morbid'),
  ('R79.0', 'Complex condition / Frail elderly', 'high', 'Abnormal level of blood mineral', 'Complex, multi-morbid'),
  ('R79.1', 'Complex condition / Frail elderly', 'high', 'Abnormal coagulation profile', 'Complex, multi-morbid'),
  ('R79.81', 'Complex condition / Frail elderly', 'high', 'Abnormal blood-gas level', 'Complex, multi-morbid'),
  ('R79.82', 'Complex condition / Frail elderly', 'high', 'Elevated C-reactive protein (CRP)', 'Complex, multi-morbid'),
  ('R79.83', 'Complex condition / Frail elderly', 'high', 'Abnormal findings of blood amino-acid level', 'Complex, multi-morbid'),
  ('R79.89', 'Complex condition / Frail elderly', 'high', 'Other specified abnormal findings of blood chemistry', 'Complex, multi-morbid'),
  ('R79.9', 'Complex condition / Frail elderly', 'high', 'Abnormal finding of blood chemistry, unspecified', 'Complex, multi-morbid'),

  -- Allied Health & Health Promotion (30 codes)
  ('Z83.0', 'Allied Health & Health Promotion', 'high', 'Family history of HIV disease', 'Planned care'),
  ('Z83.1', 'Allied Health & Health Promotion', 'high', 'Family history of other infectious and parasitic diseases', 'Planned care'),
  ('Z83.2', 'Allied Health & Health Promotion', 'high', 'Family history of diseases of the blood and blood-forming organs', 'Planned care'),
  ('Z83.3', 'Allied Health & Health Promotion', 'high', 'Family history of diabetes mellitus', 'Planned care'),
  ('Z83.41', 'Allied Health & Health Promotion', 'high', 'Family history of multiple endocrine neoplasia syndrome', 'Planned care'),
  ('Z83.42', 'Allied Health & Health Promotion', 'high', 'Family history of carrier of genetic disease', 'Planned care'),
  ('Z83.430', 'Allied Health & Health Promotion', 'high', 'Family history of elevated lipoprotein(a)', 'Planned care'),
  ('Z83.438', 'Allied Health & Health Promotion', 'high', 'Family history of other disorder of lipoprotein metabolism', 'Planned care'),
  ('Z83.49', 'Allied Health & Health Promotion', 'high', 'Family history of other endocrine, nutritional and metabolic diseases', 'Planned care'),
  ('Z83.5', 'Allied Health & Health Promotion', 'high', 'Family history of eye and ear disorders', 'Planned care'),
  ('Z83.6', 'Allied Health & Health Promotion', 'high', 'Family history of diseases of the respiratory system', 'Planned care'),
  ('Z83.71', 'Allied Health & Health Promotion', 'high', 'Family history of colonic polyps', 'Planned care'),
  ('Z83.79', 'Allied Health & Health Promotion', 'high', 'Family history of other diseases of the digestive system', 'Planned care'),
  ('Z84.0', 'Allied Health & Health Promotion', 'high', 'Family history of diseases of the skin and subcutaneous tissue', 'Planned care'),
  ('Z84.1', 'Allied Health & Health Promotion', 'high', 'Family history of disorders of kidney and ureter', 'Planned care'),
  ('Z84.2', 'Allied Health & Health Promotion', 'high', 'Family history of other diseases of the genitourinary system', 'Planned care'),
  ('Z84.3', 'Allied Health & Health Promotion', 'high', 'Family history of consanguinity', 'Planned care'),
  ('Z84.81', 'Allied Health & Health Promotion', 'high', 'Family history of carrier of genetic disease', 'Planned care'),
  ('Z84.82', 'Allied Health & Health Promotion', 'high', 'Family history of sudden infant death syndrome', 'Planned care'),
  ('Z84.89', 'Allied Health & Health Promotion', 'high', 'Family history of other specified conditions', 'Planned care'),
  ('Z85.00', 'Allied Health & Health Promotion', 'high', 'Personal history of malignant neoplasm of unspecified digestive organ', 'Planned care'),
  ('Z85.01', 'Allied Health & Health Promotion', 'high', 'Personal history of malignant neoplasm of esophagus', 'Planned care'),
  ('Z85.028', 'Allied Health & Health Promotion', 'high', 'Personal history of other malignant neoplasm of stomach', 'Planned care'),
  ('Z85.038', 'Allied Health & Health Promotion', 'high', 'Personal history of other malignant neoplasm of large intestine', 'Planned care'),
  ('Z85.048', 'Allied Health & Health Promotion', 'high', 'Personal history of other malignant neoplasm of rectum, rectosigmoid junction, and anus', 'Planned care'),
  ('Z85.05', 'Allied Health & Health Promotion', 'high', 'Personal history of malignant neoplasm of liver', 'Planned care'),
  ('Z85.068', 'Allied Health & Health Promotion', 'high', 'Personal history of other malignant neoplasm of small intestine', 'Planned care'),
  ('Z85.07', 'Allied Health & Health Promotion', 'high', 'Personal history of malignant neoplasm of pancreas', 'Planned care'),
  ('Z85.09', 'Allied Health & Health Promotion', 'high', 'Personal history of malignant neoplasm of other digestive organs', 'Planned care'),
  ('Z85.110', 'Allied Health & Health Promotion', 'high', 'Personal history of malignant carcinoid tumor of bronchus and lung', 'Planned care'),

  -- Primary dental care (30 codes)
  ('K05.30', 'Primary dental care', 'high', 'Chronic periodontitis, unspecified', 'Planned care'),
  ('K05.311', 'Primary dental care', 'high', 'Chronic periodontitis, localized, slight', 'Planned care'),
  ('K05.312', 'Primary dental care', 'high', 'Chronic periodontitis, localized, moderate', 'Planned care'),
  ('K05.313', 'Primary dental care', 'high', 'Chronic periodontitis, localized, severe', 'Planned care'),
  ('K05.319', 'Primary dental care', 'high', 'Chronic periodontitis, localized, unspecified severity', 'Planned care'),
  ('K05.321', 'Primary dental care', 'high', 'Chronic periodontitis, generalized, slight', 'Planned care'),
  ('K05.322', 'Primary dental care', 'high', 'Chronic periodontitis, generalized, moderate', 'Planned care'),
  ('K05.323', 'Primary dental care', 'high', 'Chronic periodontitis, generalized, severe', 'Planned care'),
  ('K05.329', 'Primary dental care', 'high', 'Chronic periodontitis, generalized, unspecified severity', 'Planned care'),
  ('K05.4', 'Primary dental care', 'high', 'Periodontosis', 'Planned care'),
  ('K05.5', 'Primary dental care', 'high', 'Other periodontal diseases', 'Planned care'),
  ('K05.6', 'Primary dental care', 'high', 'Periodontal disease, unspecified', 'Planned care'),
  ('K06.0', 'Primary dental care', 'high', 'Gingival recession', 'Planned care'),
  ('K06.1', 'Primary dental care', 'high', 'Gingival enlargement', 'Planned care'),
  ('K06.2', 'Primary dental care', 'high', 'Gingival and edentulous alveolar ridge lesions associated with trauma', 'Planned care'),
  ('K06.3', 'Primary dental care', 'high', 'Horizontal alveolar bone loss', 'Planned care'),
  ('K06.8', 'Primary dental care', 'high', 'Other specified disorders of gingiva and edentulous alveolar ridge', 'Planned care'),
  ('K06.9', 'Primary dental care', 'high', 'Disorder of gingiva and edentulous alveolar ridge, unspecified', 'Planned care'),
  ('K08.0', 'Primary dental care', 'high', 'Exfoliation of teeth due to systemic causes', 'Planned care'),
  ('K08.101', 'Primary dental care', 'high', 'Complete loss of teeth, unspecified cause, class I', 'Planned care'),
  ('K08.102', 'Primary dental care', 'high', 'Complete loss of teeth, unspecified cause, class II', 'Planned care'),
  ('K08.103', 'Primary dental care', 'high', 'Complete loss of teeth, unspecified cause, class III', 'Planned care'),
  ('K08.104', 'Primary dental care', 'high', 'Complete loss of teeth, unspecified cause, class IV', 'Planned care'),
  ('K08.109', 'Primary dental care', 'high', 'Complete loss of teeth, unspecified cause, unspecified class', 'Planned care'),
  ('K08.111', 'Primary dental care', 'high', 'Complete loss of teeth due to trauma, class I', 'Planned care'),
  ('K08.112', 'Primary dental care', 'high', 'Complete loss of teeth due to trauma, class II', 'Planned care'),
  ('K08.113', 'Primary dental care', 'high', 'Complete loss of teeth due to trauma, class III', 'Planned care'),
  ('K08.114', 'Primary dental care', 'high', 'Complete loss of teeth due to trauma, class IV', 'Planned care'),
  ('K08.119', 'Primary dental care', 'high', 'Complete loss of teeth due to trauma, unspecified class', 'Planned care'),
  ('K08.121', 'Primary dental care', 'high', 'Complete loss of teeth due to periodontal diseases, class I', 'Planned care');

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