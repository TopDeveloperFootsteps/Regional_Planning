-- First drop the existing constraints
ALTER TABLE assets 
DROP CONSTRAINT IF EXISTS assets_type_check,
DROP CONSTRAINT IF EXISTS assets_owner_check;

-- Add new constraints with correct values
ALTER TABLE assets
ADD CONSTRAINT assets_type_check 
CHECK (type IN ('Permanent', 'Temporary', 'PPP', 'MoH')),
ADD CONSTRAINT assets_owner_check 
CHECK (owner IN (
    'Neom',
    'MoD', 
    'Construction Camp',
    'AlBassam',
    'Nessma',
    'Tamasuk',
    'Alfanar',
    'Almutlaq',
    'MoH'
));