import pool from "../db";
import { Router } from  'express';


const app = Router();

app.get('/specialty_occupancy_rates', async (req, res) => {
    const { care_setting } = req.query;
    try {
        const result = await pool.query('SELECT * FROM specialty_occupancy_rates WHERE care_setting = $1 ORDER BY specialty', [care_setting]);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching specialty occupancy rates:', error);
        res.status(500).json({ error: 'Failed to fetch specialty occupancy rates' });
    }
});

// Endpoint to update specialty occupancy rates
app.put('/specialty_occupancy_rates/:id', async (req, res) => {
    const { id } = req.params;
    const { field, value } = req.body;
    try {
        const result = await pool.query(
            'UPDATE specialty_occupancy_rates SET ' + field + ' = $1 WHERE id = $2 RETURNING *',
            [value, id]
        );
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error updating specialty occupancy rate:', error);
        res.status(500).json({ error: 'Failed to update specialty occupancy rate' });
    }
});
  
export default app;
