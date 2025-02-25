/*
  # Drop all existing views

  1. Changes
    - Drops all views related to home codes mapping and statistics
*/

-- Drop all views in the correct order (dependent views first)
DROP VIEW IF EXISTS unmapped_home_codes_summary;
DROP VIEW IF EXISTS unmapped_home_codes_detailed;
DROP VIEW IF EXISTS home_mapping_statistics;
DROP VIEW IF EXISTS home_mapping_summary;
DROP VIEW IF EXISTS unmapped_home_codes;
DROP VIEW IF EXISTS home_codes_mapping_status;
DROP VIEW IF EXISTS home_mapping_data_check;