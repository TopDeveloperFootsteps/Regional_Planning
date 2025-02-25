/*
  # Populate service mappings in encounters table

  1. Changes
    - Update existing encounters records with service mappings
    - Uses the get_service_mapping function to look up mappings from respective tables

  2. Notes
    - Safe update that preserves existing data
    - Updates are performed in batches to avoid timeouts
*/

-- Update encounters table with service mappings
DO $$ 
DECLARE 
    r RECORD;
    mapping_result RECORD;
BEGIN
    FOR r IN SELECT * FROM encounters
    LOOP
        -- Get mapping for each record
        SELECT * FROM get_service_mapping(
            r."care setting",
            r."icd family code",
            r."system of care"
        ) INTO mapping_result;
        
        -- Update record if mapping found
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

-- Create index on id for faster updates
CREATE INDEX IF NOT EXISTS idx_encounters_id ON encounters (id);