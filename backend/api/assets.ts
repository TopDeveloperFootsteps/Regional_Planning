import pool from "../db";
import { Router } from  'express';


const router = Router();

router.get('/', async (req, res) => {
    try {
      const result = await pool.query(
        'SELECT * FROM assets WHERE status != $1 ORDER BY created_at DESC',
        ['Closed']
      ); // Adjust the query as needed
      res.json(result.rows);
    } catch (error) {
      console.error('Error fetching regions:', error);
      res.status(500).json({ error: 'Error fetching regions' });
    }
  });
router.get('/assetsTable', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM assets ORDER BY created_at DESC');
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching assets:', error);
        res.status(500).json({ error: 'Failed to fetch assets' });
    }
});
router.post('/assetsForm', async (req, res) => {
  const assetData = req.body;

  try {
      if (assetData.id) {
          // Update existing asset
          const result = await pool.query(
              'UPDATE assets SET region_id = $1, asset_id = $2, name = $3, type = $4, owner = $5, archetype = $6, population_types = $7, start_date = $8, end_date = $9, latitude = $10, longitude = $11, gfa = $12, status = $13 WHERE id = $14',
              [
                  assetData.region_id,
                  assetData.asset_id,
                  assetData.name,
                  assetData.type,
                  assetData.owner,
                  assetData.archetype,
                  assetData.population_types,
                  assetData.start_date,
                  assetData.end_date,
                  assetData.latitude,
                  assetData.longitude,
                  assetData.gfa,
                  assetData.status,
                  assetData.id,
              ]
          );
          res.json({ success: true });
      } else {
          // Create new asset
          const result = await pool.query(
              'INSERT INTO assets (region_id, asset_id, name, type, owner, archetype, population_types, start_date, end_date, latitude, longitude, gfa, status) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)',
              [
                  assetData.region_id,
                  assetData.asset_id,
                  assetData.name,
                  assetData.type,
                  assetData.owner,
                  assetData.archetype,
                  assetData.population_types,
                  assetData.start_date,
                  assetData.end_date,
                  assetData.latitude,
                  assetData.longitude,
                  assetData.gfa,
                  assetData.status,
              ]
          );
          res.json({ success: true });
      }
  } catch (error) {
      console.error('Error saving asset:', error);
      res.status(500).json({ error: 'Failed to save asset' });
  }
});

export default router;
