/*
  # Update remaining null mappings in home_sm

  1. Changes
    - Map remaining null values based on system of care and ICD code patterns
    - Update confidence and mapping logic accordingly
*/

-- Update remaining unmapped codes based on systems of care
UPDATE home_sm
SET 
    service = CASE 
        WHEN systems_of_care = 'Unplanned care' THEN 'Acute & urgent care'
        WHEN systems_of_care = 'Planned care' THEN 'Allied Health & Health Promotion'
        WHEN systems_of_care = 'Children and young people' THEN 'Paediatric care (5 to 16)'
        WHEN systems_of_care = 'Complex, multi-morbid' THEN 'Complex condition / Frail elderly'
        WHEN systems_of_care = 'Chronic conditions' THEN 'Other chronic diseases'
        WHEN systems_of_care = 'Palliative care and support' THEN 'Complex condition / Frail elderly'
        WHEN systems_of_care = 'Wellness and longevity' THEN 'Routine health checks'
    END,
    confidence = 'medium',
    mapping_logic = CASE 
        WHEN systems_of_care = 'Unplanned care' THEN 'Mapped based on unplanned care system requirement'
        WHEN systems_of_care = 'Planned care' THEN 'Mapped based on planned care system requirement'
        WHEN systems_of_care = 'Children and young people' THEN 'Mapped based on pediatric care system requirement'
        WHEN systems_of_care = 'Complex, multi-morbid' THEN 'Mapped based on complex care system requirement'
        WHEN systems_of_care = 'Chronic conditions' THEN 'Mapped based on chronic care system requirement'
        WHEN systems_of_care = 'Palliative care and support' THEN 'Mapped based on palliative care system requirement'
        WHEN systems_of_care = 'Wellness and longevity' THEN 'Mapped based on wellness system requirement'
    END
WHERE service IS NULL;

-- Create a view to show any remaining unmapped codes
CREATE OR REPLACE VIEW home_sm_unmapped AS
SELECT 
    icd_code,
    systems_of_care,
    LEFT(icd_code, 1) as icd_category
FROM home_sm
WHERE service IS NULL
ORDER BY systems_of_care, icd_code;