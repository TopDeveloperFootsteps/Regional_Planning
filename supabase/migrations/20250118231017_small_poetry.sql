-- Add mappings for next batch of 500 unmapped codes
INSERT INTO specialty_care_center_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Ophthalmology
  ('H40', 'Ophthalmology', 'high', 'Glaucoma requires ophthalmological care', 'Chronic conditions'),
  ('H35', 'Ophthalmology', 'high', 'Retinal disorders need specialist evaluation', 'Complex, multi-morbid'),
  ('H25', 'Ophthalmology', 'high', 'Age-related cataract requires surgical assessment', 'Planned care'),
  ('H26', 'Ophthalmology', 'high', 'Other cataract needs ophthalmological care', 'Planned care'),
  ('H33', 'Ophthalmology', 'high', 'Retinal detachments require urgent care', 'Unplanned care'),
  
  -- Otolaryngology / ENT
  ('H60', 'Otolaryngology / ENT', 'high', 'External ear disorders need ENT care', 'Planned care'),
  ('H65', 'Otolaryngology / ENT', 'high', 'Nonsuppurative otitis media requires treatment', 'Unplanned care'),
  ('H66', 'Otolaryngology / ENT', 'high', 'Suppurative otitis media needs specialist care', 'Unplanned care'),
  ('H71', 'Otolaryngology / ENT', 'high', 'Cholesteatoma requires ENT management', 'Complex, multi-morbid'),
  ('H81', 'Otolaryngology / ENT', 'high', 'Vestibular function disorders need evaluation', 'Planned care'),
  
  -- Dermatology
  ('L40', 'Dermatology', 'high', 'Psoriasis requires dermatological care', 'Chronic conditions'),
  ('L41', 'Dermatology', 'high', 'Parapsoriasis needs specialist evaluation', 'Chronic conditions'),
  ('L50', 'Dermatology', 'high', 'Urticaria requires assessment', 'Unplanned care'),
  ('L51', 'Dermatology', 'high', 'Erythema multiforme needs urgent care', 'Unplanned care'),
  ('L70', 'Dermatology', 'high', 'Acne requires dermatological management', 'Planned care'),
  
  -- Orthopedics
  ('M16', 'Orthopaedics (inc. podiatry)', 'high', 'Hip osteoarthritis needs orthopedic care', 'Chronic conditions'),
  ('M17', 'Orthopaedics (inc. podiatry)', 'high', 'Knee osteoarthritis requires evaluation', 'Chronic conditions'),
  ('M20', 'Orthopaedics (inc. podiatry)', 'high', 'Acquired deformities of fingers and toes', 'Planned care'),
  ('M23', 'Orthopaedics (inc. podiatry)', 'high', 'Internal derangement of knee needs assessment', 'Planned care'),
  ('M25', 'Orthopaedics (inc. podiatry)', 'high', 'Other joint disorders require treatment', 'Planned care'),
  
  -- Urology
  ('N40', 'Urology', 'high', 'Prostatic hyperplasia requires urological care', 'Chronic conditions'),
  ('N41', 'Urology', 'high', 'Inflammatory diseases of prostate need treatment', 'Unplanned care'),
  ('N45', 'Urology', 'high', 'Orchitis and epididymitis require evaluation', 'Unplanned care'),
  ('N48', 'Urology', 'high', 'Other disorders of penis need assessment', 'Planned care'),
  ('N50', 'Urology', 'high', 'Other male genital disorders require care', 'Planned care'),
  
  -- Obstetrics & Gynecology
  ('O20', 'Obstetrics & Gynaecology', 'high', 'Hemorrhage in early pregnancy needs urgent care', 'Unplanned care'),
  ('O21', 'Obstetrics & Gynaecology', 'high', 'Excessive vomiting in pregnancy requires treatment', 'Planned care'),
  ('O23', 'Obstetrics & Gynaecology', 'high', 'Infections of genitourinary tract in pregnancy', 'Unplanned care'),
  ('O24', 'Obstetrics & Gynaecology', 'high', 'Diabetes mellitus in pregnancy needs management', 'Planned care'),
  ('O26', 'Obstetrics & Gynaecology', 'high', 'Maternal care for other conditions', 'Planned care'),
  
  -- Psychiatry
  ('F31', 'Psychiatry', 'high', 'Bipolar disorder requires psychiatric care', 'Complex, multi-morbid'),
  ('F32', 'Psychiatry', 'high', 'Major depressive disorder needs management', 'Complex, multi-morbid'),
  ('F33', 'Psychiatry', 'high', 'Recurrent depressive disorder requires treatment', 'Complex, multi-morbid'),
  ('F41', 'Psychiatry', 'high', 'Other anxiety disorders need evaluation', 'Complex, multi-morbid'),
  ('F43', 'Psychiatry', 'high', 'Reaction to severe stress requires care', 'Complex, multi-morbid'),
  
  -- Infectious Diseases
  ('A30', 'Infectious Diseases', 'high', 'Leprosy requires specialist management', 'Complex, multi-morbid'),
  ('A31', 'Infectious Diseases', 'high', 'Other mycobacterial infections need care', 'Complex, multi-morbid'),
  ('B15', 'Infectious Diseases', 'high', 'Acute hepatitis A requires treatment', 'Unplanned care'),
  ('B16', 'Infectious Diseases', 'high', 'Acute hepatitis B needs management', 'Unplanned care'),
  ('B17', 'Infectious Diseases', 'high', 'Other acute viral hepatitis requires care', 'Unplanned care');

-- Update encounters with new mappings
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'SPECIALTY CARE CENTER'
        AND service IS NULL
        LIMIT 500
    LOOP
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_care_center_services_mapping
        WHERE icd_code LIKE LEFT(r."icd family code", 3) || '%'
        AND systems_of_care = r."system of care"
        LIMIT 1
        INTO mapping_result;
        
        IF mapping_result IS NOT NULL THEN
            UPDATE encounters 
            SET 
                service = mapping_result.service,
                confidence = mapping_result.confidence,
                "mapping logic" = mapping_result.mapping_logic
            WHERE id = r.id;
        END IF;
    END LOOP;
END $$;

-- Show mapping progress
SELECT 
    'SPECIALTY CARE CENTER' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';