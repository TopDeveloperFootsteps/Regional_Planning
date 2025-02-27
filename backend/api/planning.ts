import pool from "../db";
import { Router } from  'express';


const app = Router();

app.get('/plans', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM dc_plans ORDER BY date DESC');
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching plans:', error);
        res.status(500).json({ error: 'Failed to fetch plans' });
    }
});

// Endpoint to fetch ICD analysis by service
app.get('/icd_analysis', async (req, res) => {
    const { service } = req.query;

    try {
        const result = await pool.query(
            'SELECT * FROM top_icd_codes_by_service WHERE service = $1 AND rank <= 20 ORDER BY rank',
            [service]
        );
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching ICD analysis:', error);
        res.status(500).json({ error: 'Failed to fetch ICD analysis' });
    }
});

app.get('/activity_data', async (req, res) => {
    try {
        const [summaryResult, detailsResult] = await Promise.all([
            pool.query('SELECT * FROM care_setting_activity_summary'),
            pool.query('SELECT * FROM care_setting_activity_details')
        ]);

        res.json({
            summary: summaryResult.rows,
            details: detailsResult.rows
        });
    } catch (error) {
        console.error('Error fetching activity data:', error);
        res.status(500).json({ error: 'Failed to fetch activity data' });
    }
});

// Endpoint to save service allocations
app.post('/service_allocations', async (req, res) => {
    const { allocations } = req.body;

    try {
        const result = await pool.query(
            'INSERT INTO service_allocations (plan_id, service, care_setting, proposed_distribution) VALUES ($1, $2, $3, $4) ON CONFLICT (plan_id, service, care_setting) DO UPDATE SET proposed_distribution = EXCLUDED.proposed_distribution',
            [allocations.plan_id, allocations.service, allocations.care_setting, allocations.proposed_distribution]
        );

        res.json(result.rows);
    } catch (error) {
        console.error('Error saving service allocation:', error);
        res.status(500).json({ error: 'Failed to save service allocation' });
    }
});

  
  export default app;
