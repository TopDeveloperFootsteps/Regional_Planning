import pool from "../db";
import { Router } from  'express';


const router = Router();

router.post('/', async (req, res) => {
    const { name, population, date, capacity_data, activity_data } = req.body;

    try {
        const result = await pool.query(
            `INSERT INTO dc_plans (name, population, date, capacity_data, activity_data) 
             VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [name, population, date, capacity_data, activity_data]
        );

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error saving DC plan:', error);
        res.status(500).json({ error: 'Failed to save DC plan' });
    }
});

  
  export default router;
