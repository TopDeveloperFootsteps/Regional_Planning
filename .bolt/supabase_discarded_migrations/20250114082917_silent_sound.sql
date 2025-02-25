/*
  # Add 100 ICD code mappings for home services

  1. New Mappings
    - Add 100 new ICD code mappings across different service types
    - Ensure coverage across all systems of care
    - Include mix of high, medium, and low confidence mappings
    - Focus on common conditions suitable for home care
*/

INSERT INTO home_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Chronic metabolic diseases (Chronic conditions)
  ('E10.9', 'Chronic metabolic diseases', 'high', 'Type 1 diabetes without complications requires regular monitoring', 'Chronic conditions'),
  ('E66.9', 'Chronic metabolic diseases', 'high', 'Obesity requires ongoing management and lifestyle modifications', 'Chronic conditions'),
  ('E03.9', 'Chronic metabolic diseases', 'high', 'Hypothyroidism requires regular medication management', 'Chronic conditions'),
  ('E05.90', 'Chronic metabolic diseases', 'high', 'Hyperthyroidism requires ongoing monitoring', 'Chronic conditions'),
  ('E14.9', 'Chronic metabolic diseases', 'high', 'Unspecified diabetes mellitus requires regular monitoring', 'Chronic conditions'),
  ('E78.0', 'Chronic metabolic diseases', 'high', 'Pure hypercholesterolemia requires regular monitoring', 'Chronic conditions'),
  ('E79.0', 'Chronic metabolic diseases', 'medium', 'Hyperuricemia requires periodic monitoring', 'Chronic conditions'),
  ('E21.3', 'Chronic metabolic diseases', 'medium', 'Hyperparathyroidism requires regular monitoring', 'Chronic conditions'),
  ('E83.51', 'Chronic metabolic diseases', 'medium', 'Hypocalcemia requires regular monitoring', 'Chronic conditions'),
  ('E87.6', 'Chronic metabolic diseases', 'medium', 'Hypokalemia requires monitoring and management', 'Chronic conditions'),

  -- Chronic respiratory diseases (Chronic conditions)
  ('J45.909', 'Chronic respiratory diseases', 'high', 'Unspecified asthma requires regular monitoring', 'Chronic conditions'),
  ('J41.0', 'Chronic respiratory diseases', 'high', 'Simple chronic bronchitis requires ongoing care', 'Chronic conditions'),
  ('J30.9', 'Chronic respiratory diseases', 'medium', 'Allergic rhinitis requires regular management', 'Chronic conditions'),
  ('J31.0', 'Chronic respiratory diseases', 'medium', 'Chronic rhinitis requires ongoing care', 'Chronic conditions'),
  ('J37.0', 'Chronic respiratory diseases', 'medium', 'Chronic laryngitis requires regular monitoring', 'Chronic conditions'),
  ('J42', 'Chronic respiratory diseases', 'high', 'Unspecified chronic bronchitis requires management', 'Chronic conditions'),
  ('J43.9', 'Chronic respiratory diseases', 'high', 'Emphysema requires ongoing monitoring', 'Chronic conditions'),
  ('J47.9', 'Chronic respiratory diseases', 'high', 'Bronchiectasis requires regular care', 'Chronic conditions'),
  ('J45.20', 'Chronic respiratory diseases', 'high', 'Mild intermittent asthma requires monitoring', 'Chronic conditions'),
  ('J45.30', 'Chronic respiratory diseases', 'high', 'Mild persistent asthma requires regular care', 'Chronic conditions'),

  -- Chronic mental health disorders (Complex, multi-morbid)
  ('F41.1', 'Chronic mental health disorders', 'high', 'Generalized anxiety disorder requires ongoing support', 'Complex, multi-morbid'),
  ('F33.0', 'Chronic mental health disorders', 'high', 'Recurrent depressive disorder requires regular monitoring', 'Complex, multi-morbid'),
  ('F41.9', 'Chronic mental health disorders', 'medium', 'Anxiety disorder requires ongoing support', 'Complex, multi-morbid'),
  ('F43.23', 'Chronic mental health disorders', 'medium', 'Adjustment disorder requires regular monitoring', 'Complex, multi-morbid'),
  ('F51.01', 'Chronic mental health disorders', 'medium', 'Primary insomnia requires ongoing management', 'Complex, multi-morbid'),
  ('F31.9', 'Chronic mental health disorders', 'high', 'Bipolar disorder requires regular monitoring', 'Complex, multi-morbid'),
  ('F34.1', 'Chronic mental health disorders', 'high', 'Dysthymic disorder requires ongoing support', 'Complex, multi-morbid'),
  ('F42.2', 'Chronic mental health disorders', 'high', 'Mixed OCD requires regular monitoring', 'Complex, multi-morbid'),
  ('F43.10', 'Chronic mental health disorders', 'medium', 'PTSD requires ongoing support', 'Complex, multi-morbid'),
  ('F48.9', 'Chronic mental health disorders', 'medium', 'Nonpsychotic mental disorder requires monitoring', 'Complex, multi-morbid'),

  -- Allied Health & Health Promotion (Planned care)
  ('Z71.3', 'Allied Health & Health Promotion', 'high', 'Dietary counseling and surveillance', 'Planned care'),
  ('Z71.89', 'Allied Health & Health Promotion', 'high', 'Other specified counseling', 'Planned care'),
  ('Z71.82', 'Allied Health & Health Promotion', 'high', 'Exercise counseling', 'Planned care'),
  ('Z71.9', 'Allied Health & Health Promotion', 'medium', 'Counseling, unspecified', 'Planned care'),
  ('Z72.4', 'Allied Health & Health Promotion', 'medium', 'Inappropriate diet and eating habits', 'Planned care'),
  ('Z72.3', 'Allied Health & Health Promotion', 'medium', 'Lack of physical exercise', 'Planned care'),
  ('Z73.6', 'Allied Health & Health Promotion', 'medium', 'Limitation of activities due to disability', 'Planned care'),
  ('Z71.41', 'Allied Health & Health Promotion', 'high', 'Alcohol abuse counseling and surveillance', 'Planned care'),
  ('Z71.42', 'Allied Health & Health Promotion', 'high', 'Counseling for family member of alcoholic', 'Planned care'),
  ('Z71.51', 'Allied Health & Health Promotion', 'high', 'Drug abuse counseling and surveillance', 'Planned care'),

  -- Complex condition / Frail elderly (Complex, multi-morbid)
  ('R26.81', 'Complex condition / Frail elderly', 'high', 'Unsteadiness on feet requires regular monitoring', 'Complex, multi-morbid'),
  ('R26.2', 'Complex condition / Frail elderly', 'high', 'Difficulty in walking requires ongoing support', 'Complex, multi-morbid'),
  ('R26.89', 'Complex condition / Frail elderly', 'high', 'Other abnormalities of gait and mobility', 'Complex, multi-morbid'),
  ('R41.81', 'Complex condition / Frail elderly', 'high', 'Age-related cognitive decline', 'Complex, multi-morbid'),
  ('R53.1', 'Complex condition / Frail elderly', 'high', 'Weakness', 'Complex, multi-morbid'),
  ('R54', 'Complex condition / Frail elderly', 'high', 'Age-related physical debility', 'Complex, multi-morbid'),
  ('R41.3', 'Complex condition / Frail elderly', 'high', 'Other amnesia', 'Complex, multi-morbid'),
  ('R45.81', 'Complex condition / Frail elderly', 'medium', 'Low self-esteem', 'Complex, multi-morbid'),
  ('R45.0', 'Complex condition / Frail elderly', 'medium', 'Nervousness', 'Complex, multi-morbid'),
  ('R45.3', 'Complex condition / Frail elderly', 'medium', 'Demoralization and apathy', 'Complex, multi-morbid'),

  -- Acute & urgent care (Unplanned care)
  ('A09.9', 'Acute & urgent care', 'high', 'Infectious gastroenteritis and colitis', 'Unplanned care'),
  ('B34.9', 'Acute & urgent care', 'high', 'Viral infection, unspecified', 'Unplanned care'),
  ('J00', 'Acute & urgent care', 'high', 'Acute nasopharyngitis [common cold]', 'Unplanned care'),
  ('J02.9', 'Acute & urgent care', 'high', 'Acute pharyngitis, unspecified', 'Unplanned care'),
  ('J03.90', 'Acute & urgent care', 'high', 'Acute tonsillitis, unspecified', 'Unplanned care'),
  ('L01.00', 'Acute & urgent care', 'medium', 'Impetigo, unspecified', 'Unplanned care'),
  ('L02.91', 'Acute & urgent care', 'medium', 'Cutaneous abscess, unspecified', 'Unplanned care'),
  ('M25.50', 'Acute & urgent care', 'medium', 'Pain in unspecified joint', 'Unplanned care'),
  ('R05', 'Acute & urgent care', 'high', 'Cough', 'Unplanned care'),
  ('R11.2', 'Acute & urgent care', 'high', 'Nausea with vomiting, unspecified', 'Unplanned care'),

  -- Well baby care (Children and young people)
  ('Z00.121', 'Well baby care (0 to 4)', 'high', 'Encounter for routine child health exam with abnormal findings', 'Children and young people'),
  ('Z00.129', 'Well baby care (0 to 4)', 'high', 'Encounter for routine child health exam without abnormal findings', 'Children and young people'),
  ('Z00.110', 'Well baby care (0 to 4)', 'high', 'Health supervision for newborn under 8 days old', 'Children and young people'),
  ('Z00.111', 'Well baby care (0 to 4)', 'high', 'Health supervision for newborn 8 to 28 days old', 'Children and young people'),
  ('Z76.2', 'Well baby care (0 to 4)', 'high', 'Encounter for health supervision and care of other healthy infant and child', 'Children and young people'),

  -- Paediatric care (Children and young people)
  ('Z00.129', 'Paediatric care (5 to 16)', 'high', 'Encounter for routine child health examination', 'Children and young people'),
  ('Z71.89', 'Paediatric care (5 to 16)', 'high', 'Other specified counseling for children', 'Children and young people'),
  ('Z71.3', 'Paediatric care (5 to 16)', 'high', 'Dietary counseling and surveillance for children', 'Children and young people'),
  ('Z71.82', 'Paediatric care (5 to 16)', 'high', 'Exercise counseling for children', 'Children and young people'),
  ('Z00.121', 'Paediatric care (5 to 16)', 'high', 'Encounter for routine child health exam with abnormal findings', 'Children and young people'),

  -- Maternal Care (Planned care)
  ('Z34.00', 'Maternal Care', 'high', 'Supervision of normal first pregnancy', 'Planned care'),
  ('Z34.80', 'Maternal Care', 'high', 'Supervision of other normal pregnancy', 'Planned care'),
  ('Z34.90', 'Maternal Care', 'high', 'Supervision of normal pregnancy, unspecified', 'Planned care'),
  ('Z39.1', 'Maternal Care', 'high', 'Encounter for care and examination of lactating mother', 'Planned care'),
  ('Z39.2', 'Maternal Care', 'high', 'Encounter for routine postpartum follow-up', 'Planned care'),

  -- Primary dental care (Planned care)
  ('K02.9', 'Primary dental care', 'high', 'Dental caries, unspecified', 'Planned care'),
  ('K03.9', 'Primary dental care', 'high', 'Disease of hard tissues of teeth, unspecified', 'Planned care'),
  ('K05.0', 'Primary dental care', 'high', 'Acute gingivitis', 'Planned care'),
  ('K08.9', 'Primary dental care', 'high', 'Disorder of teeth and supporting structures, unspecified', 'Planned care'),
  ('Z01.20', 'Primary dental care', 'high', 'Encounter for dental examination and cleaning without abnormal findings', 'Planned care'),

  -- Routine health checks (Wellness and longevity)
  ('Z00.00', 'Routine health checks', 'high', 'Encounter for general adult medical examination without abnormal findings', 'Wellness and longevity'),
  ('Z00.01', 'Routine health checks', 'high', 'Encounter for general adult medical examination with abnormal findings', 'Wellness and longevity'),
  ('Z01.30', 'Routine health checks', 'high', 'Encounter for examination of blood pressure without abnormal findings', 'Wellness and longevity'),
  ('Z01.31', 'Routine health checks', 'high', 'Encounter for examination of blood pressure with abnormal findings', 'Wellness and longevity'),
  ('Z13.1', 'Routine health checks', 'high', 'Encounter for screening for diabetes mellitus', 'Wellness and longevity'),

  -- Other chronic diseases (Chronic conditions)
  ('K21.9', 'Other chronic diseases', 'high', 'Gastro-esophageal reflux disease without esophagitis', 'Chronic conditions'),
  ('K58.9', 'Other chronic diseases', 'high', 'Irritable bowel syndrome without diarrhea', 'Chronic conditions'),
  ('K59.00', 'Other chronic diseases', 'medium', 'Constipation, unspecified', 'Chronic conditions'),
  ('L40.0', 'Other chronic diseases', 'high', 'Psoriasis vulgaris', 'Chronic conditions'),
  ('M15.0', 'Other chronic diseases', 'high', 'Primary generalized osteoarthrosis', 'Chronic conditions');

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