import express from 'express';
import cors from 'cors';
import pool from './db';
import logo from  './api/logo';
import regionsRouter from './api/regions';
import subRegionsRouter from './api/subRegions';
import mapSettingsRouter from './api/mapsettings'; // Changed 'mapSettings' to 'mapsettings' to match the casing
import useSettings from './api/useSettings'; 
import useEncounter from './api/useEncounter'; // Removed the '.ts' extension
import assets from './api/assets'; // Removed the '.ts' extension
import population from './api/population';
import mapping from './api/Mapping';
import tablelist from './api/tablelist';
import dcPlans from './api/dcPlan';
// import output from './api/output'
import assumtions from './api/assumptions'


const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/getImageUrl', logo);
app.use('/api/regions', regionsRouter);
app.use('/api/subRegions', subRegionsRouter);
app.use('/api/mapSettings', mapSettingsRouter);
app.use('/api/useSettings', useSettings);
app.use('/api/useEncounter', useEncounter);
app.use('/api/assets', assets );
app.use('/api/population', population);
app.use('/api/mapping', mapping);
app.use('/api/tablelist', tablelist);
app.use('/api/dc_plan', dcPlans);
// app.use('/api/output', output);
app.use('/api/assumptions', assumtions);
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
