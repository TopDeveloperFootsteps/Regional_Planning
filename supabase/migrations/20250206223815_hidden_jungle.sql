-- Insert visit rates for all services
INSERT INTO visit_rates 
(service, age_group, assumption_type, male_rate, female_rate)
VALUES
  -- Routine health checks
  ('Routine health checks', '0 to 4', 'model', 0, 0),
  ('Routine health checks', '5 to 19', 'model', 0, 0),
  ('Routine health checks', '20 to 29', 'model', 0, 0),
  ('Routine health checks', '30 to 44', 'model', 37.0, 37.0),
  ('Routine health checks', '45 to 64', 'model', 111.0, 111.0),
  ('Routine health checks', '65 to 125', 'model', 111.0, 111.0),

  ('Routine health checks', '0 to 4', 'enhanced', 100, 110),
  ('Routine health checks', '5 to 19', 'enhanced', 120, 130),
  ('Routine health checks', '20 to 29', 'enhanced', 150, 160),
  ('Routine health checks', '30 to 44', 'enhanced', 200, 220),
  ('Routine health checks', '45 to 64', 'enhanced', 250, 270),
  ('Routine health checks', '65 to 125', 'enhanced', 300, 320),

  ('Routine health checks', '0 to 4', 'high_risk', 150, 165),
  ('Routine health checks', '5 to 19', 'high_risk', 180, 195),
  ('Routine health checks', '20 to 29', 'high_risk', 225, 240),
  ('Routine health checks', '30 to 44', 'high_risk', 300, 330),
  ('Routine health checks', '45 to 64', 'high_risk', 375, 405),
  ('Routine health checks', '65 to 125', 'high_risk', 450, 480),

  -- Acute & urgent care
  ('Acute & urgent care', '0 to 4', 'model', 124.5, 104.9),
  ('Acute & urgent care', '5 to 19', 'model', 166.4, 197.0),
  ('Acute & urgent care', '20 to 29', 'model', 551.9, 1073.8),
  ('Acute & urgent care', '30 to 44', 'model', 974.9, 1569.5),
  ('Acute & urgent care', '45 to 64', 'model', 1946.9, 1927.1),
  ('Acute & urgent care', '65 to 125', 'model', 4369.3, 3550.7),

  ('Acute & urgent care', '0 to 4', 'enhanced', 400, 420),
  ('Acute & urgent care', '5 to 19', 'enhanced', 350, 370),
  ('Acute & urgent care', '20 to 29', 'enhanced', 300, 310),
  ('Acute & urgent care', '30 to 44', 'enhanced', 320, 330),
  ('Acute & urgent care', '45 to 64', 'enhanced', 360, 380),
  ('Acute & urgent care', '65 to 125', 'enhanced', 400, 420),

  ('Acute & urgent care', '0 to 4', 'high_risk', 600, 630),
  ('Acute & urgent care', '5 to 19', 'high_risk', 525, 555),
  ('Acute & urgent care', '20 to 29', 'high_risk', 450, 465),
  ('Acute & urgent care', '30 to 44', 'high_risk', 480, 495),
  ('Acute & urgent care', '45 to 64', 'high_risk', 540, 570),
  ('Acute & urgent care', '65 to 125', 'high_risk', 600, 630),

  -- Chronic metabolic diseases
  ('Chronic metabolic diseases', '0 to 4', 'model', 76.9, 75.9),
  ('Chronic metabolic diseases', '5 to 19', 'model', 120.2, 148.9),
  ('Chronic metabolic diseases', '20 to 29', 'model', 215.3, 556.8),
  ('Chronic metabolic diseases', '30 to 44', 'model', 331.8, 822.2),
  ('Chronic metabolic diseases', '45 to 64', 'model', 588.0, 657.5),
  ('Chronic metabolic diseases', '65 to 125', 'model', 819.7, 759.3),

  ('Chronic metabolic diseases', '0 to 4', 'enhanced', 20, 20),
  ('Chronic metabolic diseases', '5 to 19', 'enhanced', 30, 30),
  ('Chronic metabolic diseases', '20 to 29', 'enhanced', 100, 110),
  ('Chronic metabolic diseases', '30 to 44', 'enhanced', 200, 210),
  ('Chronic metabolic diseases', '45 to 64', 'enhanced', 400, 420),
  ('Chronic metabolic diseases', '65 to 125', 'enhanced', 500, 520),

  ('Chronic metabolic diseases', '0 to 4', 'high_risk', 30, 30),
  ('Chronic metabolic diseases', '5 to 19', 'high_risk', 45, 45),
  ('Chronic metabolic diseases', '20 to 29', 'high_risk', 150, 165),
  ('Chronic metabolic diseases', '30 to 44', 'high_risk', 300, 315),
  ('Chronic metabolic diseases', '45 to 64', 'high_risk', 600, 630),
  ('Chronic metabolic diseases', '65 to 125', 'high_risk', 750, 780),

  -- Chronic respiratory diseases
  ('Chronic respiratory diseases', '0 to 4', 'model', 25.2, 20.6),
  ('Chronic respiratory diseases', '5 to 19', 'model', 25.9, 25.4),
  ('Chronic respiratory diseases', '20 to 29', 'model', 61.1, 85.2),
  ('Chronic respiratory diseases', '30 to 44', 'model', 129.2, 133.9),
  ('Chronic respiratory diseases', '45 to 64', 'model', 276.4, 264.1),
  ('Chronic respiratory diseases', '65 to 125', 'model', 556.4, 407.7),

  ('Chronic respiratory diseases', '0 to 4', 'enhanced', 50, 60),
  ('Chronic respiratory diseases', '5 to 19', 'enhanced', 60, 70),
  ('Chronic respiratory diseases', '20 to 29', 'enhanced', 100, 110),
  ('Chronic respiratory diseases', '30 to 44', 'enhanced', 150, 160),
  ('Chronic respiratory diseases', '45 to 64', 'enhanced', 200, 210),
  ('Chronic respiratory diseases', '65 to 125', 'enhanced', 300, 310),

  ('Chronic respiratory diseases', '0 to 4', 'high_risk', 75, 90),
  ('Chronic respiratory diseases', '5 to 19', 'high_risk', 90, 105),
  ('Chronic respiratory diseases', '20 to 29', 'high_risk', 150, 165),
  ('Chronic respiratory diseases', '30 to 44', 'high_risk', 225, 240),
  ('Chronic respiratory diseases', '45 to 64', 'high_risk', 300, 315),
  ('Chronic respiratory diseases', '65 to 125', 'high_risk', 450, 465),

  -- Chronic mental health disorders
  ('Chronic mental health disorders', '0 to 4', 'model', 18.4, 13.7),
  ('Chronic mental health disorders', '5 to 19', 'model', 521.4, 851.9),
  ('Chronic mental health disorders', '20 to 29', 'model', 593.6, 836.8),
  ('Chronic mental health disorders', '30 to 44', 'model', 524.6, 596.4),
  ('Chronic mental health disorders', '45 to 64', 'model', 533.5, 617.9),
  ('Chronic mental health disorders', '65 to 125', 'model', 542.4, 639.3),

  ('Chronic mental health disorders', '0 to 4', 'enhanced', 10, 10),
  ('Chronic mental health disorders', '5 to 19', 'enhanced', 50, 70),
  ('Chronic mental health disorders', '20 to 29', 'enhanced', 120, 150),
  ('Chronic mental health disorders', '30 to 44', 'enhanced', 200, 250),
  ('Chronic mental health disorders', '45 to 64', 'enhanced', 180, 220),
  ('Chronic mental health disorders', '65 to 125', 'enhanced', 100, 130),

  ('Chronic mental health disorders', '0 to 4', 'high_risk', 15, 15),
  ('Chronic mental health disorders', '5 to 19', 'high_risk', 75, 105),
  ('Chronic mental health disorders', '20 to 29', 'high_risk', 180, 225),
  ('Chronic mental health disorders', '30 to 44', 'high_risk', 300, 375),
  ('Chronic mental health disorders', '45 to 64', 'high_risk', 270, 330),
  ('Chronic mental health disorders', '65 to 125', 'high_risk', 150, 195),

  -- Other chronic diseases
  ('Other chronic diseases', '0 to 4', 'model', 7.1, 6.0),
  ('Other chronic diseases', '5 to 19', 'model', 9.5, 11.2),
  ('Other chronic diseases', '20 to 29', 'model', 31.4, 61.1),
  ('Other chronic diseases', '30 to 44', 'model', 55.5, 89.3),
  ('Other chronic diseases', '45 to 64', 'model', 110.8, 109.7),
  ('Other chronic diseases', '65 to 125', 'model', 248.7, 202.1),

  ('Other chronic diseases', '0 to 4', 'enhanced', 20, 20),
  ('Other chronic diseases', '5 to 19', 'enhanced', 40, 50),
  ('Other chronic diseases', '20 to 29', 'enhanced', 80, 90),
  ('Other chronic diseases', '30 to 44', 'enhanced', 150, 170),
  ('Other chronic diseases', '45 to 64', 'enhanced', 250, 270),
  ('Other chronic diseases', '65 to 125', 'enhanced', 350, 370),

  ('Other chronic diseases', '0 to 4', 'high_risk', 30, 30),
  ('Other chronic diseases', '5 to 19', 'high_risk', 60, 75),
  ('Other chronic diseases', '20 to 29', 'high_risk', 120, 135),
  ('Other chronic diseases', '30 to 44', 'high_risk', 225, 255),
  ('Other chronic diseases', '45 to 64', 'high_risk', 375, 405),
  ('Other chronic diseases', '65 to 125', 'high_risk', 525, 555),

  -- Complex condition / Frail elderly
  ('Complex condition / Frail elderly', '0 to 4', 'model', 0, 0),
  ('Complex condition / Frail elderly', '5 to 19', 'model', 0, 0),
  ('Complex condition / Frail elderly', '20 to 29', 'model', 0, 0),
  ('Complex condition / Frail elderly', '30 to 44', 'model', 0, 0),
  ('Complex condition / Frail elderly', '45 to 64', 'model', 0, 0),
  ('Complex condition / Frail elderly', '65 to 125', 'model', 471.0, 471.0),

  ('Complex condition / Frail elderly', '0 to 4', 'enhanced', 0, 0),
  ('Complex condition / Frail elderly', '5 to 19', 'enhanced', 0, 0),
  ('Complex condition / Frail elderly', '20 to 29', 'enhanced', 10, 10),
  ('Complex condition / Frail elderly', '30 to 44', 'enhanced', 30, 30),
  ('Complex condition / Frail elderly', '45 to 64', 'enhanced', 100, 110),
  ('Complex condition / Frail elderly', '65 to 125', 'enhanced', 400, 420),

  ('Complex condition / Frail elderly', '0 to 4', 'high_risk', 0, 0),
  ('Complex condition / Frail elderly', '5 to 19', 'high_risk', 0, 0),
  ('Complex condition / Frail elderly', '20 to 29', 'high_risk', 15, 15),
  ('Complex condition / Frail elderly', '30 to 44', 'high_risk', 45, 45),
  ('Complex condition / Frail elderly', '45 to 64', 'high_risk', 150, 165),
  ('Complex condition / Frail elderly', '65 to 125', 'high_risk', 600, 630),

  -- Maternal Care
  ('Maternal Care', '0 to 4', 'model', 0, 0),
  ('Maternal Care', '5 to 19', 'model', 0, 50.6),
  ('Maternal Care', '20 to 29', 'model', 0, 936.1),
  ('Maternal Care', '30 to 44', 'model', 0, 1010.2),
  ('Maternal Care', '45 to 64', 'model', 0, 43.7),
  ('Maternal Care', '65 to 125', 'model', 0, 0),

  ('Maternal Care', '0 to 4', 'enhanced', 0, 0),
  ('Maternal Care', '5 to 19', 'enhanced', 0, 20),
  ('Maternal Care', '20 to 29', 'enhanced', 0, 300),
  ('Maternal Care', '30 to 44', 'enhanced', 0, 250),
  ('Maternal Care', '45 to 64', 'enhanced', 0, 0),
  ('Maternal Care', '65 to 125', 'enhanced', 0, 0),

  ('Maternal Care', '0 to 4', 'high_risk', 0, 0),
  ('Maternal Care', '5 to 19', 'high_risk', 0, 30),
  ('Maternal Care', '20 to 29', 'high_risk', 0, 450),
  ('Maternal Care', '30 to 44', 'high_risk', 0, 375),
  ('Maternal Care', '45 to 64', 'high_risk', 0, 0),
  ('Maternal Care', '65 to 125', 'high_risk', 0, 0),

  -- Well baby care (0 to 4)
  ('Well baby care (0 to 4)', '0 to 4', 'model', 3150.0, 3150.0),
  ('Well baby care (0 to 4)', '5 to 19', 'model', 0, 0),
  ('Well baby care (0 to 4)', '20 to 29', 'model', 0, 0),
  ('Well baby care (0 to 4)', '30 to 44', 'model', 0, 0),
  ('Well baby care (0 to 4)', '45 to 64', 'model', 0, 0),
  ('Well baby care (0 to 4)', '65 to 125', 'model', 0, 0),

  ('Well baby care (0 to 4)', '0 to 4', 'enhanced', 350, 350),
  ('Well baby care (0 to 4)', '5 to 19', 'enhanced', 0, 0),
  ('Well baby care (0 to 4)', '20 to 29', 'enhanced', 0, 0),
  ('Well baby care (0 to 4)', '30 to 44', 'enhanced', 0, 0),
  ('Well baby care (0 to 4)', '45 to 64', 'enhanced', 0, 0),
  ('Well baby care (0 to 4)', '65 to 125', 'enhanced', 0, 0),

  ('Well baby care (0 to 4)', '0 to 4', 'high_risk', 525, 525),
  ('Well baby care (0 to 4)', '5 to 19', 'high_risk', 0, 0),
  ('Well baby care (0 to 4)', '20 to 29', 'high_risk', 0, 0),
  ('Well baby care (0 to 4)', '30 to 44', 'high_risk', 0, 0),
  ('Well baby care (0 to 4)', '45 to 64', 'high_risk', 0, 0),
  ('Well baby care (0 to 4)', '65 to 125', 'high_risk', 0, 0),

  -- Paediatric care (5 to 16)
  ('Paediatric care (5 to 16)', '0 to 4', 'model', 0, 0),
  ('Paediatric care (5 to 16)', '5 to 19', 'model', 720.0, 720.0),
  ('Paediatric care (5 to 16)', '20 to 29', 'model', 0, 0),
  ('Paediatric care (5 to 16)', '30 to 44', 'model', 0, 0),
  ('Paediatric care (5 to 16)', '45 to 64', 'model', 0, 0),
  ('Paediatric care (5 to 16)', '65 to 125', 'model', 0, 0),

  ('Paediatric care (5 to 16)', '0 to 4', 'enhanced', 0, 0),
  ('Paediatric care (5 to 16)', '5 to 19', 'enhanced', 300, 320),
  ('Paediatric care (5 to 16)', '20 to 29', 'enhanced', 0, 0),
  ('Paediatric care (5 to 16)', '30 to 44', 'enhanced', 0, 0),
  ('Paediatric care (5 to 16)', '45 to 64', 'enhanced', 0, 0),
  ('Paediatric care (5 to 16)', '65 to 125', 'enhanced', 0, 0),

  ('Paediatric care (5 to 16)', '0 to 4', 'high_risk', 0, 0),
  ('Paediatric care (5 to 16)', '5 to 19', 'high_risk', 450, 480),
  ('Paediatric care (5 to 16)', '20 to 29', 'high_risk', 0, 0),
  ('Paediatric care (5 to 16)', '30 to 44', 'high_risk', 0, 0),
  ('Paediatric care (5 to 16)', '45 to 64', 'high_risk', 0, 0),
  ('Paediatric care (5 to 16)', '65 to 125', 'high_risk', 0, 0),

  -- Allied Health & Health Promotion
  ('Allied Health & Health Promotion', '0 to 4', 'model', 76.9, 75.9),
  ('Allied Health & Health Promotion', '5 to 19', 'model', 120.2, 148.9),
  ('Allied Health & Health Promotion', '20 to 29', 'model', 215.3, 556.8),
  ('Allied Health & Health Promotion', '30 to 44', 'model', 331.8, 822.2),
  ('Allied Health & Health Promotion', '45 to 64', 'model', 588.0, 657.5),
  ('Allied Health & Health Promotion', '65 to 125', 'model', 819.7, 759.3),

  ('Allied Health & Health Promotion', '0 to 4', 'enhanced', 50, 60),
  ('Allied Health & Health Promotion', '5 to 19', 'enhanced', 80, 90),
  ('Allied Health & Health Promotion', '20 to 29', 'enhanced', 100, 110),
  ('Allied Health & Health Promotion', '30 to 44', 'enhanced', 120, 130),
  ('Allied Health & Health Promotion', '45 to 64', 'enhanced', 140, 150),
  ('Allied Health & Health Promotion', '65 to 125', 'enhanced', 160, 170),

  ('Allied Health & Health Promotion', '0 to 4', 'high_risk', 75, 90),
  ('Allied Health & Health Promotion', '5 to 19', 'high_risk', 120, 135),
  ('Allied Health & Health Promotion', '20 to 29', 'high_risk', 150, 165),
  ('Allied Health & Health Promotion', '30 to 44', 'high_risk', 180, 195),
  ('Allied Health & Health Promotion', '45 to 64', 'high_risk', 210, 225),
  ('Allied Health & Health Promotion', '65 to 125', 'high_risk', 240, 255);