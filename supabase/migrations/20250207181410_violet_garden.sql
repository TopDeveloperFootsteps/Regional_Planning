-- Drop triggers first
DROP TRIGGER IF EXISTS update_population_summary ON population_data;
DROP TRIGGER IF EXISTS update_population_totals ON population_summary;

-- Drop functions
DROP FUNCTION IF EXISTS calculate_population_summary(text, integer);
DROP FUNCTION IF EXISTS calculate_all_population_summaries(integer);
DROP FUNCTION IF EXISTS update_population_summary_trigger();
DROP FUNCTION IF EXISTS calculate_population_totals(text, integer);
DROP FUNCTION IF EXISTS calculate_all_population_totals(integer);
DROP FUNCTION IF EXISTS update_population_totals_trigger();

-- Drop tables
DROP TABLE IF EXISTS population_summary CASCADE;
DROP TABLE IF EXISTS population_totals CASCADE;

-- Add comment explaining the change
COMMENT ON TABLE population_data IS 'Primary table for storing population data. Population summary functionality has been removed in favor of direct calculations.';