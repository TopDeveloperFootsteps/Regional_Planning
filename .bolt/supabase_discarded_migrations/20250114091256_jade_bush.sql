-- Create a view to show detailed mapping statistics
CREATE OR REPLACE VIEW home_mapping_statistics AS
SELECT 
    hsm.service,
    hsm.systems_of_care,
    COUNT(*) as mapped_codes,
    STRING_AGG(hsm.icd_code, ', ' ORDER BY hsm.icd_code) as sample_codes
FROM 
    home_services_mapping hsm
GROUP BY 
    hsm.service,
    hsm.systems_of_care
ORDER BY 
    hsm.service,
    hsm.systems_of_care;