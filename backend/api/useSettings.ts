import pool from "../db";
import { Router } from  'express';


const router = Router();
// Get region settings
router.get('/regionSettings', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM region_settings LIMIT 1'); // Adjust the query as needed
      res.json(result.rows[0]);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Error fetching regions' });
    }
  });
  
  // Get sub-region settings
  router.get('/subRegionSettings', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM sub_region_settings LIMIT 1'); // Adjust the query as needed
      res.json(result.rows[0]);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Error fetching regions' });
    }
  });
  
  // Update region settings
  router.put('/regionSettings/:id', async (req, res) => {
    try {
      const { id } = req.params;
      const { show_circles, circle_transparency, circle_border, circle_radius_km } = req.body;
      const result = await pool.query(
        'UPDATE region_settings SET show_circles = $1, circle_transparency = $2, circle_border = $3, circle_radius_km = $4 WHERE id = $5 RETURNING *',
        [show_circles, circle_transparency, circle_border, circle_radius_km, id]
      );
      res.json(result.rows[0]);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Error fetching regions' });
    }
  });
  
  // Update sub-region settings
  router.put('/subRegionSettings/:id', async (req, res) => {
    try {
      const { id } = req.params;
      const { show_circles, circle_transparency, circle_border, circle_radius_km } = req.body;
      const result = await pool.query(
        'UPDATE sub_region_settings SET show_circles = $1, circle_transparency = $2, circle_border = $3, circle_radius_km = $4 WHERE id = $5 RETURNING *',
        [show_circles, circle_transparency, circle_border, circle_radius_km, id]
      );
      res.json(result.rows[0]);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Error fetching regions' });
    }
  });
  export default router;