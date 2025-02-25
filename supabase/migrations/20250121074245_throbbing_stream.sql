-- Add NEOM column to regions table
ALTER TABLE regions
ADD COLUMN is_neom boolean NOT NULL DEFAULT true;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_regions_is_neom ON regions(is_neom);

-- Set all existing regions to NEOM = true
UPDATE regions SET is_neom = true;