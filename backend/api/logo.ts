import pool from "../db";
import { Router } from  'express';


const router = Router();

router.get('/', async (req, res) => {
    const imageName = req.query.imageName;
    try {
      const result = await pool.query('SELECT public_url FROM images WHERE name = $1', [imageName]);
      
      if (result.rows.length > 0) {
        res.json({ publicUrl: result.rows[0].public_url });
      } else {
        res.status(404).json({ error: 'Image not found' });
      }
    } catch (error) {
      console.error('Error fetching image URL:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  export default router;
