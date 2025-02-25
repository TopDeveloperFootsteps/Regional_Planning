-- First: Update existing regions to use new ID format
WITH region_updates AS (
  SELECT 
    r.id as old_id,
    generate_region_id(r.name) as new_id,
    r.name,
    r.latitude,
    r.longitude,
    r.status
  FROM regions r
)
UPDATE regions r
SET id = ru.new_id
FROM region_updates ru
WHERE r.id = ru.old_id;

-- Update any existing sub_regions to reference new region IDs
UPDATE sub_regions sr
SET region_id = r.id
FROM regions r
WHERE sr.region_id::text = r.id::text;