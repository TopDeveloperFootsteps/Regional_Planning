-- First: Check if we have both tables
DO $$ 
BEGIN
    -- Create specialty_care_center_services_mapping if it doesn't exist
    CREATE TABLE IF NOT EXISTS specialty_care_center_services_mapping (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        icd_code text NOT NULL,
        service text NOT NULL,
        confidence text NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
        mapping_logic text NOT NULL,
        systems_of_care text NOT NULL,
        created_at timestamptz DEFAULT now()
    );

    -- Enable RLS
    ALTER TABLE specialty_care_center_services_mapping ENABLE ROW LEVEL SECURITY;

    -- Create policy for public read access
    DROP POLICY IF EXISTS "Allow public read access on specialty_care_center_services_mapping" 
    ON specialty_care_center_services_mapping;
    
    CREATE POLICY "Allow public read access on specialty_care_center_services_mapping"
        ON specialty_care_center_services_mapping
        FOR SELECT
        TO public
        USING (true);

    -- Create index if it doesn't exist
    CREATE INDEX IF NOT EXISTS idx_specialty_care_center_services_mapping_icd_code 
    ON specialty_care_center_services_mapping (icd_code);

    CREATE INDEX IF NOT EXISTS idx_specialty_care_center_services_mapping_systems_of_care
    ON specialty_care_center_services_mapping (systems_of_care);
END $$;

-- Copy data from specialty_services_mapping if it exists
DO $$ 
BEGIN
    IF EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'specialty_services_mapping'
    ) THEN
        INSERT INTO specialty_care_center_services_mapping (
            icd_code, 
            service, 
            confidence, 
            mapping_logic, 
            systems_of_care
        )
        SELECT 
            icd_code, 
            service, 
            confidence, 
            mapping_logic, 
            systems_of_care
        FROM specialty_services_mapping
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- Update encounters with correct table reference
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
    LOOP
        -- Try exact 3-character match first
        SELECT 
            service, 
            confidence, 
            mapping_logic
        FROM specialty_care_center_services_mapping
        WHERE icd_code LIKE LEFT(r."icd family code", 3) || '%'
        AND systems_of_care = r."system of care"
        LIMIT 1
        INTO mapping_result;
        
        -- If no match, try first character match
        IF mapping_result IS NULL THEN
            SELECT 
                service, 
                confidence, 
                mapping_logic
            FROM specialty_care_center_services_mapping
            WHERE icd_code = LEFT(r."icd family code", 1)
            AND systems_of_care = r."system of care"
            LIMIT 1
            INTO mapping_result;
        END IF;
        
        -- If still no match, use default mapping based on system of care
        IF mapping_result IS NULL THEN
            UPDATE encounters 
            SET 
                service = CASE r."system of care"
                    WHEN 'Complex, multi-morbid' THEN 'Complex condition / Frail elderly'
                    WHEN 'Chronic conditions' THEN 'Chronic metabolic diseases'
                    WHEN 'Children and young people' THEN 'Paediatric Medicine'
                    WHEN 'Unplanned care' THEN 'Acute & urgent care'
                    WHEN 'Planned care' THEN 'Allied Health & Health Promotion'
                    WHEN 'Palliative care and support' THEN 'Hospice and Palliative Care'
                END,
                confidence = 'medium',
                "mapping logic" = 'Default mapping based on system of care'
            WHERE id = r.id;
        ELSE
            -- Update with found mapping
            UPDATE encounters 
            SET 
                service = mapping_result.service,
                confidence = mapping_result.confidence,
                "mapping logic" = mapping_result.mapping_logic
            WHERE id = r.id;
        END IF;
    END LOOP;
END $$;

-- Show final mapping statistics
SELECT 
    'SPECIALTY CARE CENTER' as care_setting,
    COUNT(*) as total_records,
    COUNT(service) as mapped_records,
    COUNT(*) - COUNT(service) as unmapped_records,
    ROUND((COUNT(service)::numeric / COUNT(*)::numeric * 100), 2) || '%' as mapping_percentage,
    COUNT(*) FILTER (WHERE confidence = 'high') as high_confidence_count,
    COUNT(*) FILTER (WHERE confidence = 'medium') as medium_confidence_count,
    COUNT(*) FILTER (WHERE confidence = 'low') as low_confidence_count
FROM encounters
WHERE "care setting" = 'SPECIALTY CARE CENTER';