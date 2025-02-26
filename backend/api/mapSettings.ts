import pool from "../db";
import { Router } from  'express';


const router = Router();

router.get('/', async (req, res) => {
    try {
      const { rows } = await pool.query('SELECT * FROM regions ORDER BY name');
      res.json(rows);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
// Get map settings
router.get('/', async (req, res) => {
    try {
      const { rows } = await pool.query('SELECT * FROM map_settings LIMIT 1');
      res.json(rows[0]);
    } catch (error) {
      console.error('Error fetching map settings:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  // Update map settings
  router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { show_circles, circle_transparency, circle_border, circle_radius_km } = req.body;
    try {
      const { rowCount } = await pool.query(
        'UPDATE map_settings SET show_circles = $1, circle_transparency = $2, circle_border = $3, circle_radius_km = $4 WHERE id = $5',
        [show_circles, circle_transparency, circle_border, circle_radius_km, id]
      );
      if (rowCount === 0) {
        return res.status(404).json({ error: 'Map settings not found' });
      }
      res.status(200).json({ message: 'Map settings updated successfully' });
    } catch (error) {
      console.error('Error updating map settings:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  export default router;