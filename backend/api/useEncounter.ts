import pool from "../db";
import { Router } from  'express';


const router = Router();
// Get region settings
router.get('/useEncounter/encountersStatistics', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM encounters_statistics'); // Adjust the query as needed
      res.json(result.rows);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Error fetching regions' });
    }
  });
  
  // Get system of care analysis
  router.get('/useEncounter/systemOfCareAnalysis', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM system_of_care_analysis'); // Adjust the query as needed
      res.json(result.rows);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Error fetching regions' });
    }
  });
  
  // Get care setting optimization data
  router.get('/useEncounter/careSettingOptimizationData', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM care_setting_optimization_data'); // Adjust the query as needed
      res.json(result.rows);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Error fetching regions' });
    }
  });
  
  // Get ICD code analysis
  router.get('/useEncounter/icdCodeAnalysis', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM icd_code_analysis ORDER BY total_encounters DESC LIMIT 5'); // Adjust the query as needed
      res.json(result.rows);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Error fetching regions' });
    }
  });

export default router;