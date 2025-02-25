-- Drop existing constraints if they exist
ALTER TABLE primary_care_capacity 
DROP CONSTRAINT IF EXISTS primary_care_capacity_service_year_key;

ALTER TABLE specialist_opd_capacity
DROP CONSTRAINT IF EXISTS specialist_opd_capacity_specialty_year_key;

-- Add new composite primary keys
ALTER TABLE primary_care_capacity
DROP CONSTRAINT IF EXISTS primary_care_capacity_pkey,
ADD PRIMARY KEY (service, year);

ALTER TABLE specialist_opd_capacity
DROP CONSTRAINT IF EXISTS specialist_opd_capacity_pkey,
ADD PRIMARY KEY (specialty, year);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_primary_care_capacity_service_year 
ON primary_care_capacity(service, year);

CREATE INDEX IF NOT EXISTS idx_specialist_opd_capacity_specialty_year 
ON specialist_opd_capacity(specialty, year);

-- Add comments
COMMENT ON TABLE primary_care_capacity IS 'Stores capacity calculations for primary care services with composite key on service and year';
COMMENT ON TABLE specialist_opd_capacity IS 'Stores capacity calculations for specialist outpatient services with composite key on specialty and year';