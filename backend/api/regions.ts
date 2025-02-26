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
  
  // Update an existing region
  router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { name, latitude, longitude, status, is_neom } = req.body;
    try {
      const { rowCount } = await pool.query(
        'UPDATE regions SET name = $1, latitude = $2, longitude = $3, status = $4, is_neom = $5 WHERE id = $6',
        [name, latitude, longitude, status, is_neom, id]
      );
      if (rowCount === 0) {
        return res.status(404).json({ error: 'Region not found' });
      }
      res.status(200).json({ message: 'Region updated successfully' });
    } catch (error) {
      console.error('Error updating region:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  export default router;