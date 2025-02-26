import express from 'express';
import cors from 'cors';
import pool from './db';

const app = express();
app.use(cors());
app.use(express.json());


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
