/*
  # Update Column Names to Match CSV Structure

  1. Changes
    Modify all tables to use exact CSV header names:
    - Rename 'care_setting' to 'Care Setting'
    - Rename 'systems_of_care' to 'Systems of Care'
    - Rename 'icd_family_code' to 'ICD FamilyCode'

  2. Notes
    - Column names with spaces are wrapped in double quotes
    - Preserves existing data and constraints
*/

DO $$ 
BEGIN
  -- Health Station Codes
  ALTER TABLE health_station_codes 
    RENAME COLUMN care_setting TO "Care Setting";
  ALTER TABLE health_station_codes 
    RENAME COLUMN systems_of_care TO "Systems of Care";
  ALTER TABLE health_station_codes 
    RENAME COLUMN icd_family_code TO "ICD FamilyCode";

  -- Home Codes
  ALTER TABLE home_codes 
    RENAME COLUMN care_setting TO "Care Setting";
  ALTER TABLE home_codes 
    RENAME COLUMN systems_of_care TO "Systems of Care";
  ALTER TABLE home_codes 
    RENAME COLUMN icd_family_code TO "ICD FamilyCode";

  -- Ambulatory Service Center Codes
  ALTER TABLE ambulatory_service_center_codes 
    RENAME COLUMN care_setting TO "Care Setting";
  ALTER TABLE ambulatory_service_center_codes 
    RENAME COLUMN systems_of_care TO "Systems of Care";
  ALTER TABLE ambulatory_service_center_codes 
    RENAME COLUMN icd_family_code TO "ICD FamilyCode";

  -- Specialty Care Center Codes
  ALTER TABLE specialty_care_center_codes 
    RENAME COLUMN care_setting TO "Care Setting";
  ALTER TABLE specialty_care_center_codes 
    RENAME COLUMN systems_of_care TO "Systems of Care";
  ALTER TABLE specialty_care_center_codes 
    RENAME COLUMN icd_family_code TO "ICD FamilyCode";

  -- Extended Care Facility Codes
  ALTER TABLE extended_care_facility_codes 
    RENAME COLUMN care_setting TO "Care Setting";
  ALTER TABLE extended_care_facility_codes 
    RENAME COLUMN systems_of_care TO "Systems of Care";
  ALTER TABLE extended_care_facility_codes 
    RENAME COLUMN icd_family_code TO "ICD FamilyCode";

  -- Hospital Codes
  ALTER TABLE hospital_codes 
    RENAME COLUMN care_setting TO "Care Setting";
  ALTER TABLE hospital_codes 
    RENAME COLUMN systems_of_care TO "Systems of Care";
  ALTER TABLE hospital_codes 
    RENAME COLUMN icd_family_code TO "ICD FamilyCode";
END $$;