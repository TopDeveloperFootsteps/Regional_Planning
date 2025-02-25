/*
  # Optimize ICD code search
  
  1. Changes
    - Add B-tree index for faster ICD code searches
    - Ensure consistent case formatting for ICD codes
*/

-- Add index for faster ICD code searches
CREATE INDEX IF NOT EXISTS idx_home_services_mapping_icd_code 
ON home_services_mapping (icd_code);

-- Ensure the ICD codes are stored in a consistent format
UPDATE home_services_mapping 
SET icd_code = UPPER(TRIM(icd_code))
WHERE icd_code != UPPER(TRIM(icd_code));