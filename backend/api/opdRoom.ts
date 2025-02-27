import pool from "../db";
import { Router } from  'express';


const app = Router();

app.get('/regions', async (req, res) => {
    try {
        const result = await pool.query('SELECT id, name FROM regions WHERE is_neom = true AND status = $1', ['active']);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching regions:', error);
        res.status(500).json({ error: 'Failed to fetch regions' });
    }
});

// Endpoint to fetch visit rates
app.get('/visit_rates', async (req, res) => {
    const { assumption_type } = req.query;
    try {
        const result = await pool.query('SELECT * FROM visit_rates WHERE assumption_type = $1', [assumption_type]);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching visit rates:', error);
        res.status(500).json({ error: 'Failed to fetch visit rates' });
    }
});

// Endpoint to fetch population data
app.get('/population_data', async (req, res) => {
    const { region_id } = req.query;
    try {
        const result = await pool.query('SELECT * FROM population_data WHERE region_id = $1 OR $1 = \'all\'', [region_id]);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching population data:', error);
        res.status(500).json({ error: 'Failed to fetch population data' });
    }
});

// Endpoint to fetch specialty occupancy rates
app.get('/specialty_occupancy_rates', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM specialty_occupancy_rates');
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching specialty occupancy rates:', error);
        res.status(500).json({ error: 'Failed to fetch specialty occupancy rates' });
    }
});

// Endpoint to fetch working hours for OPD
app.get('/working_hours', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM working_hours_settings WHERE care_setting = $1', ['Specialist Outpatient Care']);
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching working hours:', error);
        res.status(500).json({ error: 'Failed to fetch working hours' });
    }
});

// Endpoint to fetch available days for OPD
app.get('/available_days', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM available_days_settings WHERE care_setting = $1', ['Specialist Outpatient Care']);
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching available days:', error);
        res.status(500).json({ error: 'Failed to fetch available days' });
    }
});
  
export default app;
