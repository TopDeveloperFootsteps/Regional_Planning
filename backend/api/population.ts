import pool from "../db";
import { Router } from  'express';


const router = Router();

router.get('/population_data', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM population_data');
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching population data:', error);
        res.status(500).json({ error: 'Failed to fetch population data' });
    }
});

// Endpoint to fetch regions
router.get('/regions', async (req, res) => {
    try {
        const result = await pool.query('SELECT id, name FROM regions WHERE is_neom = true AND status = $1', ['active']);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching regions:', error);
        res.status(500).json({ error: 'Failed to fetch regions' });
    }
});

router.get('/regions_g', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM regions WHERE is_neom = true AND status = $1', ['active']);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching regions:', error);
        res.status(500).json({ error: 'Failed to fetch regions' });
    }
});

// Endpoint to fetch gender distribution baseline data
router.get('/gender_distribution_baseline', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM gender_distribution_baseline WHERE id = $1', [1]);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching gender distribution baseline:', error);
        res.status(500).json({ error: 'Failed to fetch gender distribution baseline' });
    }
});

// Endpoint to save gender distribution baseline data
router.post('/gender_distribution_baseline', async (req, res) => {
    const { male_data } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO gender_distribution_baseline (id, male_data) VALUES ($1, $2) ON CONFLICT (id) DO UPDATE SET male_data = EXCLUDED.male_data',
            [1, male_data]
        );
        res.json(result);
    } catch (error) {
        console.error('Error saving gender distribution baseline:', error);
        res.status(500).json({ error: 'Failed to save gender distribution baseline' });
    }
});

router.put('/population_data/:id', async (req, res) => {
    const { id } = req.params;
    const { year, value } = req.body;
    try {
        const result = await pool.query(
            'UPDATE population_data SET year_$1 = $2 WHERE id = $3 RETURNING *',
            [year, value, id]
        );
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error updating population data:', error);
        res.status(500).json({ error: 'Failed to update population data' });
    }
});

// Endpoint to insert new population data
router.post('/population_data', async (req, res) => {
    const { region_id, population_type, default_factor, divisor, year, value } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO population_data (region_id, population_type, default_factor, divisor, year_$1) VALUES ($2, $3, $4, $5, $6) RETURNING *',
            [year, region_id, population_type, default_factor, divisor, value]
        );
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error inserting population data:', error);
        res.status(500).json({ error: 'Failed to insert population data' });
    }
});
  

router.get('/populationData', async (req, res) => {
    const { region_id } = req.query;
    try {
        const result = await pool.query('SELECT * FROM population_data WHERE region_id = $1', [region_id]);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching population data:', error);
        res.status(500).json({ error: 'Failed to fetch population data' });
    }
});
export default router;
