/*
  # Add service mapping columns to encounters table

  1. Changes
    - Add Service, Confidence, and Mapping Logic columns to encounters table
    - Create indexes for new columns
    - Maintain existing RLS policies

  2. Security
    - Keep existing RLS policies
*/

-- Add new columns to encounters table
ALTER TABLE encounters 
ADD COLUMN "service" text,
ADD COLUMN "confidence" text CHECK (confidence IN ('high', 'medium', 'low')),
ADD COLUMN "mapping logic" text;

-- Create indexes for new columns
CREATE INDEX IF NOT EXISTS idx_encounters_service
    ON encounters ("service");

CREATE INDEX IF NOT EXISTS idx_encounters_confidence
    ON encounters ("confidence");

-- Create a function to get service mapping
CREATE OR REPLACE FUNCTION get_service_mapping(
    p_care_setting text,
    p_icd_code text,
    p_system_of_care text
) RETURNS TABLE (
    service text,
    confidence text,
    mapping_logic text
) AS $$
BEGIN
    CASE p_care_setting
        WHEN 'HEALTH STATION' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM health_station_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'HOME' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM home_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'AMBULATORY SERVICE CENTER' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM ambulatory_service_center_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'SPECIALTY CARE CENTER' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM specialty_care_center_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'EXTENDED CARE FACILITY' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM extended_care_facility_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'HOSPITAL' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM hospital_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger function to automatically update service mapping
CREATE OR REPLACE FUNCTION update_service_mapping()
RETURNS TRIGGER AS $$
DECLARE
    mapping_result RECORD;
BEGIN
    SELECT * FROM get_service_mapping(
        NEW."care setting",
        NEW."icd family code",
        NEW."system of care"
    ) INTO mapping_result;
    
    IF mapping_result IS NOT NULL THEN
        NEW.service := mapping_result.service;
        NEW.confidence := mapping_result.confidence;
        NEW."mapping logic" := mapping_result.mapping_logic;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update service mapping on insert or update
CREATE TRIGGER update_service_mapping_trigger
    BEFORE INSERT OR UPDATE ON encounters
    FOR EACH ROW
    EXECUTE FUNCTION update_service_mapping();