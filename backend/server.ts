import express from 'express';
import cors from 'cors';
import pool from './db';
import logo from  './api/logo';
import regionsRouter from './api/regions';
import subRegionsRouter from './api/subRegions';
import mapSettingsRouter from './api/mapsettings'; // Changed 'mapSettings' to 'mapsettings' to match the casing
import useSettings from './api/useSettings'; 

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/getImageUrl', logo);
app.use('/api/regions', regionsRouter);
app.use('/api/subRegions', subRegionsRouter);
app.use('/api/mapSettings', mapSettingsRouter);
app.use('/api/useSettings', useSettings);


// Test database connection
pool.connect()
  .then(() => {
    console.log('Successfully connected to PostgreSQL database');
  })
  .catch(err => {
    console.error('Error connecting to PostgreSQL database:', err);
  });

app.listen(4000, () => {
  console.log('Server running on port 4000');
});
