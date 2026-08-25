require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Désactivation explicite du SSL pour le dev local
const isLocal = process.env.DISABLE_SSL === 'true' || process.env.DB_HOST === '127.0.0.1' || process.env.DB_HOST === 'localhost';

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'postgres',
  port: process.env.DB_PORT || 5432,
  ssl: isLocal ? false : { rejectUnauthorized: false }
});

// Endpoint Health Check
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'UP', db: 'Connected to Postgres' });
  } catch (err) {
    res.status(500).json({ status: 'DOWN', error: err.message });
  }
});

// Endpoint pour lire dans la BDD
app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ message: "Connected successfully!", timestamp: result.rows[0].now });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});