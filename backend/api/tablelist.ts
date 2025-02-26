import pool from "../db";
import { Router } from  'express';


const router = Router();

router.get('/', async (req, res) => {
    try {
        // List of current tables with their proper names
        const knownTables = [
            "home_services_mapping",
            "ambulatory_service_center_services_mapping",
            "extended_care_facility_services_mapping",
            "health_station_services_mapping",
            "specialty_care_center_services_mapping",
            "hospital_services_mapping",
            "care_settings_encounters",
        ];

        const tableData = await Promise.all(
            knownTables.map(async (tableName) => {
                try {
                    const result = await pool.query(`SELECT COUNT(*) FROM ${tableName}`);
                    const count = parseInt(result.rows[0].count, 10);
                    return { name: tableName, count: count || 0 };
                } catch (err) {
                    console.warn(`Error fetching count for ${tableName}:`, err);
                    return { name: tableName, count: 0 };
                }
            })
        );

        res.json(tableData.filter((table) => table.count > 0));
    } catch (err) {
        console.error("Error fetching tables:", err);
        res.status(500).json({ error: "Failed to fetch table information" });
    }
});

export default router;
