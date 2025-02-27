import pool from "../db";
import { Router } from  'express';

const app = Router();
app.get('/available_days', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM available_days_settings WHERE care_setting = $1', ['Primary Care']);
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching available days:', error);
        res.status(500).json({ error: 'Failed to fetch available days' });
    }
});

// Endpoint to fetch working hours
app.get('/working_hours', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM working_hours_settings WHERE care_setting = $1', ['Primary Care']);
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching working hours:', error);
        res.status(500).json({ error: 'Failed to fetch working hours' });
    }
});

// Endpoint to fetch visit times
app.get('/visit_times', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM primary_care_visit_times ORDER BY reason_for_visit');
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching visit times:', error);
        res.status(500).json({ error: 'Failed to fetch visit times' });
    }
});

app.get('/available_days_s', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM available_days_settings WHERE care_setting = $1', ['Specialist Outpatient Care']);
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching available days:', error);
        res.status(500).json({ error: 'Failed to fetch available days' });
    }
});

// Endpoint to fetch working hours
app.get('/working_hours_s', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM working_hours_settings WHERE care_setting = $1', ['Specialist Outpatient Care']);
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching working hours:', error);
        res.status(500).json({ error: 'Failed to fetch working hours' });
    }
});

// Endpoint to fetch visit times
app.get('/visit_times_s', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM specialist_visit_times ORDER BY reason_for_visit');
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching visit times:', error);
        res.status(500).json({ error: 'Failed to fetch visit times' });
    }
});

// Endpoint to save capacity calculations
// app.post('/save_capacity_calculations', async (req, res) => {
//     const calculations = req.body;
//     try {
//         const result = await pool.query(
//             'INSERT INTO primary_care_capacity (service, total_minutes_per_year, total_slots_per_year, average_visit_duration, new_visits_per_year, follow_up_visits_per_year, slots_per_day, year) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) ON CONFLICT (service, year) DO UPDATE SET total_minutes_per_year = EXCLUDED.total_minutes_per_year, total_slots_per_year = EXCLUDED.total_slots_per_year, average_visit_duration = EXCLUDED.average_visit_duration, new_visits_per_year = EXCLUDED.new_visits_per_year, follow_up_visits_per_year = EXCLUDED.follow_up_visits_per_year, slots_per_day = EXCLUDED.slots_per_day',
//             calculations.map(calc => [
//                 calc.service,
//                 calc.totalMinutesPerYear,
//                 calc.totalSlotsPerYear,
//                 calc.averageVisitDuration,
//                 calc.newVisitsPerYear,
//                 calc.followUpVisitsPerYear,
//                 calc.slotsPerDay,
//                 calc.year
//             ])
//         );
//         res.json(result);
//     } catch (error) {
//         console.error('Error saving capacity calculations:', error);
//         res.status(500).json({ error: 'Failed to save calculations' });
//     }
// });
export default app;
