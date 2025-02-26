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
  
  // Create a new region
  router.post('/', async (req, res) => {
    const { name, latitude, longitude, status, is_neom } = req.body;
    try {
      const { rows } = await pool.query(
        'INSERT INTO regions (name, latitude, longitude, status, is_neom) VALUES ($1, $2, $3, $4, $5) RETURNING *',
        [name, latitude, longitude, status, is_neom]
      );
      res.status(201).json(rows[0]);
    } catch (error) {
      console.error('Error creating region:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  router.get('/', async (req, res) => {
    try {
      const { rows } = await pool.query('SELECT * FROM sub_regions ORDER BY name');
      res.json(rows);
    } catch (error) {
      console.error('Error fetching sub-regions:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  export default router;