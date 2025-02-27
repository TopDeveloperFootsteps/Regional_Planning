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

// Endpoint to fetch population data
app.get('/population_data', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM population_data');
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching population data:', error);
        res.status(500).json({ error: 'Failed to fetch population data' });
    }
});

// Endpoint to fetch visit rates
app.get('/visit_rates', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM visit_rates');
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching visit rates:', error);
        res.status(500).json({ error: 'Failed to fetch visit rates' });
    }
});

// Endpoint to fetch gender distribution data
app.get('/gender_distribution', async (req, res) => {
    try {
        const result = await pool.query('SELECT male_data FROM gender_distribution_baseline LIMIT 1');
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching gender distribution:', error);
        res.status(500).json({ error: 'Failed to fetch gender distribution' });
    }
});
  
export default app;
