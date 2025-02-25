-- Add new mappings for generic conditions and family medicine
DO $$ 
BEGIN
    -- First ensure systems_of_care column exists
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'home_services_mapping' 
        AND column_name = 'systems_of_care'
    ) THEN
        ALTER TABLE home_services_mapping ADD COLUMN systems_of_care text;
    END IF;
END $$;

-- Insert new mappings
INSERT INTO home_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Generic symptoms/conditions that map to Acute & urgent care
  ('R50.9', 'Acute & urgent care', 'high', 'Fever, unspecified - common primary care presentation suitable for home assessment', 'Unplanned care'),
  ('R51', 'Acute & urgent care', 'high', 'Headache - common primary care presentation requiring initial assessment', 'Unplanned care'),
  ('J06.9', 'Acute & urgent care', 'high', 'Acute upper respiratory infection - typical primary care condition suitable for home visit', 'Unplanned care'),
  ('R10.9', 'Acute & urgent care', 'high', 'Unspecified abdominal pain - requires initial assessment and can be managed at home if not severe', 'Unplanned care'),
  
  -- Common primary care conditions
  ('J20.9', 'Acute & urgent care', 'high', 'Acute bronchitis - common condition suitable for home-based assessment and treatment', 'Unplanned care'),
  ('L30.9', 'Acute & urgent care', 'medium', 'Dermatitis, unspecified - can be initially assessed and managed at home', 'Unplanned care'),
  ('H66.90', 'Acute & urgent care', 'high', 'Otitis media - common primary care condition suitable for home visit', 'Unplanned care'),
  
  -- General health supervision
  ('Z00.00', 'Allied Health & Health Promotion', 'high', 'General adult medical examination - routine health maintenance', 'Planned care'),
  ('Z71.89', 'Allied Health & Health Promotion', 'high', 'Other specified counseling - general health advice and guidance', 'Planned care'),
  
  -- Chronic condition follow-ups
  ('Z71.9', 'Chronic metabolic diseases', 'medium', 'Counseling, unspecified - follow-up for chronic condition management', 'Chronic conditions'),
  ('Z51.81', 'Complex condition / Frail elderly', 'high', 'Encounter for therapeutic drug level monitoring - medication management', 'Complex, multi-morbid');

-- Create index for systems_of_care if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE tablename = 'home_services_mapping'
        AND indexname = 'idx_home_services_mapping_systems_of_care'
    ) THEN
        CREATE INDEX idx_home_services_mapping_systems_of_care 
        ON home_services_mapping (systems_of_care);
    END IF;
END $$;