-- Insert initial visit rates for Primary dental care
INSERT INTO visit_rates 
(service, age_group, assumption_type, male_rate, female_rate)
VALUES
  -- Model rates
  ('Primary dental care', '0 to 4', 'model', 113.8, 119.5),
  ('Primary dental care', '5 to 19', 'model', 955.8, 1004.2),
  ('Primary dental care', '20 to 29', 'model', 586.3, 587.7),
  ('Primary dental care', '30 to 44', 'model', 448.4, 425.0),
  ('Primary dental care', '45 to 64', 'model', 503.6, 484.3),
  ('Primary dental care', '65 to 125', 'model', 766.4, 621.9),

  -- Enhanced rates
  ('Primary dental care', '0 to 4', 'enhanced', 150.0, 160.0),
  ('Primary dental care', '5 to 19', 'enhanced', 300.0, 320.0),
  ('Primary dental care', '20 to 29', 'enhanced', 250.0, 270.0),
  ('Primary dental care', '30 to 44', 'enhanced', 280.0, 300.0),
  ('Primary dental care', '45 to 64', 'enhanced', 260.0, 280.0),
  ('Primary dental care', '65 to 125', 'enhanced', 240.0, 260.0),

  -- High risk rates (using enhanced rates * 1.5 as an example)
  ('Primary dental care', '0 to 4', 'high_risk', 225.0, 240.0),
  ('Primary dental care', '5 to 19', 'high_risk', 450.0, 480.0),
  ('Primary dental care', '20 to 29', 'high_risk', 375.0, 405.0),
  ('Primary dental care', '30 to 44', 'high_risk', 420.0, 450.0),
  ('Primary dental care', '45 to 64', 'high_risk', 390.0, 420.0),
  ('Primary dental care', '65 to 125', 'high_risk', 360.0, 390.0);