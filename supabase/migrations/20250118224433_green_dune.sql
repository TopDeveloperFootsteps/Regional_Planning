/*
  # Add Additional Specialty Care Service Mappings

  1. New Mappings
    - Add comprehensive specialty care service mappings
    - Focus on specialized medical services
    - Cover multiple systems of care

  2. Process
    - Insert new specialty care mappings
    - Update unmapped encounters
    - Show updated mapping statistics
*/

-- Add specialty care service mappings
INSERT INTO specialty_services_mapping 
(icd_code, service, confidence, mapping_logic, systems_of_care) 
VALUES
  -- Ophthalmology
  ('H25', 'Ophthalmology', 'high', 'Senile cataract requires specialized ophthalmological care', 'Planned care'),
  ('H40', 'Ophthalmology', 'high', 'Glaucoma needs ongoing specialist management', 'Chronic conditions'),
  ('H33', 'Ophthalmology', 'high', 'Retinal detachments require specialist intervention', 'Unplanned care'),
  
  -- Otolaryngology
  ('H81', 'Otolaryngology / ENT', 'high', 'Disorders of vestibular function need specialist evaluation', 'Planned care'),
  ('H90', 'Otolaryngology / ENT', 'high', 'Conductive and sensorineural hearing loss requires ENT care', 'Chronic conditions'),
  ('J32', 'Otolaryngology / ENT', 'high', 'Chronic sinusitis needs specialist management', 'Chronic conditions'),
  
  -- Dermatology
  ('L40', 'Dermatology', 'high', 'Psoriasis requires specialized dermatological care', 'Chronic conditions'),
  ('L30', 'Dermatology', 'high', 'Other dermatitis needs specialist evaluation', 'Planned care'),
  ('L73', 'Dermatology', 'medium', 'Other follicular disorders require dermatology care', 'Planned care'),
  
  -- Urology
  ('N20', 'Urology', 'high', 'Kidney stone requires urological management', 'Unplanned care'),
  ('N40', 'Urology', 'high', 'Prostatic hyperplasia needs specialist care', 'Chronic conditions'),
  ('N31', 'Urology', 'high', 'Neuromuscular dysfunction of bladder requires specialist management', 'Complex, multi-morbid'),
  
  -- Plastic Surgery
  ('L91', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Hypertrophic disorders of skin need specialist care', 'Planned care'),
  ('Q18', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Other congenital malformations of face and neck', 'Planned care'),
  ('T20', 'Plastics (incl. Burns and Maxillofacial)', 'high', 'Burns requiring specialized care', 'Unplanned care'),
  
  -- Vascular Surgery
  ('I70', 'Vascular Surgery', 'high', 'Atherosclerosis requires vascular specialist care', 'Chronic conditions'),
  ('I83', 'Vascular Surgery', 'high', 'Varicose veins need specialist evaluation', 'Planned care'),
  ('I74', 'Vascular Surgery', 'high', 'Arterial embolism and thrombosis require urgent care', 'Unplanned care'),
  
  -- Orthopedics
  ('M23', 'Orthopaedics (inc. podiatry)', 'high', 'Internal derangement of knee needs specialist care', 'Planned care'),
  ('M75', 'Orthopaedics (inc. podiatry)', 'high', 'Shoulder lesions require orthopedic evaluation', 'Planned care'),
  ('M51', 'Orthopaedics (inc. podiatry)', 'high', 'Intervertebral disc disorders need specialist management', 'Chronic conditions'),
  
  -- Allergy/Immunology
  ('J30', 'Allergy and Immunology', 'high', 'Vasomotor and allergic rhinitis needs specialist care', 'Chronic conditions'),
  ('L50', 'Allergy and Immunology', 'high', 'Urticaria requires immunology evaluation', 'Chronic conditions'),
  ('D80', 'Allergy and Immunology', 'high', 'Immunodeficiency needs specialist management', 'Complex, multi-morbid'),
  
  -- Physical Medicine
  ('M62', 'Physical Medicine and Rehabilitation', 'high', 'Other disorders of muscle need rehabilitation', 'Planned care'),
  ('M96', 'Physical Medicine and Rehabilitation', 'high', 'Postprocedural musculoskeletal disorders', 'Complex, multi-morbid'),
  ('R26', 'Physical Medicine and Rehabilitation', 'high', 'Abnormalities of gait and mobility need therapy', 'Complex, multi-morbid'),
  
  -- Infectious Disease
  ('B20', 'Infectious Diseases', 'high', 'HIV disease requires specialist management', 'Complex, multi-morbid'),
  ('B18', 'Infectious Diseases', 'high', 'Chronic viral hepatitis needs ongoing care', 'Chronic conditions'),
  ('A31', 'Infectious Diseases', 'high', 'Mycobacterial infections require specialist care', 'Complex, multi-morbid');

-- Map SPECIALTY CARE CENTER encounters
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    -- Loop through unmapped SPECIALTY CARE CENTER encounters
    FOR r IN 
        SELECT * 
        FROM encounters 
        WHERE "care setting" = 'SPECIALTY CARE CENTER'
        AND (service IS NULL OR confidence IS NULL OR "mapping logic" IS NULL)
    LOOP
        -- Get mapping from specialty_services_mapping
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_services_mapping
        WHERE icd_code LIKE LEFT(r."icd family code", 3) || '%'
        AND systems_of_care = r."system of care"
        LIMIT 1
        INTO mapping_result;
        
        -- Update encounter if mapping found
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

-- Show updated mapping statistics
SELECT 
    'SPECIALTY CARE CENTER' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';