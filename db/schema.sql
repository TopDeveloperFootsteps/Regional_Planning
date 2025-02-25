

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."icon_type" AS ENUM (
    'region',
    'sub_region',
    'both'
);


ALTER TYPE "public"."icon_type" OWNER TO "postgres";


CREATE TYPE "public"."region_status" AS ENUM (
    'active',
    'inactive'
);


ALTER TYPE "public"."region_status" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_proposed_percentages"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_total numeric;
    v_count integer;
BEGIN
    -- Check if we have all required care settings
    SELECT COUNT(*), SUM(proposed_percentage)
    INTO v_count, v_total
    FROM proposed_care_setting_distribution
    WHERE plan_id = NEW.plan_id;

    IF v_count = 6 AND ROUND(v_total) != 100 THEN
        RAISE EXCEPTION 'Total proposed percentages must equal 100%%';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_proposed_percentages"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."check_proposed_percentages"() IS 'Trigger function to ensure proposed percentages sum to 100%';



CREATE OR REPLACE FUNCTION "public"."clean_activity_value"("activity_str" "text") RETURNS numeric
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Remove commas and convert to numeric
    RETURN replace(activity_str, ',', '')::numeric(20,2);
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Invalid activity value: %', activity_str;
END;
$$;


ALTER FUNCTION "public"."clean_activity_value"("activity_str" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."extract_icd_range"("description" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    code_match text;
BEGIN
    -- Extract text within parentheses that matches pattern like (Z00-Z13)
    SELECT substring(description FROM '\(([A-Z][0-9]+(?:-[A-Z][0-9]+)?)\)')
    INTO code_match;
    
    RETURN code_match;
END;
$$;


ALTER FUNCTION "public"."extract_icd_range"("description" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fix_invalid_services"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Update invalid services using the service mapping function
    UPDATE planning_family_code pfc
    SET service = get_service_for_planning(pfc.care_setting, pfc.icd_family, pfc.systems_of_care)
    WHERE pfc.service NOT IN (SELECT service FROM valid_services_view);
END;
$$;


ALTER FUNCTION "public"."fix_invalid_services"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."fix_invalid_services"() IS 'Updates invalid services in planning_family_code table using service mapping function';



CREATE OR REPLACE FUNCTION "public"."generate_region_id"("region_name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    prefix text;
    next_num integer;
    new_id text;
BEGIN
    -- Get first 3 letters of region name (uppercase)
    prefix := UPPER(LEFT(region_name, 3));
    
    -- Find the highest number used for this prefix
    SELECT COALESCE(MAX(NULLIF(REGEXP_REPLACE(id, '^' || prefix, ''), '')::integer), 0)
    INTO next_num
    FROM regions
    WHERE id LIKE prefix || '%';
    
    -- Generate new ID
    new_id := prefix || (next_num + 1);
    
    RETURN new_id;
END;
$$;


ALTER FUNCTION "public"."generate_region_id"("region_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_appropriate_service"("p_icd_code" "text", "p_care_setting" "text", "p_systems_of_care" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_service text;
BEGIN
    -- Check care setting and get service from appropriate mapping table
    CASE p_care_setting
        WHEN 'HOME' THEN
            SELECT service INTO v_service
            FROM home_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_systems_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'HEALTH STATION' THEN
            SELECT service INTO v_service
            FROM health_station_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_systems_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'AMBULATORY SERVICE CENTER' THEN
            SELECT service INTO v_service
            FROM ambulatory_service_center_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_systems_of_care
            ORDER BY confidence DESC
            LIMIT 1;
    END CASE;

    RETURN v_service;
END;
$$;


ALTER FUNCTION "public"."get_appropriate_service"("p_icd_code" "text", "p_care_setting" "text", "p_systems_of_care" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_icon_url"("storage_path" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN 'https://cdbxhphnyyudtfsckotz.supabase.co/storage/v1/object/public/icons/' || storage_path;
END;
$$;


ALTER FUNCTION "public"."get_icon_url"("storage_path" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."map_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "show_circles" boolean DEFAULT false,
    "circle_transparency" integer DEFAULT 50,
    "circle_border" boolean DEFAULT true,
    "circle_radius_km" integer DEFAULT 10,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "map_settings_circle_transparency_check" CHECK ((("circle_transparency" >= 0) AND ("circle_transparency" <= 100)))
);


ALTER TABLE "public"."map_settings" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_map_settings"() RETURNS "public"."map_settings"
    LANGUAGE "sql" STABLE
    AS $$
    SELECT *
    FROM map_settings
    LIMIT 1;
$$;


ALTER FUNCTION "public"."get_map_settings"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_service_for_planning"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_service text;
    v_icd_prefix text;
BEGIN
    -- Get first character/prefix of ICD code
    v_icd_prefix := LEFT(p_icd_code, 1);

    -- First check for dental codes
    IF LEFT(p_icd_code, 2) IN ('K0') THEN
        RETURN 'Primary dental care';
    END IF;

    -- Rest of the function remains the same...
    CASE p_care_setting
        WHEN 'HOME' THEN
            SELECT service INTO v_service
            FROM home_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'HEALTH STATION' THEN
            SELECT service INTO v_service
            FROM health_station_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'AMBULATORY SERVICE CENTER' THEN
            SELECT service INTO v_service
            FROM ambulatory_service_center_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'SPECIALTY CARE CENTER' THEN
            SELECT service INTO v_service
            FROM specialty_care_center_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'EXTENDED CARE FACILITY' THEN
            SELECT service INTO v_service
            FROM extended_care_facility_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
            
        WHEN 'HOSPITAL' THEN
            SELECT service INTO v_service
            FROM hospital_services_mapping
            WHERE icd_code LIKE LEFT(p_icd_code, 3) || '%'
            AND systems_of_care = p_system_of_care
            ORDER BY confidence DESC
            LIMIT 1;
    END CASE;

    -- If no specific mapping found, use a default based on system of care
    IF v_service IS NULL THEN
        v_service := CASE p_system_of_care
            WHEN 'Planned care' THEN 'Allied Health & Health Promotion'
            WHEN 'Unplanned care' THEN 'Acute & urgent care'
            WHEN 'Wellness and longevity' THEN 'Allied Health & Health Promotion'
            WHEN 'Children and young people' THEN 'Paediatric Medicine'
            WHEN 'Chronic conditions' THEN 'Internal Medicine'
            WHEN 'Complex, multi-morbid' THEN 'Complex condition / Frail elderly'
            WHEN 'Palliative care and support' THEN 'Hospice and Palliative Care'
            ELSE 'Other'
        END;
    END IF;

    RETURN v_service;
END;
$$;


ALTER FUNCTION "public"."get_service_for_planning"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_service_mapping"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") RETURNS TABLE("service" "text", "confidence" "text", "mapping_logic" "text")
    LANGUAGE "plpgsql"
    AS $$
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
            FROM ambulatory_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'SPECIALTY CARE CENTER' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM specialty_services_mapping sm
            WHERE sm.icd_code LIKE p_icd_code || '%'
            AND sm.systems_of_care = p_system_of_care
            LIMIT 1;
            
        WHEN 'EXTENDED CARE FACILITY' THEN
            RETURN QUERY 
            SELECT sm.service, sm.confidence, sm.mapping_logic
            FROM extended_services_mapping sm
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
$$;


ALTER FUNCTION "public"."get_service_mapping"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."inactivate_region_cascade"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF NEW.status = 'inactive' THEN
        UPDATE sub_regions
        SET status = 'inactive'
        WHERE region_id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."inactivate_region_cascade"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."initialize_proposed_distribution"("p_plan_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_care_setting text;
BEGIN
    -- Get all care settings and their current percentages
    FOR v_care_setting IN 
        SELECT DISTINCT care_setting 
        FROM planning_family_code
    LOOP
        -- Calculate current percentage for this care setting
        WITH total_activity AS (
            SELECT SUM(activity) as total FROM planning_family_code
        ),
        setting_activity AS (
            SELECT 
                SUM(activity) as setting_total,
                (SELECT total FROM total_activity) as grand_total
            FROM planning_family_code
            WHERE care_setting = v_care_setting
        )
        INSERT INTO proposed_care_setting_distribution 
            (plan_id, care_setting, current_percentage, proposed_percentage)
        SELECT 
            p_plan_id,
            v_care_setting,
            ROUND((setting_total * 100.0 / grand_total)::numeric, 2),
            ROUND((setting_total * 100.0 / grand_total)::numeric, 2)
        FROM setting_activity
        ON CONFLICT (plan_id, care_setting) DO UPDATE
        SET 
            current_percentage = EXCLUDED.current_percentage,
            proposed_percentage = EXCLUDED.proposed_percentage;
    END LOOP;

    -- Ensure all care settings exist with default values
    INSERT INTO proposed_care_setting_distribution 
        (plan_id, care_setting, current_percentage, proposed_percentage)
    VALUES 
        (p_plan_id, 'HOME', 15, 15),
        (p_plan_id, 'HEALTH STATION', 20, 20),
        (p_plan_id, 'AMBULATORY SERVICE CENTER', 25, 25),
        (p_plan_id, 'SPECIALTY CARE CENTER', 18, 18),
        (p_plan_id, 'EXTENDED CARE FACILITY', 12, 12),
        (p_plan_id, 'HOSPITAL', 10, 10)
    ON CONFLICT (plan_id, care_setting) DO NOTHING;
END;
$$;


ALTER FUNCTION "public"."initialize_proposed_distribution"("p_plan_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."initialize_proposed_distribution"("p_plan_id" "uuid") IS 'Initializes proposed distribution percentages for a plan';



CREATE OR REPLACE FUNCTION "public"."migrate_planning_code_sections"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Clear existing data
    DELETE FROM planning_code_sections;
    
    -- Insert data from staging table with cleaned numeric values
    INSERT INTO planning_code_sections 
    (systems_of_care, care_setting, icd_sections, activity)
    SELECT 
        systems_of_care,
        care_setting,
        icd_sections,
        replace(activity, ',', '')::numeric(20,2)
    FROM planning_code_sections_staging;
    
    -- Clear staging table
    DELETE FROM planning_code_sections_staging;
END;
$$;


ALTER FUNCTION "public"."migrate_planning_code_sections"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."migrate_planning_code_sections"() IS 'Migrates data from staging table to final table, cleaning numeric values';



CREATE OR REPLACE FUNCTION "public"."set_planning_family_service"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.service := get_service_for_planning(NEW.care_setting, NEW.icd_family, NEW.systems_of_care);
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_planning_family_service"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_population_defaults"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Set default factor and divisor based on population type
    IF NEW.population_type IN ('Staff', 'Residents', 'Construction Worker') THEN
        NEW.default_factor := 365;
        NEW.divisor := 365;
    ELSIF NEW.population_type = 'Tourists/Visit' THEN
        -- For Tourists/Visit, only set defaults if values are NULL
        IF NEW.default_factor IS NULL THEN
            NEW.default_factor := 3.7;
        END IF;
        NEW.divisor := 270;
    ELSE -- Same day Visitor
        NEW.default_factor := 1;
        NEW.divisor := 365;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_population_defaults"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."set_population_defaults"() IS 'Sets default factor and divisor values for population data based on population type:
- Staff, Residents, Construction Worker: fixed at factor=365, divisor=365
- Tourists/Visit: customizable factor (default 3.7 if not specified), fixed divisor=270
- Same day Visitor: factor=1, divisor=365';



CREATE OR REPLACE FUNCTION "public"."set_region_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF NEW.id IS NULL THEN
        NEW.id := generate_region_id(NEW.name);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_region_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_assets_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_assets_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_gender_baseline_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_gender_baseline_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_population_data_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_population_data_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_service_mapping"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."update_service_mapping"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_timestamp"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_visit_rates_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_visit_rates_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_proposed_percentages"("p_plan_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_total numeric;
    v_count integer;
BEGIN
    -- Check if we have all required care settings
    SELECT COUNT(*)
    INTO v_count
    FROM proposed_care_setting_distribution
    WHERE plan_id = p_plan_id;

    IF v_count != 6 THEN
        RETURN false;
    END IF;

    -- Check if total equals 100%
    SELECT SUM(proposed_percentage)
    INTO v_total
    FROM proposed_care_setting_distribution
    WHERE plan_id = p_plan_id;

    RETURN ROUND(v_total) = 100;
END;
$$;


ALTER FUNCTION "public"."validate_proposed_percentages"("p_plan_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_proposed_percentages"("p_plan_id" "uuid") IS 'Validates that proposed percentages sum to 100%';



CREATE TABLE IF NOT EXISTS "public"."ambulatory_service_center_services_mapping" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "icd_code" "text" NOT NULL,
    "service" "text" NOT NULL,
    "confidence" "text" NOT NULL,
    "mapping_logic" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "ambulatory_service_center_services_mapping_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."ambulatory_service_center_services_mapping" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ambulatory_services_mapping" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "icd_code" "text" NOT NULL,
    "service" "text" NOT NULL,
    "confidence" "text" NOT NULL,
    "mapping_logic" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "ambulatory_services_mapping_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."ambulatory_services_mapping" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."assets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "region_id" "text",
    "asset_id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "type" "text" NOT NULL,
    "owner" "text" NOT NULL,
    "archetype" "text" NOT NULL,
    "population_types" "text"[] NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date",
    "latitude" numeric(10,6) NOT NULL,
    "longitude" numeric(10,6) NOT NULL,
    "gfa" numeric(10,2) NOT NULL,
    "status" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "assets_archetype_check" CHECK (("archetype" = ANY (ARRAY['Family Health Center'::"text", 'Resort'::"text", 'Spoke'::"text", 'Field Hospital'::"text", 'N/A'::"text", 'Advance Health Ceter'::"text", 'Hub'::"text", 'First Aid Point'::"text", 'Clinic'::"text", 'Hospital'::"text"]))),
    CONSTRAINT "assets_gfa_check" CHECK (("gfa" > (0)::numeric)),
    CONSTRAINT "assets_owner_check" CHECK (("owner" = ANY (ARRAY['Neom'::"text", 'MoD'::"text", 'Construction Camp'::"text", 'AlBassam'::"text", 'Nessma'::"text", 'Tamasuk'::"text", 'Alfanar'::"text", 'Almutlaq'::"text", 'MoH'::"text"]))),
    CONSTRAINT "assets_start_date_check" CHECK (("start_date" >= '2017-01-01'::"date")),
    CONSTRAINT "assets_status_check" CHECK (("status" = ANY (ARRAY['Design'::"text", 'Planning'::"text", 'Operational'::"text", 'Closed'::"text", 'Not Started'::"text", 'Partially Operational'::"text"]))),
    CONSTRAINT "assets_type_check" CHECK (("type" = ANY (ARRAY['Permanent'::"text", 'Temporary'::"text", 'PPP'::"text", 'MoH'::"text"]))),
    CONSTRAINT "valid_dates" CHECK ((("end_date" IS NULL) OR ("end_date" >= "start_date"))),
    CONSTRAINT "valid_population_types" CHECK ((("array_length"("population_types", 1) > 0) AND ("array_length"("population_types", 1) <= 4) AND ("population_types" <@ ARRAY['Residents'::"text", 'Staff'::"text", 'Visitors/Tourists'::"text", 'Construction Workers'::"text"])))
);


ALTER TABLE "public"."assets" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."available_days_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "care_setting" "text" NOT NULL,
    "working_days_per_week" integer NOT NULL,
    "working_weeks_per_year" integer NOT NULL,
    "available_days_per_year" integer NOT NULL,
    "source" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "available_days_settings_available_days_per_year_check" CHECK ((("available_days_per_year" >= 1) AND ("available_days_per_year" <= 366))),
    CONSTRAINT "available_days_settings_working_days_per_week_check" CHECK ((("working_days_per_week" >= 1) AND ("working_days_per_week" <= 7))),
    CONSTRAINT "available_days_settings_working_weeks_per_year_check" CHECK ((("working_weeks_per_year" >= 1) AND ("working_weeks_per_year" <= 52)))
);


ALTER TABLE "public"."available_days_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."planning_family_code" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "care_setting" "text" NOT NULL,
    "icd_family" "text" NOT NULL,
    "activity" numeric(20,2) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "service" "text" NOT NULL,
    CONSTRAINT "planning_family_code_care_setting_check" CHECK (("care_setting" = ANY (ARRAY['HOME'::"text", 'HEALTH STATION'::"text", 'AMBULATORY SERVICE CENTER'::"text", 'SPECIALTY CARE CENTER'::"text", 'EXTENDED CARE FACILITY'::"text", 'HOSPITAL'::"text"]))),
    CONSTRAINT "planning_family_code_systems_of_care_check" CHECK (("systems_of_care" = ANY (ARRAY['Planned care'::"text", 'Unplanned care'::"text", 'Wellness and longevity'::"text", 'Children and young people'::"text", 'Chronic conditions'::"text", 'Complex, multi-morbid'::"text", 'Palliative care and support'::"text"])))
);


ALTER TABLE "public"."planning_family_code" OWNER TO "postgres";


COMMENT ON TABLE "public"."planning_family_code" IS 'Stores planning code families for healthcare systems';



COMMENT ON COLUMN "public"."planning_family_code"."systems_of_care" IS 'The system of care category';



COMMENT ON COLUMN "public"."planning_family_code"."care_setting" IS 'The care setting type';



COMMENT ON COLUMN "public"."planning_family_code"."icd_family" IS 'ICD family code';



COMMENT ON COLUMN "public"."planning_family_code"."activity" IS 'The associated activity value';



COMMENT ON COLUMN "public"."planning_family_code"."service" IS 'The mapped healthcare service based on care setting and ICD code';



CREATE OR REPLACE VIEW "public"."care_setting_activity_details" AS
 SELECT "planning_family_code"."care_setting",
    "planning_family_code"."service",
    "planning_family_code"."systems_of_care",
    "count"(*) AS "code_count",
    "sum"("planning_family_code"."activity") AS "total_activity",
    "round"("avg"("planning_family_code"."activity"), 2) AS "avg_activity_per_code"
   FROM "public"."planning_family_code"
  GROUP BY "planning_family_code"."care_setting", "planning_family_code"."service", "planning_family_code"."systems_of_care"
  ORDER BY ("sum"("planning_family_code"."activity")) DESC;


ALTER TABLE "public"."care_setting_activity_details" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."care_setting_activity_summary" AS
 WITH "total_activity" AS (
         SELECT "sum"("planning_family_code_1"."activity") AS "total"
           FROM "public"."planning_family_code" "planning_family_code_1"
        )
 SELECT "planning_family_code"."care_setting",
    "sum"("planning_family_code"."activity") AS "total_activity",
    "round"((("sum"("planning_family_code"."activity") * 100.0) / "total_activity"."total"), 2) AS "percentage"
   FROM "public"."planning_family_code",
    "total_activity"
  GROUP BY "planning_family_code"."care_setting", "total_activity"."total"
  ORDER BY ("round"((("sum"("planning_family_code"."activity") * 100.0) / "total_activity"."total"), 2)) DESC;


ALTER TABLE "public"."care_setting_activity_summary" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."encounters" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "care setting" "text" NOT NULL,
    "system of care" "text" NOT NULL,
    "icd family code" "text" NOT NULL,
    "number of encounters" numeric DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "service" "text",
    "confidence" "text",
    "mapping logic" "text",
    CONSTRAINT "encounters_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."encounters" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."care_setting_optimization" AS
 WITH "current_stats" AS (
         SELECT
                CASE "encounters"."care setting"
                    WHEN 'HEALTH STATION'::"text" THEN 'Health Station'::"text"
                    WHEN 'HOME'::"text" THEN 'Home'::"text"
                    WHEN 'AMBULATORY SERVICE CENTER'::"text" THEN 'Ambulatory Service Center'::"text"
                    WHEN 'SPECIALTY CARE CENTER'::"text" THEN 'Specialty Care Center'::"text"
                    WHEN 'EXTENDED CARE FACILITY'::"text" THEN 'Extended Care Facility'::"text"
                    WHEN 'HOSPITAL'::"text" THEN 'Hospital'::"text"
                    ELSE "encounters"."care setting"
                END AS "care_setting",
            "floor"("sum"("encounters"."number of encounters")) AS "current_encounters",
            "floor"((("sum"("encounters"."number of encounters") * 100.0) / ( SELECT "sum"("encounters_1"."number of encounters") AS "sum"
                   FROM "public"."encounters" "encounters_1"))) AS "current_percentage",
            "array_agg"(DISTINCT "encounters"."icd family code") AS "icd_codes"
           FROM "public"."encounters"
          GROUP BY "encounters"."care setting"
        ), "optimization_potential" AS (
         SELECT "current_stats"."care_setting",
            "current_stats"."current_encounters",
            "current_stats"."current_percentage",
                CASE "current_stats"."care_setting"
                    WHEN 'Home'::"text" THEN (0)::numeric
                    WHEN 'Health Station'::"text" THEN "floor"(("current_stats"."current_encounters" * 0.15))
                    WHEN 'Ambulatory Service Center'::"text" THEN "floor"(("current_stats"."current_encounters" * 0.25))
                    WHEN 'Specialty Care Center'::"text" THEN "floor"(("current_stats"."current_encounters" * 0.10))
                    WHEN 'Extended Care Facility'::"text" THEN "floor"(("current_stats"."current_encounters" * 0.05))
                    WHEN 'Hospital'::"text" THEN "floor"(("current_stats"."current_encounters" * 0.05))
                    ELSE (0)::numeric
                END AS "shift_potential",
                CASE "current_stats"."care_setting"
                    WHEN 'Home'::"text" THEN 'Already optimal setting'::"text"
                    WHEN 'Health Station'::"text" THEN 'Potential for home-based care through remote monitoring and telehealth'::"text"
                    WHEN 'Ambulatory Service Center'::"text" THEN 'Opportunity for care delivery in home or health station settings with proper support'::"text"
                    WHEN 'Specialty Care Center'::"text" THEN 'Some cases manageable in primary care settings with specialist oversight'::"text"
                    WHEN 'Extended Care Facility'::"text" THEN 'Select cases suitable for home care with support'::"text"
                    WHEN 'Hospital'::"text" THEN 'Some cases manageable in lower acuity settings with proper support'::"text"
                    ELSE 'No specific optimization identified'::"text"
                END AS "optimization_strategy"
           FROM "current_stats"
        )
 SELECT "optimization_potential"."care_setting",
    "optimization_potential"."current_encounters",
    "optimization_potential"."current_percentage",
    "optimization_potential"."shift_potential",
        CASE
            WHEN ("optimization_potential"."current_encounters" > (0)::numeric) THEN "floor"((("optimization_potential"."shift_potential" / "optimization_potential"."current_encounters") * (100)::numeric))
            ELSE (0)::numeric
        END AS "potential_shift_percentage",
    "optimization_potential"."optimization_strategy"
   FROM "optimization_potential"
  ORDER BY
        CASE "optimization_potential"."care_setting"
            WHEN 'Home'::"text" THEN 1
            WHEN 'Health Station'::"text" THEN 2
            WHEN 'Ambulatory Service Center'::"text" THEN 3
            WHEN 'Specialty Care Center'::"text" THEN 4
            WHEN 'Extended Care Facility'::"text" THEN 5
            WHEN 'Hospital'::"text" THEN 6
            ELSE 7
        END;


ALTER TABLE "public"."care_setting_optimization" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."care_setting_optimization_data" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "care_setting" "text" NOT NULL,
    "current_encounters" integer NOT NULL,
    "current_percentage" integer NOT NULL,
    "shift_potential" integer NOT NULL,
    "shift_direction" "text" NOT NULL,
    "potential_shift_percentage" integer NOT NULL,
    "proposed_percentage" integer NOT NULL,
    "potential_encounters_change" integer NOT NULL,
    "optimization_strategy" "text" NOT NULL,
    "incoming_shifts" "jsonb",
    "outgoing_shifts" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."care_setting_optimization_data" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."care_settings_encounters" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "care_setting" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "icd_family_code" "text" NOT NULL,
    "encounters" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."care_settings_encounters" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."dc_plans" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "population" integer NOT NULL,
    "date" "date" NOT NULL,
    "capacity_data" "jsonb" NOT NULL,
    "activity_data" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "dc_plans_population_check" CHECK (("population" > 0))
);


ALTER TABLE "public"."dc_plans" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."encounters_statistics" AS
 WITH "total_encounters" AS (
         SELECT "floor"("sum"("encounters"."number of encounters")) AS "total"
           FROM "public"."encounters"
        ), "stats" AS (
         SELECT
                CASE "encounters"."care setting"
                    WHEN 'HEALTH STATION'::"text" THEN 'Health Station'::"text"
                    WHEN 'HOME'::"text" THEN 'Home'::"text"
                    WHEN 'AMBULATORY SERVICE CENTER'::"text" THEN 'Ambulatory Service Center'::"text"
                    WHEN 'SPECIALTY CARE CENTER'::"text" THEN 'Specialty Care Center'::"text"
                    WHEN 'EXTENDED CARE FACILITY'::"text" THEN 'Extended Care Facility'::"text"
                    WHEN 'HOSPITAL'::"text" THEN 'Hospital'::"text"
                    ELSE "encounters"."care setting"
                END AS "care_setting",
            "floor"(("count"(*))::double precision) AS "total_records",
            "floor"("sum"("encounters"."number of encounters")) AS "total_encounter_count",
            "floor"(("count"(DISTINCT "encounters"."icd family code"))::double precision) AS "unique_icd_codes"
           FROM "public"."encounters"
          GROUP BY "encounters"."care setting"
        )
 SELECT "stats"."care_setting",
    "stats"."total_records" AS "record_count",
    "stats"."total_encounter_count" AS "encounter_count",
    "stats"."unique_icd_codes" AS "icd_code_count",
    "floor"((("stats"."total_encounter_count" / "t"."total") * (100)::numeric)) AS "encounter_percentage"
   FROM "stats",
    "total_encounters" "t"
  ORDER BY "stats"."total_encounter_count" DESC;


ALTER TABLE "public"."encounters_statistics" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."extended_care_facility_services_mapping" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "icd_code" "text" NOT NULL,
    "service" "text" NOT NULL,
    "confidence" "text" NOT NULL,
    "mapping_logic" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "extended_care_facility_services_mapping_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."extended_care_facility_services_mapping" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."extended_services_mapping" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "icd_code" "text" NOT NULL,
    "service" "text" NOT NULL,
    "confidence" "text" NOT NULL,
    "mapping_logic" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "extended_services_mapping_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."extended_services_mapping" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."gender_distribution_baseline" (
    "id" integer NOT NULL,
    "male_data" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."gender_distribution_baseline" OWNER TO "postgres";


COMMENT ON TABLE "public"."gender_distribution_baseline" IS 'Stores baseline data for gender distribution across age groups';



COMMENT ON COLUMN "public"."gender_distribution_baseline"."male_data" IS 'JSON array containing male population percentages by age group and year';



CREATE TABLE IF NOT EXISTS "public"."health_station_services_mapping" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "icd_code" "text" NOT NULL,
    "service" "text" NOT NULL,
    "confidence" "text" NOT NULL,
    "mapping_logic" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "health_station_services_mapping_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."health_station_services_mapping" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."home_services_mapping" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "icd_code" "text" NOT NULL,
    "service" "text" NOT NULL,
    "confidence" "text" NOT NULL,
    "mapping_logic" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "home_services_mapping_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."home_services_mapping" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."hospital_services_mapping" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "icd_code" "text" NOT NULL,
    "service" "text" NOT NULL,
    "confidence" "text" NOT NULL,
    "mapping_logic" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "hospital_services_mapping_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."hospital_services_mapping" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."icd_code_analysis" AS
 SELECT "encounters"."icd family code" AS "icd_family_code",
    "count"(*) AS "record_count",
    "sum"("encounters"."number of encounters") AS "total_encounters",
    "count"(DISTINCT "encounters"."care setting") AS "unique_settings",
    "count"(DISTINCT "encounters"."system of care") AS "unique_systems",
    "array_agg"(DISTINCT "encounters"."system of care") AS "systems_of_care"
   FROM "public"."encounters"
  GROUP BY "encounters"."icd family code"
  ORDER BY ("sum"("encounters"."number of encounters")) DESC;


ALTER TABLE "public"."icd_code_analysis" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."specialty_care_center_services_mapping" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "icd_code" "text" NOT NULL,
    "service" "text" NOT NULL,
    "confidence" "text" NOT NULL,
    "mapping_logic" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "specialty_care_center_services_mapping_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."specialty_care_center_services_mapping" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."icd_severity_analysis" AS
 WITH "all_mappings" AS (
         SELECT "home_services_mapping"."icd_code",
            "home_services_mapping"."systems_of_care"
           FROM "public"."home_services_mapping"
        UNION ALL
         SELECT "health_station_services_mapping"."icd_code",
            "health_station_services_mapping"."systems_of_care"
           FROM "public"."health_station_services_mapping"
        UNION ALL
         SELECT "ambulatory_service_center_services_mapping"."icd_code",
            "ambulatory_service_center_services_mapping"."systems_of_care"
           FROM "public"."ambulatory_service_center_services_mapping"
        UNION ALL
         SELECT "specialty_care_center_services_mapping"."icd_code",
            "specialty_care_center_services_mapping"."systems_of_care"
           FROM "public"."specialty_care_center_services_mapping"
        UNION ALL
         SELECT "extended_care_facility_services_mapping"."icd_code",
            "extended_care_facility_services_mapping"."systems_of_care"
           FROM "public"."extended_care_facility_services_mapping"
        UNION ALL
         SELECT "hospital_services_mapping"."icd_code",
            "hospital_services_mapping"."systems_of_care"
           FROM "public"."hospital_services_mapping"
        ), "severity_categories" AS (
         SELECT "left"("all_mappings"."icd_code", 1) AS "icd_category",
                CASE
                    WHEN ("left"("all_mappings"."icd_code", 1) = 'Z'::"text") THEN 'Low'::"text"
                    WHEN ("left"("all_mappings"."icd_code", 1) = ANY (ARRAY['F'::"text", 'L'::"text", 'M'::"text", 'R'::"text"])) THEN 'Low-Medium'::"text"
                    WHEN ("left"("all_mappings"."icd_code", 1) = ANY (ARRAY['E'::"text", 'G'::"text", 'H'::"text", 'J'::"text", 'K'::"text", 'N'::"text"])) THEN 'Medium'::"text"
                    WHEN ("left"("all_mappings"."icd_code", 1) = ANY (ARRAY['A'::"text", 'B'::"text", 'C'::"text", 'D'::"text", 'I'::"text"])) THEN 'High'::"text"
                    WHEN ("left"("all_mappings"."icd_code", 1) = ANY (ARRAY['S'::"text", 'T'::"text"])) THEN 'Very High'::"text"
                    ELSE 'Medium'::"text"
                END AS "severity_level",
            "count"(*) AS "code_count"
           FROM "all_mappings"
          GROUP BY ("left"("all_mappings"."icd_code", 1))
        )
 SELECT "severity_categories"."severity_level",
    "count"(*) AS "total_codes",
    "array_agg"(DISTINCT "severity_categories"."icd_category") AS "icd_categories",
    "round"(((("count"(*))::numeric / (( SELECT "count"(*) AS "count"
           FROM "severity_categories" "severity_categories_1"))::numeric) * (100)::numeric), 1) AS "percentage"
   FROM "severity_categories"
  GROUP BY "severity_categories"."severity_level"
  ORDER BY
        CASE "severity_categories"."severity_level"
            WHEN 'Low'::"text" THEN 1
            WHEN 'Low-Medium'::"text" THEN 2
            WHEN 'Medium'::"text" THEN 3
            WHEN 'High'::"text" THEN 4
            WHEN 'Very High'::"text" THEN 5
            ELSE NULL::integer
        END;


ALTER TABLE "public"."icd_severity_analysis" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."map_icons" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "url" "text" NOT NULL,
    "icon_type" "public"."icon_type" NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "storage_path" "text",
    "mime_type" "text"
);


ALTER TABLE "public"."map_icons" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."mapping_statistics" AS
 WITH "stats" AS (
         SELECT "encounters"."care setting",
            "count"(*) AS "total_records",
            "count"("encounters"."service") AS "mapped_records",
            ("count"(*) - "count"("encounters"."service")) AS "unmapped_records",
            "round"(((("count"("encounters"."service"))::numeric / ("count"(*))::numeric) * (100)::numeric), 2) AS "mapping_percentage"
           FROM "public"."encounters"
          GROUP BY "encounters"."care setting"
        )
 SELECT "stats"."care setting",
    "stats"."total_records",
    "stats"."mapped_records",
    "stats"."unmapped_records",
    ("stats"."mapping_percentage" || '%'::"text") AS "mapping_percentage"
   FROM "stats"
  ORDER BY "stats"."care setting";


ALTER TABLE "public"."mapping_statistics" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."occupancy_rates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "care_setting" "text" NOT NULL,
    "inperson_rate" numeric(5,4) NOT NULL,
    "virtual_rate" numeric(5,4),
    "source" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "occupancy_rates_inperson_rate_check" CHECK ((("inperson_rate" >= (0)::numeric) AND ("inperson_rate" <= (1)::numeric))),
    CONSTRAINT "occupancy_rates_virtual_rate_check" CHECK ((("virtual_rate" >= (0)::numeric) AND ("virtual_rate" <= (1)::numeric)))
);


ALTER TABLE "public"."occupancy_rates" OWNER TO "postgres";


COMMENT ON TABLE "public"."occupancy_rates" IS 'Stores occupancy rates as decimal values between 0 and 1 (e.g., 0.7 = 70%)';



COMMENT ON COLUMN "public"."occupancy_rates"."inperson_rate" IS 'In-person occupancy rate stored as decimal (0-1)';



COMMENT ON COLUMN "public"."occupancy_rates"."virtual_rate" IS 'Virtual occupancy rate stored as decimal (0-1), NULL if not applicable';



CREATE TABLE IF NOT EXISTS "public"."planning_code_sections" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "care_setting" "text" NOT NULL,
    "icd_sections" "text" NOT NULL,
    "activity" numeric(20,2) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "planning_code_sections_care_setting_check" CHECK (("care_setting" = ANY (ARRAY['HOME'::"text", 'HEALTH STATION'::"text", 'AMBULATORY SERVICE CENTER'::"text", 'SPECIALTY CARE CENTER'::"text", 'EXTENDED CARE FACILITY'::"text", 'HOSPITAL'::"text"]))),
    CONSTRAINT "planning_code_sections_systems_of_care_check" CHECK (("systems_of_care" = ANY (ARRAY['Planned care'::"text", 'Unplanned care'::"text", 'Wellness and longevity'::"text", 'Children and young people'::"text", 'Chronic conditions'::"text", 'Complex, multi-morbid'::"text", 'Palliative care and support'::"text"])))
);


ALTER TABLE "public"."planning_code_sections" OWNER TO "postgres";


COMMENT ON TABLE "public"."planning_code_sections" IS 'Stores planning code sections for healthcare systems';



COMMENT ON COLUMN "public"."planning_code_sections"."systems_of_care" IS 'The system of care category';



COMMENT ON COLUMN "public"."planning_code_sections"."care_setting" IS 'The care setting type';



COMMENT ON COLUMN "public"."planning_code_sections"."icd_sections" IS 'ICD code section in format like Z00-Z13';



COMMENT ON COLUMN "public"."planning_code_sections"."activity" IS 'The associated activity value';



CREATE TABLE IF NOT EXISTS "public"."planning_code_sections_staging" (
    "systems_of_care" "text" NOT NULL,
    "care_setting" "text" NOT NULL,
    "icd_sections" "text" NOT NULL,
    "activity" "text" NOT NULL
);


ALTER TABLE "public"."planning_code_sections_staging" OWNER TO "postgres";


COMMENT ON TABLE "public"."planning_code_sections_staging" IS 'Temporary staging table for loading planning code sections data';



CREATE OR REPLACE VIEW "public"."planning_service_mapping_analysis" AS
 WITH "mapping_stats" AS (
         SELECT "planning_family_code"."care_setting",
            "count"(*) AS "total_records",
            "count"("planning_family_code"."service") AS "mapped_records",
            ("count"(*) - "count"("planning_family_code"."service")) AS "unmapped_records",
            "round"(((("count"("planning_family_code"."service"))::numeric / ("count"(*))::numeric) * (100)::numeric), 2) AS "mapping_percentage"
           FROM "public"."planning_family_code"
          GROUP BY "planning_family_code"."care_setting"
        )
 SELECT "mapping_stats"."care_setting",
    "mapping_stats"."total_records",
    "mapping_stats"."mapped_records",
    "mapping_stats"."unmapped_records",
    ("mapping_stats"."mapping_percentage" || '%'::"text") AS "mapping_percentage"
   FROM "mapping_stats"
  ORDER BY ("mapping_stats"."mapping_percentage" || '%'::"text") DESC;


ALTER TABLE "public"."planning_service_mapping_analysis" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."population_data" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "region_id" "text",
    "population_type" "text" NOT NULL,
    "default_factor" numeric NOT NULL,
    "year_2025" integer,
    "year_2026" integer,
    "year_2027" integer,
    "year_2028" integer,
    "year_2029" integer,
    "year_2030" integer,
    "year_2031" integer,
    "year_2032" integer,
    "year_2033" integer,
    "year_2034" integer,
    "year_2035" integer,
    "year_2036" integer,
    "year_2037" integer,
    "year_2038" integer,
    "year_2039" integer,
    "year_2040" integer,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "divisor" integer DEFAULT 365 NOT NULL,
    CONSTRAINT "population_data_population_type_check" CHECK (("population_type" = ANY (ARRAY['Staff'::"text", 'Residents'::"text", 'Tourists/Visit'::"text", 'Same day Visitor'::"text", 'Construction Worker'::"text"]))),
    CONSTRAINT "population_type_rules" CHECK (((("population_type" = 'Staff'::"text") AND ("default_factor" = (365)::numeric) AND ("divisor" = 365)) OR (("population_type" = 'Residents'::"text") AND ("default_factor" = (365)::numeric) AND ("divisor" = 365)) OR (("population_type" = 'Construction Worker'::"text") AND ("default_factor" = (365)::numeric) AND ("divisor" = 365)) OR (("population_type" = 'Tourists/Visit'::"text") AND ("divisor" = 270) AND ("default_factor" > (0)::numeric)) OR (("population_type" = 'Same day Visitor'::"text") AND ("default_factor" = (1)::numeric) AND ("divisor" = 365))))
);


ALTER TABLE "public"."population_data" OWNER TO "postgres";


COMMENT ON TABLE "public"."population_data" IS 'Primary table for storing population data. Population summary functionality has been removed in favor of direct calculations.';



COMMENT ON COLUMN "public"."population_data"."region_id" IS 'Reference to the region this population data belongs to';



COMMENT ON COLUMN "public"."population_data"."population_type" IS 'Type of population (Staff, Residents, etc.)';



COMMENT ON COLUMN "public"."population_data"."default_factor" IS 'Default factor used for population calculations';



COMMENT ON CONSTRAINT "population_type_rules" ON "public"."population_data" IS 'Enforces population type rules:
- Staff: factor=365, divisor=365
- Residents: factor=365, divisor=365
- Construction Worker: factor=365, divisor=365
- Tourists/Visit: divisor=270, factor>0 (customizable)
- Same day Visitor: factor=1, divisor=365';



CREATE TABLE IF NOT EXISTS "public"."primary_care_capacity" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "service" "text" NOT NULL,
    "total_minutes_per_year" integer NOT NULL,
    "total_slots_per_year" integer NOT NULL,
    "average_visit_duration" numeric(10,2) NOT NULL,
    "new_visits_per_year" integer NOT NULL,
    "follow_up_visits_per_year" integer NOT NULL,
    "slots_per_day" integer NOT NULL,
    "year" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."primary_care_capacity" OWNER TO "postgres";


COMMENT ON TABLE "public"."primary_care_capacity" IS 'Stores capacity calculations for primary care services';



CREATE TABLE IF NOT EXISTS "public"."primary_care_visit_times" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "care_setting" "text" DEFAULT 'Primary Care'::"text" NOT NULL,
    "reason_for_visit" "text" NOT NULL,
    "new_visit_duration" integer NOT NULL,
    "follow_up_visit_duration" integer NOT NULL,
    "percent_new_visits" integer NOT NULL,
    "average_visit_duration" numeric GENERATED ALWAYS AS ((((("new_visit_duration" * "percent_new_visits") + ("follow_up_visit_duration" * (100 - "percent_new_visits"))))::numeric / 100.0)) STORED,
    "source" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "primary_care_visit_times_follow_up_visit_duration_check" CHECK (("follow_up_visit_duration" > 0)),
    CONSTRAINT "primary_care_visit_times_new_visit_duration_check" CHECK (("new_visit_duration" > 0)),
    CONSTRAINT "primary_care_visit_times_percent_new_visits_check" CHECK ((("percent_new_visits" >= 0) AND ("percent_new_visits" <= 100)))
);


ALTER TABLE "public"."primary_care_visit_times" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."proposed_care_setting_distribution" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "plan_id" "uuid",
    "care_setting" "text" NOT NULL,
    "current_percentage" numeric(5,2) NOT NULL,
    "proposed_percentage" numeric(5,2) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "proposed_care_setting_distribution_care_setting_check" CHECK (("care_setting" = ANY (ARRAY['HOME'::"text", 'HEALTH STATION'::"text", 'AMBULATORY SERVICE CENTER'::"text", 'SPECIALTY CARE CENTER'::"text", 'EXTENDED CARE FACILITY'::"text", 'HOSPITAL'::"text"]))),
    CONSTRAINT "proposed_care_setting_distribution_current_percentage_check" CHECK ((("current_percentage" >= (0)::numeric) AND ("current_percentage" <= (100)::numeric))),
    CONSTRAINT "proposed_care_setting_distribution_proposed_percentage_check" CHECK ((("proposed_percentage" >= (0)::numeric) AND ("proposed_percentage" <= (100)::numeric)))
);


ALTER TABLE "public"."proposed_care_setting_distribution" OWNER TO "postgres";


COMMENT ON TABLE "public"."proposed_care_setting_distribution" IS 'Stores proposed distribution percentages for care settings';



COMMENT ON COLUMN "public"."proposed_care_setting_distribution"."current_percentage" IS 'Current percentage of activity for this care setting';



COMMENT ON COLUMN "public"."proposed_care_setting_distribution"."proposed_percentage" IS 'Proposed percentage of activity for this care setting (must be multiple of 5)';



CREATE TABLE IF NOT EXISTS "public"."region_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "show_circles" boolean DEFAULT true,
    "circle_transparency" integer DEFAULT 50,
    "circle_border" boolean DEFAULT true,
    "circle_radius_km" integer DEFAULT 10,
    "icon_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "region_settings_circle_radius_km_check" CHECK ((("circle_radius_km" >= 5) AND ("circle_radius_km" <= 100))),
    CONSTRAINT "region_settings_circle_transparency_check" CHECK ((("circle_transparency" >= 0) AND ("circle_transparency" <= 100)))
);


ALTER TABLE "public"."region_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."regions" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "latitude" numeric(10,6) NOT NULL,
    "longitude" numeric(10,6) NOT NULL,
    "status" "public"."region_status" DEFAULT 'active'::"public"."region_status",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_neom" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."regions" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."service_activity_summary" AS
 WITH "total_activity" AS (
         SELECT "sum"("planning_family_code"."activity") AS "total"
           FROM "public"."planning_family_code"
        ), "care_setting_percentages" AS (
         SELECT "planning_family_code"."service",
            "planning_family_code"."care_setting",
            "sum"("planning_family_code"."activity") AS "setting_activity",
            "sum"("sum"("planning_family_code"."activity")) OVER (PARTITION BY "planning_family_code"."service") AS "service_total"
           FROM "public"."planning_family_code"
          GROUP BY "planning_family_code"."service", "planning_family_code"."care_setting"
        ), "service_totals" AS (
         SELECT "planning_family_code"."service",
            "sum"("planning_family_code"."activity") AS "total_activity",
            ( SELECT "total_activity"."total"
                   FROM "total_activity") AS "grand_total"
           FROM "public"."planning_family_code"
          GROUP BY "planning_family_code"."service"
        ), "care_setting_distribution" AS (
         SELECT "care_setting_percentages"."service",
            "jsonb_object_agg"("care_setting_percentages"."care_setting", "round"((("care_setting_percentages"."setting_activity" * 100.0) / "care_setting_percentages"."service_total"), 2)) AS "care_setting_distribution"
           FROM "care_setting_percentages"
          GROUP BY "care_setting_percentages"."service"
        )
 SELECT "st"."service",
    "st"."total_activity",
    "round"((("st"."total_activity" * 100.0) / "st"."grand_total"), 2) AS "percentage",
    "csd"."care_setting_distribution"
   FROM ("service_totals" "st"
     JOIN "care_setting_distribution" "csd" ON (("csd"."service" = "st"."service")))
  ORDER BY "st"."total_activity" DESC;


ALTER TABLE "public"."service_activity_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."service_care_setting_distribution" AS
 WITH "service_totals" AS (
         SELECT "planning_family_code"."service",
            "sum"("planning_family_code"."activity") AS "total_activity"
           FROM "public"."planning_family_code"
          GROUP BY "planning_family_code"."service"
        ), "care_setting_distribution" AS (
         SELECT "pfc"."service",
            "pfc"."care_setting",
            "sum"("pfc"."activity") AS "setting_activity",
            "st"."total_activity"
           FROM ("public"."planning_family_code" "pfc"
             JOIN "service_totals" "st" ON (("st"."service" = "pfc"."service")))
          GROUP BY "pfc"."service", "pfc"."care_setting", "st"."total_activity"
        )
 SELECT "care_setting_distribution"."service",
    "care_setting_distribution"."care_setting",
    "care_setting_distribution"."setting_activity",
    "round"((("care_setting_distribution"."setting_activity" * 100.0) / "care_setting_distribution"."total_activity"), 2) AS "percentage"
   FROM "care_setting_distribution"
  ORDER BY "care_setting_distribution"."service", ("round"((("care_setting_distribution"."setting_activity" * 100.0) / "care_setting_distribution"."total_activity"), 2)) DESC;


ALTER TABLE "public"."service_care_setting_distribution" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."service_icd_analysis" AS
 WITH "service_totals" AS (
         SELECT "planning_family_code"."service",
            "sum"("planning_family_code"."activity") AS "total_service_activity"
           FROM "public"."planning_family_code"
          GROUP BY "planning_family_code"."service"
        ), "icd_activity" AS (
         SELECT "planning_family_code"."service",
            "planning_family_code"."icd_family",
            "sum"("planning_family_code"."activity") AS "total_activity",
            "count"(*) AS "occurrence_count",
            "array_agg"(DISTINCT "planning_family_code"."care_setting") AS "care_settings",
            "array_agg"(DISTINCT "planning_family_code"."systems_of_care") AS "systems_of_care"
           FROM "public"."planning_family_code"
          GROUP BY "planning_family_code"."service", "planning_family_code"."icd_family"
        )
 SELECT "ia"."service",
    "ia"."icd_family",
    "ia"."total_activity",
    "round"((("ia"."total_activity" * 100.0) / "st"."total_service_activity"), 2) AS "percentage_of_service",
    "ia"."occurrence_count",
    "ia"."care_settings",
    "ia"."systems_of_care"
   FROM ("icd_activity" "ia"
     JOIN "service_totals" "st" ON (("st"."service" = "ia"."service")));


ALTER TABLE "public"."service_icd_analysis" OWNER TO "postgres";


COMMENT ON VIEW "public"."service_icd_analysis" IS 'Analyzes ICD code distribution within each service';



CREATE OR REPLACE VIEW "public"."valid_services_view" AS
 SELECT DISTINCT "all_services"."service"
   FROM ( SELECT "home_services_mapping"."service"
           FROM "public"."home_services_mapping"
        UNION ALL
         SELECT "health_station_services_mapping"."service"
           FROM "public"."health_station_services_mapping"
        UNION ALL
         SELECT "ambulatory_service_center_services_mapping"."service"
           FROM "public"."ambulatory_service_center_services_mapping"
        UNION ALL
         SELECT "specialty_care_center_services_mapping"."service"
           FROM "public"."specialty_care_center_services_mapping"
        UNION ALL
         SELECT "extended_care_facility_services_mapping"."service"
           FROM "public"."extended_care_facility_services_mapping"
        UNION ALL
         SELECT "hospital_services_mapping"."service"
           FROM "public"."hospital_services_mapping") "all_services";


ALTER TABLE "public"."valid_services_view" OWNER TO "postgres";


COMMENT ON VIEW "public"."valid_services_view" IS 'View of all valid services from service mapping tables';



CREATE OR REPLACE VIEW "public"."service_mapping_analysis" AS
 WITH "invalid_services" AS (
         SELECT DISTINCT "pfc"."service",
            "pfc"."care_setting",
            "count"(*) AS "occurrence_count",
            "array_agg"(DISTINCT "pfc"."icd_family") AS "example_icd_codes"
           FROM ("public"."planning_family_code" "pfc"
             LEFT JOIN "public"."valid_services_view" "vsv" ON (("vsv"."service" = "pfc"."service")))
          WHERE ("vsv"."service" IS NULL)
          GROUP BY "pfc"."service", "pfc"."care_setting"
        ), "service_stats" AS (
         SELECT "count"(*) AS "total_records",
            "count"(DISTINCT "pfc"."service") AS "unique_services",
            "sum"(
                CASE
                    WHEN ("vsv"."service" IS NULL) THEN 1
                    ELSE 0
                END) AS "invalid_service_records",
            "round"(((("sum"(
                CASE
                    WHEN ("vsv"."service" IS NULL) THEN 1
                    ELSE 0
                END))::numeric / ("count"(*))::numeric) * (100)::numeric), 2) AS "invalid_percentage"
           FROM ("public"."planning_family_code" "pfc"
             LEFT JOIN "public"."valid_services_view" "vsv" ON (("vsv"."service" = "pfc"."service")))
        )
 SELECT 'Summary'::"text" AS "analysis_type",
    "jsonb_build_object"('total_records', "service_stats"."total_records", 'unique_services', "service_stats"."unique_services", 'invalid_records', "service_stats"."invalid_service_records", 'invalid_percentage', ("service_stats"."invalid_percentage" || '%'::"text")) AS "summary_data",
    NULL::"text" AS "service",
    NULL::"text" AS "care_setting",
    NULL::integer AS "occurrence_count",
    NULL::"text"[] AS "example_icd_codes"
   FROM "service_stats"
UNION ALL
 SELECT 'Invalid Service'::"text" AS "analysis_type",
    NULL::"jsonb" AS "summary_data",
    "invalid_services"."service",
    "invalid_services"."care_setting",
    "invalid_services"."occurrence_count",
    "invalid_services"."example_icd_codes"
   FROM "invalid_services"
  ORDER BY 1, 5 DESC NULLS LAST;


ALTER TABLE "public"."service_mapping_analysis" OWNER TO "postgres";


COMMENT ON VIEW "public"."service_mapping_analysis" IS 'Analyzes service mappings in planning_family_code table to identify invalid services';



CREATE TABLE IF NOT EXISTS "public"."specialist_opd_capacity" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "specialty" "text" NOT NULL,
    "total_minutes_per_year" integer NOT NULL,
    "total_slots_per_year" integer NOT NULL,
    "average_visit_duration" numeric(10,2) NOT NULL,
    "new_visits_per_year" integer NOT NULL,
    "follow_up_visits_per_year" integer NOT NULL,
    "slots_per_day" integer NOT NULL,
    "year" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."specialist_opd_capacity" OWNER TO "postgres";


COMMENT ON TABLE "public"."specialist_opd_capacity" IS 'Stores capacity calculations for specialist outpatient services';



CREATE TABLE IF NOT EXISTS "public"."specialist_visit_times" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "care_setting" "text" DEFAULT 'Specialist Outpatient Care'::"text" NOT NULL,
    "reason_for_visit" "text" NOT NULL,
    "new_visit_duration" integer NOT NULL,
    "follow_up_visit_duration" integer NOT NULL,
    "percent_new_visits" integer NOT NULL,
    "source" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "specialist_visit_times_follow_up_visit_duration_check" CHECK (("follow_up_visit_duration" > 0)),
    CONSTRAINT "specialist_visit_times_new_visit_duration_check" CHECK (("new_visit_duration" > 0)),
    CONSTRAINT "specialist_visit_times_percent_new_visits_check" CHECK ((("percent_new_visits" >= 0) AND ("percent_new_visits" <= 100)))
);


ALTER TABLE "public"."specialist_visit_times" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."specialty_care_mapping_stats" AS
 SELECT 'SPECIALTY CARE CENTER'::"text" AS "care_setting",
    "count"(*) AS "total_records",
    "count"("encounters"."service") AS "mapped_records",
    ("count"(*) - "count"("encounters"."service")) AS "unmapped_records",
    ("round"(((("count"("encounters"."service"))::numeric / ("count"(*))::numeric) * (100)::numeric), 2) || '%'::"text") AS "mapping_percentage"
   FROM "public"."encounters"
  WHERE ("encounters"."care setting" = 'SPECIALTY CARE CENTER'::"text");


ALTER TABLE "public"."specialty_care_mapping_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."specialty_occupancy_rates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "care_setting" "text" NOT NULL,
    "specialty" "text" NOT NULL,
    "virtual_rate" numeric(5,4) NOT NULL,
    "inperson_rate" numeric(5,4) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "specialty_occupancy_rates_inperson_rate_check" CHECK ((("inperson_rate" >= (0)::numeric) AND ("inperson_rate" <= (1)::numeric))),
    CONSTRAINT "specialty_occupancy_rates_virtual_rate_check" CHECK ((("virtual_rate" >= (0)::numeric) AND ("virtual_rate" <= (1)::numeric)))
);


ALTER TABLE "public"."specialty_occupancy_rates" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."specialty_services_mapping" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "icd_code" "text" NOT NULL,
    "service" "text" NOT NULL,
    "confidence" "text" NOT NULL,
    "mapping_logic" "text" NOT NULL,
    "systems_of_care" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "specialty_services_mapping_confidence_check" CHECK (("confidence" = ANY (ARRAY['high'::"text", 'medium'::"text", 'low'::"text"])))
);


ALTER TABLE "public"."specialty_services_mapping" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sub_region_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "show_circles" boolean DEFAULT true,
    "circle_transparency" integer DEFAULT 50,
    "circle_border" boolean DEFAULT true,
    "circle_radius_km" integer DEFAULT 5,
    "icon_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "sub_region_settings_circle_radius_km_check" CHECK ((("circle_radius_km" >= 5) AND ("circle_radius_km" <= 100))),
    CONSTRAINT "sub_region_settings_circle_transparency_check" CHECK ((("circle_transparency" >= 0) AND ("circle_transparency" <= 100)))
);


ALTER TABLE "public"."sub_region_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sub_regions" (
    "id" "text" NOT NULL,
    "region_id" "text",
    "name" "text" NOT NULL,
    "latitude" numeric(10,6) NOT NULL,
    "longitude" numeric(10,6) NOT NULL,
    "status" "public"."region_status" DEFAULT 'active'::"public"."region_status",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."sub_regions" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."system_of_care_analysis" AS
 WITH "care_setting_totals" AS (
         SELECT "encounters"."system of care",
            "encounters"."care setting",
            "floor"("sum"("encounters"."number of encounters")) AS "setting_encounters",
            "floor"("sum"("sum"("encounters"."number of encounters")) OVER (PARTITION BY "encounters"."system of care")) AS "total_system_encounters"
           FROM "public"."encounters"
          GROUP BY "encounters"."system of care", "encounters"."care setting"
        )
 SELECT "e"."system of care" AS "system_of_care",
    "floor"(("count"(*))::double precision) AS "record_count",
    "floor"("sum"("e"."number of encounters")) AS "total_encounters",
    "floor"(("count"(DISTINCT "e"."icd family code"))::double precision) AS "unique_icd_codes",
    "jsonb_object_agg"(
        CASE "cs"."care setting"
            WHEN 'HEALTH STATION'::"text" THEN 'Health Station'::"text"
            WHEN 'HOME'::"text" THEN 'Home'::"text"
            WHEN 'AMBULATORY SERVICE CENTER'::"text" THEN 'Ambulatory Service Center'::"text"
            WHEN 'SPECIALTY CARE CENTER'::"text" THEN 'Specialty Care Center'::"text"
            WHEN 'EXTENDED CARE FACILITY'::"text" THEN 'Extended Care Facility'::"text"
            WHEN 'HOSPITAL'::"text" THEN 'Hospital'::"text"
            ELSE "cs"."care setting"
        END, "floor"((("cs"."setting_encounters" / "cs"."total_system_encounters") * (100)::numeric))) AS "care_setting_percentages"
   FROM ("public"."encounters" "e"
     LEFT JOIN "care_setting_totals" "cs" ON ((("e"."system of care" = "cs"."system of care") AND ("e"."care setting" = "cs"."care setting"))))
  GROUP BY "e"."system of care"
  ORDER BY ("floor"("sum"("e"."number of encounters"))) DESC;


ALTER TABLE "public"."system_of_care_analysis" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."table_row_counts" AS
 SELECT 'ambulatory_service_center_services_mapping'::"text" AS "table_name",
    "count"(*) AS "row_count"
   FROM "public"."ambulatory_service_center_services_mapping"
UNION ALL
 SELECT 'extended_care_facility_services_mapping'::"text" AS "table_name",
    "count"(*) AS "row_count"
   FROM "public"."extended_care_facility_services_mapping"
UNION ALL
 SELECT 'specialty_care_center_services_mapping'::"text" AS "table_name",
    "count"(*) AS "row_count"
   FROM "public"."specialty_care_center_services_mapping"
UNION ALL
 SELECT 'health_station_services_mapping'::"text" AS "table_name",
    "count"(*) AS "row_count"
   FROM "public"."health_station_services_mapping"
UNION ALL
 SELECT 'home_services_mapping'::"text" AS "table_name",
    "count"(*) AS "row_count"
   FROM "public"."home_services_mapping"
UNION ALL
 SELECT 'hospital_services_mapping'::"text" AS "table_name",
    "count"(*) AS "row_count"
   FROM "public"."hospital_services_mapping"
UNION ALL
 SELECT 'encounters'::"text" AS "table_name",
    "count"(*) AS "row_count"
   FROM "public"."encounters";


ALTER TABLE "public"."table_row_counts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."test" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."test" OWNER TO "postgres";


ALTER TABLE "public"."test" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."test_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "public"."top_icd_codes_by_service" AS
 WITH "service_totals" AS (
         SELECT "planning_family_code"."service",
            "sum"("planning_family_code"."activity") AS "total_service_activity"
           FROM "public"."planning_family_code"
          GROUP BY "planning_family_code"."service"
        ), "icd_activity" AS (
         SELECT "planning_family_code"."service",
            "planning_family_code"."icd_family",
            "sum"("planning_family_code"."activity") AS "total_activity",
            "count"(*) AS "occurrence_count",
            "array_agg"(DISTINCT "planning_family_code"."care_setting") AS "care_settings",
            "array_agg"(DISTINCT "planning_family_code"."systems_of_care") AS "systems_of_care"
           FROM "public"."planning_family_code"
          GROUP BY "planning_family_code"."service", "planning_family_code"."icd_family"
        )
 SELECT "ia"."service",
    "ia"."icd_family",
    "ia"."total_activity",
    "round"((("ia"."total_activity" * 100.0) / "st"."total_service_activity"), 2) AS "percentage_of_service",
    "ia"."occurrence_count",
    "ia"."care_settings",
    "ia"."systems_of_care",
    "row_number"() OVER (PARTITION BY "ia"."service" ORDER BY "ia"."total_activity" DESC) AS "rank"
   FROM ("icd_activity" "ia"
     JOIN "service_totals" "st" ON (("st"."service" = "ia"."service")));


ALTER TABLE "public"."top_icd_codes_by_service" OWNER TO "postgres";


COMMENT ON VIEW "public"."top_icd_codes_by_service" IS 'Shows top ICD codes for each service ranked by activity';



CREATE TABLE IF NOT EXISTS "public"."visit_rates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "service" "text" NOT NULL,
    "age_group" "text" NOT NULL,
    "assumption_type" "text" NOT NULL,
    "male_rate" numeric NOT NULL,
    "female_rate" numeric NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "visit_rates_assumption_type_check" CHECK (("assumption_type" = ANY (ARRAY['model'::"text", 'enhanced'::"text", 'high_risk'::"text"])))
);


ALTER TABLE "public"."visit_rates" OWNER TO "postgres";


COMMENT ON TABLE "public"."visit_rates" IS 'Stores visit rates for different services by age group and assumption type';



COMMENT ON COLUMN "public"."visit_rates"."service" IS 'The healthcare service';



COMMENT ON COLUMN "public"."visit_rates"."age_group" IS 'The age group for the rate';



COMMENT ON COLUMN "public"."visit_rates"."assumption_type" IS 'The type of assumption (model, enhanced, high_risk)';



COMMENT ON COLUMN "public"."visit_rates"."male_rate" IS 'Visit rate per 1000 for males';



COMMENT ON COLUMN "public"."visit_rates"."female_rate" IS 'Visit rate per 1000 for females';



CREATE TABLE IF NOT EXISTS "public"."working_hours_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "care_setting" "text" NOT NULL,
    "working_hours_per_day" integer NOT NULL,
    "source" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "working_hours_settings_working_hours_per_day_check" CHECK ((("working_hours_per_day" >= 1) AND ("working_hours_per_day" <= 24)))
);


ALTER TABLE "public"."working_hours_settings" OWNER TO "postgres";


ALTER TABLE ONLY "public"."ambulatory_service_center_services_mapping"
    ADD CONSTRAINT "ambulatory_service_center_services_mapping_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ambulatory_services_mapping"
    ADD CONSTRAINT "ambulatory_services_mapping_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assets"
    ADD CONSTRAINT "assets_asset_id_key" UNIQUE ("asset_id");



ALTER TABLE ONLY "public"."assets"
    ADD CONSTRAINT "assets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."available_days_settings"
    ADD CONSTRAINT "available_days_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."care_setting_optimization_data"
    ADD CONSTRAINT "care_setting_optimization_data_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."care_settings_encounters"
    ADD CONSTRAINT "care_settings_encounters_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dc_plans"
    ADD CONSTRAINT "dc_plans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."encounters"
    ADD CONSTRAINT "encounters_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."extended_care_facility_services_mapping"
    ADD CONSTRAINT "extended_care_facility_services_mapping_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."extended_services_mapping"
    ADD CONSTRAINT "extended_services_mapping_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."gender_distribution_baseline"
    ADD CONSTRAINT "gender_distribution_baseline_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."health_station_services_mapping"
    ADD CONSTRAINT "health_station_services_mapping_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."home_services_mapping"
    ADD CONSTRAINT "home_services_mapping_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hospital_services_mapping"
    ADD CONSTRAINT "hospital_services_mapping_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."map_icons"
    ADD CONSTRAINT "map_icons_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."map_settings"
    ADD CONSTRAINT "map_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."occupancy_rates"
    ADD CONSTRAINT "occupancy_rates_care_setting_key" UNIQUE ("care_setting");



ALTER TABLE ONLY "public"."occupancy_rates"
    ADD CONSTRAINT "occupancy_rates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."planning_code_sections"
    ADD CONSTRAINT "planning_code_sections_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."planning_family_code"
    ADD CONSTRAINT "planning_family_code_care_setting_icd_family_key" UNIQUE ("care_setting", "icd_family");



ALTER TABLE ONLY "public"."planning_family_code"
    ADD CONSTRAINT "planning_family_code_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."population_data"
    ADD CONSTRAINT "population_data_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."population_data"
    ADD CONSTRAINT "population_data_region_id_population_type_key" UNIQUE ("region_id", "population_type");



ALTER TABLE ONLY "public"."primary_care_capacity"
    ADD CONSTRAINT "primary_care_capacity_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."primary_care_capacity"
    ADD CONSTRAINT "primary_care_capacity_service_year_key" UNIQUE ("service", "year");



ALTER TABLE ONLY "public"."primary_care_visit_times"
    ADD CONSTRAINT "primary_care_visit_times_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."proposed_care_setting_distribution"
    ADD CONSTRAINT "proposed_care_setting_distribution_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."proposed_care_setting_distribution"
    ADD CONSTRAINT "proposed_care_setting_distribution_plan_id_care_setting_key" UNIQUE ("plan_id", "care_setting");



ALTER TABLE ONLY "public"."region_settings"
    ADD CONSTRAINT "region_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."regions"
    ADD CONSTRAINT "regions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."specialist_opd_capacity"
    ADD CONSTRAINT "specialist_opd_capacity_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."specialist_opd_capacity"
    ADD CONSTRAINT "specialist_opd_capacity_specialty_year_key" UNIQUE ("specialty", "year");



ALTER TABLE ONLY "public"."specialist_visit_times"
    ADD CONSTRAINT "specialist_visit_times_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."specialty_care_center_services_mapping"
    ADD CONSTRAINT "specialty_care_center_services_mapping_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."specialty_occupancy_rates"
    ADD CONSTRAINT "specialty_occupancy_rates_care_setting_specialty_key" UNIQUE ("care_setting", "specialty");



ALTER TABLE ONLY "public"."specialty_occupancy_rates"
    ADD CONSTRAINT "specialty_occupancy_rates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."specialty_services_mapping"
    ADD CONSTRAINT "specialty_services_mapping_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sub_region_settings"
    ADD CONSTRAINT "sub_region_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sub_regions"
    ADD CONSTRAINT "sub_regions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."test"
    ADD CONSTRAINT "test_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."extended_care_facility_services_mapping"
    ADD CONSTRAINT "unique_extended_care_icd_system_constraint" UNIQUE ("icd_code", "systems_of_care");



ALTER TABLE ONLY "public"."ambulatory_service_center_services_mapping"
    ADD CONSTRAINT "unique_icd_system_constraint" UNIQUE ("icd_code", "systems_of_care");



ALTER TABLE ONLY "public"."specialty_care_center_services_mapping"
    ADD CONSTRAINT "unique_specialty_care_icd_system_constraint" UNIQUE ("icd_code", "systems_of_care");



ALTER TABLE ONLY "public"."visit_rates"
    ADD CONSTRAINT "visit_rates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."visit_rates"
    ADD CONSTRAINT "visit_rates_service_age_group_assumption_type_key" UNIQUE ("service", "age_group", "assumption_type");



ALTER TABLE ONLY "public"."working_hours_settings"
    ADD CONSTRAINT "working_hours_settings_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_ambulatory_service_center_icd_system" ON "public"."ambulatory_service_center_services_mapping" USING "btree" ("icd_code", "systems_of_care");



CREATE INDEX "idx_ambulatory_service_center_services_mapping_icd_code" ON "public"."ambulatory_service_center_services_mapping" USING "btree" ("icd_code");



CREATE INDEX "idx_ambulatory_service_center_services_mapping_systems_of_care" ON "public"."ambulatory_service_center_services_mapping" USING "btree" ("systems_of_care");



CREATE INDEX "idx_ambulatory_services_mapping_icd_code" ON "public"."ambulatory_services_mapping" USING "btree" ("icd_code");



CREATE INDEX "idx_assets_archetype" ON "public"."assets" USING "btree" ("archetype");



CREATE INDEX "idx_assets_asset_id" ON "public"."assets" USING "btree" ("asset_id");



CREATE INDEX "idx_assets_region_id" ON "public"."assets" USING "btree" ("region_id");



CREATE INDEX "idx_assets_status" ON "public"."assets" USING "btree" ("status");



CREATE INDEX "idx_assets_type" ON "public"."assets" USING "btree" ("type");



CREATE INDEX "idx_care_settings_encounters_care_setting" ON "public"."care_settings_encounters" USING "btree" ("care_setting");



CREATE INDEX "idx_care_settings_encounters_icd_code" ON "public"."care_settings_encounters" USING "btree" ("icd_family_code");



CREATE INDEX "idx_care_settings_encounters_systems_of_care" ON "public"."care_settings_encounters" USING "btree" ("systems_of_care");



CREATE INDEX "idx_dc_plans_date" ON "public"."dc_plans" USING "btree" ("date");



CREATE INDEX "idx_dc_plans_name" ON "public"."dc_plans" USING "btree" ("name");



CREATE INDEX "idx_encounters_care_setting" ON "public"."encounters" USING "btree" ("care setting");



CREATE INDEX "idx_encounters_composite_analysis" ON "public"."encounters" USING "btree" ("care setting", "system of care", "icd family code");



CREATE INDEX "idx_encounters_confidence" ON "public"."encounters" USING "btree" ("confidence");



CREATE INDEX "idx_encounters_icd_family_code" ON "public"."encounters" USING "btree" ("icd family code");



CREATE INDEX "idx_encounters_id" ON "public"."encounters" USING "btree" ("id");



CREATE INDEX "idx_encounters_number_of_encounters" ON "public"."encounters" USING "btree" ("number of encounters");



CREATE INDEX "idx_encounters_service" ON "public"."encounters" USING "btree" ("service");



CREATE INDEX "idx_encounters_system_of_care" ON "public"."encounters" USING "btree" ("system of care");



CREATE INDEX "idx_extended_care_facility_icd_system" ON "public"."extended_care_facility_services_mapping" USING "btree" ("icd_code", "systems_of_care");



CREATE INDEX "idx_extended_care_facility_services_mapping_icd_code" ON "public"."extended_care_facility_services_mapping" USING "btree" ("icd_code");



CREATE INDEX "idx_extended_care_facility_services_mapping_systems_of_care" ON "public"."extended_care_facility_services_mapping" USING "btree" ("systems_of_care");



CREATE INDEX "idx_extended_services_mapping_icd_code" ON "public"."extended_services_mapping" USING "btree" ("icd_code");



CREATE INDEX "idx_health_station_services_mapping_icd_code" ON "public"."health_station_services_mapping" USING "btree" ("icd_code");



CREATE INDEX "idx_health_station_services_mapping_systems_of_care" ON "public"."health_station_services_mapping" USING "btree" ("systems_of_care");



CREATE INDEX "idx_home_services_mapping_icd_code" ON "public"."home_services_mapping" USING "btree" ("icd_code");



CREATE INDEX "idx_hospital_services_mapping_icd_code" ON "public"."hospital_services_mapping" USING "btree" ("icd_code");



CREATE INDEX "idx_hospital_services_mapping_systems_of_care" ON "public"."hospital_services_mapping" USING "btree" ("systems_of_care");



CREATE INDEX "idx_planning_code_sections_care_setting" ON "public"."planning_code_sections" USING "btree" ("care_setting");



CREATE INDEX "idx_planning_code_sections_systems_of_care" ON "public"."planning_code_sections" USING "btree" ("systems_of_care");



CREATE INDEX "idx_planning_family_code_care_setting" ON "public"."planning_family_code" USING "btree" ("care_setting");



CREATE INDEX "idx_planning_family_code_icd_family" ON "public"."planning_family_code" USING "btree" ("icd_family");



CREATE INDEX "idx_planning_family_code_service" ON "public"."planning_family_code" USING "btree" ("service");



CREATE INDEX "idx_planning_family_code_systems_of_care" ON "public"."planning_family_code" USING "btree" ("systems_of_care");



CREATE INDEX "idx_population_data_population_type" ON "public"."population_data" USING "btree" ("population_type");



CREATE INDEX "idx_population_data_region_id" ON "public"."population_data" USING "btree" ("region_id");



CREATE INDEX "idx_primary_care_capacity_year" ON "public"."primary_care_capacity" USING "btree" ("year");



CREATE INDEX "idx_regions_is_neom" ON "public"."regions" USING "btree" ("is_neom");



CREATE INDEX "idx_regions_status" ON "public"."regions" USING "btree" ("status");



CREATE INDEX "idx_specialist_opd_capacity_year" ON "public"."specialist_opd_capacity" USING "btree" ("year");



CREATE INDEX "idx_specialty_care_center_icd_system" ON "public"."specialty_care_center_services_mapping" USING "btree" ("icd_code", "systems_of_care");



CREATE INDEX "idx_specialty_care_center_services_mapping_icd_code" ON "public"."specialty_care_center_services_mapping" USING "btree" ("icd_code");



CREATE INDEX "idx_specialty_care_center_services_mapping_systems_of_care" ON "public"."specialty_care_center_services_mapping" USING "btree" ("systems_of_care");



CREATE INDEX "idx_specialty_services_mapping_icd_code" ON "public"."specialty_services_mapping" USING "btree" ("icd_code");



CREATE INDEX "idx_sub_regions_status" ON "public"."sub_regions" USING "btree" ("status");



CREATE OR REPLACE TRIGGER "region_inactivation_trigger" AFTER UPDATE OF "status" ON "public"."regions" FOR EACH ROW WHEN ((("old"."status" = 'active'::"public"."region_status") AND ("new"."status" = 'inactive'::"public"."region_status"))) EXECUTE FUNCTION "public"."inactivate_region_cascade"();



CREATE OR REPLACE TRIGGER "set_planning_family_service_trigger" BEFORE INSERT ON "public"."planning_family_code" FOR EACH ROW EXECUTE FUNCTION "public"."set_planning_family_service"();



CREATE OR REPLACE TRIGGER "set_population_defaults_trigger" BEFORE INSERT ON "public"."population_data" FOR EACH ROW EXECUTE FUNCTION "public"."set_population_defaults"();



CREATE OR REPLACE TRIGGER "set_region_id_trigger" BEFORE INSERT ON "public"."regions" FOR EACH ROW EXECUTE FUNCTION "public"."set_region_id"();



CREATE OR REPLACE TRIGGER "update_assets_updated_at" BEFORE UPDATE ON "public"."assets" FOR EACH ROW EXECUTE FUNCTION "public"."update_assets_updated_at"();



CREATE OR REPLACE TRIGGER "update_available_days_settings_updated_at" BEFORE UPDATE ON "public"."available_days_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_dc_plans_updated_at" BEFORE UPDATE ON "public"."dc_plans" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_gender_baseline_updated_at" BEFORE UPDATE ON "public"."gender_distribution_baseline" FOR EACH ROW EXECUTE FUNCTION "public"."update_gender_baseline_updated_at"();



CREATE OR REPLACE TRIGGER "update_occupancy_rates_updated_at" BEFORE UPDATE ON "public"."occupancy_rates" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_planning_code_sections_updated_at" BEFORE UPDATE ON "public"."planning_code_sections" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_planning_family_code_updated_at" BEFORE UPDATE ON "public"."planning_family_code" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_population_data_updated_at" BEFORE UPDATE ON "public"."population_data" FOR EACH ROW EXECUTE FUNCTION "public"."update_population_data_updated_at"();



CREATE OR REPLACE TRIGGER "update_primary_care_capacity_updated_at" BEFORE UPDATE ON "public"."primary_care_capacity" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_primary_care_visit_times_updated_at" BEFORE UPDATE ON "public"."primary_care_visit_times" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_proposed_care_setting_distribution_updated_at" BEFORE UPDATE ON "public"."proposed_care_setting_distribution" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_regions_updated_at" BEFORE UPDATE ON "public"."regions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_service_mapping_trigger" BEFORE INSERT OR UPDATE ON "public"."encounters" FOR EACH ROW EXECUTE FUNCTION "public"."update_service_mapping"();



CREATE OR REPLACE TRIGGER "update_specialist_opd_capacity_updated_at" BEFORE UPDATE ON "public"."specialist_opd_capacity" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_specialist_visit_times_updated_at" BEFORE UPDATE ON "public"."specialist_visit_times" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_specialty_occupancy_rates_updated_at" BEFORE UPDATE ON "public"."specialty_occupancy_rates" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "update_sub_regions_updated_at" BEFORE UPDATE ON "public"."sub_regions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_visit_rates_updated_at" BEFORE UPDATE ON "public"."visit_rates" FOR EACH ROW EXECUTE FUNCTION "public"."update_visit_rates_updated_at"();



CREATE OR REPLACE TRIGGER "update_working_hours_settings_updated_at" BEFORE UPDATE ON "public"."working_hours_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_timestamp"();



CREATE OR REPLACE TRIGGER "validate_proposed_percentages_trigger" AFTER INSERT OR UPDATE ON "public"."proposed_care_setting_distribution" FOR EACH ROW EXECUTE FUNCTION "public"."check_proposed_percentages"();



ALTER TABLE ONLY "public"."assets"
    ADD CONSTRAINT "assets_region_id_fkey" FOREIGN KEY ("region_id") REFERENCES "public"."regions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."population_data"
    ADD CONSTRAINT "population_data_region_id_fkey" FOREIGN KEY ("region_id") REFERENCES "public"."regions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."proposed_care_setting_distribution"
    ADD CONSTRAINT "proposed_care_setting_distribution_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."dc_plans"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."region_settings"
    ADD CONSTRAINT "region_settings_icon_id_fkey" FOREIGN KEY ("icon_id") REFERENCES "public"."map_icons"("id");



ALTER TABLE ONLY "public"."sub_region_settings"
    ADD CONSTRAINT "sub_region_settings_icon_id_fkey" FOREIGN KEY ("icon_id") REFERENCES "public"."map_icons"("id");



ALTER TABLE ONLY "public"."sub_regions"
    ADD CONSTRAINT "sub_regions_region_id_fkey" FOREIGN KEY ("region_id") REFERENCES "public"."regions"("id") ON DELETE CASCADE;



CREATE POLICY "Allow public read access on ambulatory_service_center_services_" ON "public"."ambulatory_service_center_services_mapping" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on ambulatory_services_mapping" ON "public"."ambulatory_services_mapping" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on care_setting_optimization_data" ON "public"."care_setting_optimization_data" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on care_settings_encounters" ON "public"."care_settings_encounters" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on encounters" ON "public"."encounters" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on extended_care_facility_services_map" ON "public"."extended_care_facility_services_mapping" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on extended_services_mapping" ON "public"."extended_services_mapping" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on health_station_services_mapping" ON "public"."health_station_services_mapping" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on home_services_mapping" ON "public"."home_services_mapping" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on hospital_services_mapping" ON "public"."hospital_services_mapping" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on specialty_care_center_services_mapp" ON "public"."specialty_care_center_services_mapping" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on specialty_services_mapping" ON "public"."specialty_services_mapping" FOR SELECT USING (true);



CREATE POLICY "Enable all access for all users on available_days_settings" ON "public"."available_days_settings" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on dc_plans" ON "public"."dc_plans" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on occupancy_rates" ON "public"."occupancy_rates" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on planning_code_sections" ON "public"."planning_code_sections" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on planning_code_sections_stagi" ON "public"."planning_code_sections_staging" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on planning_family_code" ON "public"."planning_family_code" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on primary_care_capacity" ON "public"."primary_care_capacity" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on primary_care_visit_times" ON "public"."primary_care_visit_times" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on proposed_care_setting_distri" ON "public"."proposed_care_setting_distribution" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on specialist_opd_capacity" ON "public"."specialist_opd_capacity" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on specialist_visit_times" ON "public"."specialist_visit_times" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on specialty_occupancy_rates" ON "public"."specialty_occupancy_rates" USING (true) WITH CHECK (true);



CREATE POLICY "Enable all access for all users on working_hours_settings" ON "public"."working_hours_settings" USING (true) WITH CHECK (true);



CREATE POLICY "Enable insert for all users on assets" ON "public"."assets" FOR INSERT WITH CHECK (true);



CREATE POLICY "Enable insert for all users on population_data" ON "public"."population_data" FOR INSERT WITH CHECK (true);



CREATE POLICY "Enable insert for all users on regions" ON "public"."regions" FOR INSERT WITH CHECK (true);



CREATE POLICY "Enable insert for all users on sub_regions" ON "public"."sub_regions" FOR INSERT WITH CHECK (true);



CREATE POLICY "Enable insert/update for all users on gender_distribution_basel" ON "public"."gender_distribution_baseline" USING (true) WITH CHECK (true);



CREATE POLICY "Enable insert/update for all users on visit_rates" ON "public"."visit_rates" USING (true) WITH CHECK (true);



CREATE POLICY "Enable read access for all users on assets" ON "public"."assets" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on available_days_settings" ON "public"."available_days_settings" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on dc_plans" ON "public"."dc_plans" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on gender_distribution_baselin" ON "public"."gender_distribution_baseline" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on map_icons" ON "public"."map_icons" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on map_settings" ON "public"."map_settings" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on occupancy_rates" ON "public"."occupancy_rates" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on planning_code_sections" ON "public"."planning_code_sections" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on planning_family_code" ON "public"."planning_family_code" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on population_data" ON "public"."population_data" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on primary_care_capacity" ON "public"."primary_care_capacity" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on primary_care_visit_times" ON "public"."primary_care_visit_times" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on proposed_care_setting_distr" ON "public"."proposed_care_setting_distribution" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on region_settings" ON "public"."region_settings" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on regions" ON "public"."regions" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on specialist_opd_capacity" ON "public"."specialist_opd_capacity" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on specialist_visit_times" ON "public"."specialist_visit_times" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on specialty_occupancy_rates" ON "public"."specialty_occupancy_rates" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on sub_region_settings" ON "public"."sub_region_settings" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on sub_regions" ON "public"."sub_regions" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on visit_rates" ON "public"."visit_rates" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users on working_hours_settings" ON "public"."working_hours_settings" FOR SELECT USING (true);



CREATE POLICY "Enable update for all users on assets" ON "public"."assets" FOR UPDATE USING (true) WITH CHECK (true);



CREATE POLICY "Enable update for all users on map_settings" ON "public"."map_settings" FOR UPDATE USING (true) WITH CHECK (true);



CREATE POLICY "Enable update for all users on population_data" ON "public"."population_data" FOR UPDATE USING (true) WITH CHECK (true);



CREATE POLICY "Enable update for all users on region_settings" ON "public"."region_settings" FOR UPDATE USING (true);



CREATE POLICY "Enable update for all users on regions" ON "public"."regions" FOR UPDATE USING (true) WITH CHECK (true);



CREATE POLICY "Enable update for all users on sub_region_settings" ON "public"."sub_region_settings" FOR UPDATE USING (true);



CREATE POLICY "Enable update for all users on sub_regions" ON "public"."sub_regions" FOR UPDATE USING (true) WITH CHECK (true);



ALTER TABLE "public"."ambulatory_service_center_services_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ambulatory_services_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."assets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."available_days_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."care_setting_optimization_data" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."care_settings_encounters" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."dc_plans" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."encounters" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."extended_care_facility_services_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."extended_services_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."gender_distribution_baseline" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."health_station_services_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."home_services_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hospital_services_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."map_icons" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."map_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."occupancy_rates" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."planning_code_sections" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."planning_code_sections_staging" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."planning_family_code" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."population_data" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."primary_care_capacity" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."primary_care_visit_times" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."proposed_care_setting_distribution" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."region_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."regions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."specialist_opd_capacity" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."specialist_visit_times" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."specialty_care_center_services_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."specialty_occupancy_rates" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."specialty_services_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sub_region_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sub_regions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."test" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."visit_rates" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."working_hours_settings" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."check_proposed_percentages"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_proposed_percentages"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_proposed_percentages"() TO "service_role";



GRANT ALL ON FUNCTION "public"."clean_activity_value"("activity_str" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."clean_activity_value"("activity_str" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."clean_activity_value"("activity_str" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."extract_icd_range"("description" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."extract_icd_range"("description" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."extract_icd_range"("description" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."fix_invalid_services"() TO "anon";
GRANT ALL ON FUNCTION "public"."fix_invalid_services"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fix_invalid_services"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_region_id"("region_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_region_id"("region_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_region_id"("region_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_appropriate_service"("p_icd_code" "text", "p_care_setting" "text", "p_systems_of_care" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_appropriate_service"("p_icd_code" "text", "p_care_setting" "text", "p_systems_of_care" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_appropriate_service"("p_icd_code" "text", "p_care_setting" "text", "p_systems_of_care" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_icon_url"("storage_path" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_icon_url"("storage_path" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_icon_url"("storage_path" "text") TO "service_role";



GRANT ALL ON TABLE "public"."map_settings" TO "anon";
GRANT ALL ON TABLE "public"."map_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."map_settings" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_map_settings"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_map_settings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_map_settings"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_service_for_planning"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_service_for_planning"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_service_for_planning"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_service_mapping"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_service_mapping"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_service_mapping"("p_care_setting" "text", "p_icd_code" "text", "p_system_of_care" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."inactivate_region_cascade"() TO "anon";
GRANT ALL ON FUNCTION "public"."inactivate_region_cascade"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."inactivate_region_cascade"() TO "service_role";



GRANT ALL ON FUNCTION "public"."initialize_proposed_distribution"("p_plan_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."initialize_proposed_distribution"("p_plan_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."initialize_proposed_distribution"("p_plan_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."migrate_planning_code_sections"() TO "anon";
GRANT ALL ON FUNCTION "public"."migrate_planning_code_sections"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."migrate_planning_code_sections"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_planning_family_service"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_planning_family_service"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_planning_family_service"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_population_defaults"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_population_defaults"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_population_defaults"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_region_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_region_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_region_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_assets_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_assets_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_assets_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_gender_baseline_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_gender_baseline_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_gender_baseline_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_population_data_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_population_data_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_population_data_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_service_mapping"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_service_mapping"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_service_mapping"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_timestamp"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_visit_rates_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_visit_rates_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_visit_rates_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_proposed_percentages"("p_plan_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."validate_proposed_percentages"("p_plan_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_proposed_percentages"("p_plan_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."ambulatory_service_center_services_mapping" TO "anon";
GRANT ALL ON TABLE "public"."ambulatory_service_center_services_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."ambulatory_service_center_services_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."ambulatory_services_mapping" TO "anon";
GRANT ALL ON TABLE "public"."ambulatory_services_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."ambulatory_services_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."assets" TO "anon";
GRANT ALL ON TABLE "public"."assets" TO "authenticated";
GRANT ALL ON TABLE "public"."assets" TO "service_role";



GRANT ALL ON TABLE "public"."available_days_settings" TO "anon";
GRANT ALL ON TABLE "public"."available_days_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."available_days_settings" TO "service_role";



GRANT ALL ON TABLE "public"."planning_family_code" TO "anon";
GRANT ALL ON TABLE "public"."planning_family_code" TO "authenticated";
GRANT ALL ON TABLE "public"."planning_family_code" TO "service_role";



GRANT ALL ON TABLE "public"."care_setting_activity_details" TO "anon";
GRANT ALL ON TABLE "public"."care_setting_activity_details" TO "authenticated";
GRANT ALL ON TABLE "public"."care_setting_activity_details" TO "service_role";



GRANT ALL ON TABLE "public"."care_setting_activity_summary" TO "anon";
GRANT ALL ON TABLE "public"."care_setting_activity_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."care_setting_activity_summary" TO "service_role";



GRANT ALL ON TABLE "public"."encounters" TO "anon";
GRANT ALL ON TABLE "public"."encounters" TO "authenticated";
GRANT ALL ON TABLE "public"."encounters" TO "service_role";



GRANT ALL ON TABLE "public"."care_setting_optimization" TO "anon";
GRANT ALL ON TABLE "public"."care_setting_optimization" TO "authenticated";
GRANT ALL ON TABLE "public"."care_setting_optimization" TO "service_role";



GRANT ALL ON TABLE "public"."care_setting_optimization_data" TO "anon";
GRANT ALL ON TABLE "public"."care_setting_optimization_data" TO "authenticated";
GRANT ALL ON TABLE "public"."care_setting_optimization_data" TO "service_role";



GRANT ALL ON TABLE "public"."care_settings_encounters" TO "anon";
GRANT ALL ON TABLE "public"."care_settings_encounters" TO "authenticated";
GRANT ALL ON TABLE "public"."care_settings_encounters" TO "service_role";



GRANT ALL ON TABLE "public"."dc_plans" TO "anon";
GRANT ALL ON TABLE "public"."dc_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."dc_plans" TO "service_role";



GRANT ALL ON TABLE "public"."encounters_statistics" TO "anon";
GRANT ALL ON TABLE "public"."encounters_statistics" TO "authenticated";
GRANT ALL ON TABLE "public"."encounters_statistics" TO "service_role";



GRANT ALL ON TABLE "public"."extended_care_facility_services_mapping" TO "anon";
GRANT ALL ON TABLE "public"."extended_care_facility_services_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."extended_care_facility_services_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."extended_services_mapping" TO "anon";
GRANT ALL ON TABLE "public"."extended_services_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."extended_services_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."gender_distribution_baseline" TO "anon";
GRANT ALL ON TABLE "public"."gender_distribution_baseline" TO "authenticated";
GRANT ALL ON TABLE "public"."gender_distribution_baseline" TO "service_role";



GRANT ALL ON TABLE "public"."health_station_services_mapping" TO "anon";
GRANT ALL ON TABLE "public"."health_station_services_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."health_station_services_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."home_services_mapping" TO "anon";
GRANT ALL ON TABLE "public"."home_services_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."home_services_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."hospital_services_mapping" TO "anon";
GRANT ALL ON TABLE "public"."hospital_services_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."hospital_services_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."icd_code_analysis" TO "anon";
GRANT ALL ON TABLE "public"."icd_code_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."icd_code_analysis" TO "service_role";



GRANT ALL ON TABLE "public"."specialty_care_center_services_mapping" TO "anon";
GRANT ALL ON TABLE "public"."specialty_care_center_services_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."specialty_care_center_services_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."icd_severity_analysis" TO "anon";
GRANT ALL ON TABLE "public"."icd_severity_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."icd_severity_analysis" TO "service_role";



GRANT ALL ON TABLE "public"."map_icons" TO "anon";
GRANT ALL ON TABLE "public"."map_icons" TO "authenticated";
GRANT ALL ON TABLE "public"."map_icons" TO "service_role";



GRANT ALL ON TABLE "public"."mapping_statistics" TO "anon";
GRANT ALL ON TABLE "public"."mapping_statistics" TO "authenticated";
GRANT ALL ON TABLE "public"."mapping_statistics" TO "service_role";



GRANT ALL ON TABLE "public"."occupancy_rates" TO "anon";
GRANT ALL ON TABLE "public"."occupancy_rates" TO "authenticated";
GRANT ALL ON TABLE "public"."occupancy_rates" TO "service_role";



GRANT ALL ON TABLE "public"."planning_code_sections" TO "anon";
GRANT ALL ON TABLE "public"."planning_code_sections" TO "authenticated";
GRANT ALL ON TABLE "public"."planning_code_sections" TO "service_role";



GRANT ALL ON TABLE "public"."planning_code_sections_staging" TO "anon";
GRANT ALL ON TABLE "public"."planning_code_sections_staging" TO "authenticated";
GRANT ALL ON TABLE "public"."planning_code_sections_staging" TO "service_role";



GRANT ALL ON TABLE "public"."planning_service_mapping_analysis" TO "anon";
GRANT ALL ON TABLE "public"."planning_service_mapping_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."planning_service_mapping_analysis" TO "service_role";



GRANT ALL ON TABLE "public"."population_data" TO "anon";
GRANT ALL ON TABLE "public"."population_data" TO "authenticated";
GRANT ALL ON TABLE "public"."population_data" TO "service_role";



GRANT ALL ON TABLE "public"."primary_care_capacity" TO "anon";
GRANT ALL ON TABLE "public"."primary_care_capacity" TO "authenticated";
GRANT ALL ON TABLE "public"."primary_care_capacity" TO "service_role";



GRANT ALL ON TABLE "public"."primary_care_visit_times" TO "anon";
GRANT ALL ON TABLE "public"."primary_care_visit_times" TO "authenticated";
GRANT ALL ON TABLE "public"."primary_care_visit_times" TO "service_role";



GRANT ALL ON TABLE "public"."proposed_care_setting_distribution" TO "anon";
GRANT ALL ON TABLE "public"."proposed_care_setting_distribution" TO "authenticated";
GRANT ALL ON TABLE "public"."proposed_care_setting_distribution" TO "service_role";



GRANT ALL ON TABLE "public"."region_settings" TO "anon";
GRANT ALL ON TABLE "public"."region_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."region_settings" TO "service_role";



GRANT ALL ON TABLE "public"."regions" TO "anon";
GRANT ALL ON TABLE "public"."regions" TO "authenticated";
GRANT ALL ON TABLE "public"."regions" TO "service_role";



GRANT ALL ON TABLE "public"."service_activity_summary" TO "anon";
GRANT ALL ON TABLE "public"."service_activity_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."service_activity_summary" TO "service_role";



GRANT ALL ON TABLE "public"."service_care_setting_distribution" TO "anon";
GRANT ALL ON TABLE "public"."service_care_setting_distribution" TO "authenticated";
GRANT ALL ON TABLE "public"."service_care_setting_distribution" TO "service_role";



GRANT ALL ON TABLE "public"."service_icd_analysis" TO "anon";
GRANT ALL ON TABLE "public"."service_icd_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."service_icd_analysis" TO "service_role";



GRANT ALL ON TABLE "public"."valid_services_view" TO "anon";
GRANT ALL ON TABLE "public"."valid_services_view" TO "authenticated";
GRANT ALL ON TABLE "public"."valid_services_view" TO "service_role";



GRANT ALL ON TABLE "public"."service_mapping_analysis" TO "anon";
GRANT ALL ON TABLE "public"."service_mapping_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."service_mapping_analysis" TO "service_role";



GRANT ALL ON TABLE "public"."specialist_opd_capacity" TO "anon";
GRANT ALL ON TABLE "public"."specialist_opd_capacity" TO "authenticated";
GRANT ALL ON TABLE "public"."specialist_opd_capacity" TO "service_role";



GRANT ALL ON TABLE "public"."specialist_visit_times" TO "anon";
GRANT ALL ON TABLE "public"."specialist_visit_times" TO "authenticated";
GRANT ALL ON TABLE "public"."specialist_visit_times" TO "service_role";



GRANT ALL ON TABLE "public"."specialty_care_mapping_stats" TO "anon";
GRANT ALL ON TABLE "public"."specialty_care_mapping_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."specialty_care_mapping_stats" TO "service_role";



GRANT ALL ON TABLE "public"."specialty_occupancy_rates" TO "anon";
GRANT ALL ON TABLE "public"."specialty_occupancy_rates" TO "authenticated";
GRANT ALL ON TABLE "public"."specialty_occupancy_rates" TO "service_role";



GRANT ALL ON TABLE "public"."specialty_services_mapping" TO "anon";
GRANT ALL ON TABLE "public"."specialty_services_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."specialty_services_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."sub_region_settings" TO "anon";
GRANT ALL ON TABLE "public"."sub_region_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."sub_region_settings" TO "service_role";



GRANT ALL ON TABLE "public"."sub_regions" TO "anon";
GRANT ALL ON TABLE "public"."sub_regions" TO "authenticated";
GRANT ALL ON TABLE "public"."sub_regions" TO "service_role";



GRANT ALL ON TABLE "public"."system_of_care_analysis" TO "anon";
GRANT ALL ON TABLE "public"."system_of_care_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."system_of_care_analysis" TO "service_role";



GRANT ALL ON TABLE "public"."table_row_counts" TO "anon";
GRANT ALL ON TABLE "public"."table_row_counts" TO "authenticated";
GRANT ALL ON TABLE "public"."table_row_counts" TO "service_role";



GRANT ALL ON TABLE "public"."test" TO "anon";
GRANT ALL ON TABLE "public"."test" TO "authenticated";
GRANT ALL ON TABLE "public"."test" TO "service_role";



GRANT ALL ON SEQUENCE "public"."test_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."test_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."test_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."top_icd_codes_by_service" TO "anon";
GRANT ALL ON TABLE "public"."top_icd_codes_by_service" TO "authenticated";
GRANT ALL ON TABLE "public"."top_icd_codes_by_service" TO "service_role";



GRANT ALL ON TABLE "public"."visit_rates" TO "anon";
GRANT ALL ON TABLE "public"."visit_rates" TO "authenticated";
GRANT ALL ON TABLE "public"."visit_rates" TO "service_role";



GRANT ALL ON TABLE "public"."working_hours_settings" TO "anon";
GRANT ALL ON TABLE "public"."working_hours_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."working_hours_settings" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






RESET ALL;
