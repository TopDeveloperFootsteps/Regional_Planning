import pool from "../db";
import { Router } from  'express';


const router = Router();

router.get('/populationData', async (req, res) => {
try {
    const result = await pool.query('SELECT * FROM population_data'); // Adjust the query as needed
    res.json(result.rows);
} catch (error) {
    console.error('Error fetching regions:', error);
    res.status(500).json({ error: 'Error fetching regions' });
}
});
  
  // Get regions
router.get('/populationRegions', async (req, res) => {
try {
    const result = await pool.query('SELECT id, name FROM regions WHERE is_neom = true AND status = \'active\''); // Adjust the query as needed
    res.json(result.rows);
} catch (error) {
    console.error('Error fetching regions:', error);
    res.status(500).json({ error: 'Error fetching regions' });
}
});
  
export default router;
