const express = require('express');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;
// Middleware
app.use(bodyParser.json());
app.use(cors());
// PostgreSQL connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});
// Test endpoint to verify server is running
app.get('/api/status', (req, res) => {
  res.json({ status: 'API is running', timestamp: new Date() });
});
// Get player information
app.get('/api/get_player_info', async (req, res) => {
  const { player_first_name, player_last_name } = req.query;
  if (!player_first_name || !player_last_name) {
    return res.status(400).json({ error: 'Missing player name parameters' });
  }
  try {
    // Updated to include love field
    const query = {
      text: 'SELECT player_first_name, player_last_name, health, rubles, charm, influence, imperial_favor, faith, xp, love, family_name, russian_title, court_position, rank, supernatural_status, player_gender, is_owner FROM players WHERE player_first_name = $1 AND player_last_name = $2',
      values: [player_first_name, player_last_name]
    };
    const result = await pool.query(query);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Add a new player
app.post('/api/add_player', async (req, res) => {
  const { player_first_name, player_last_name, family_name, player_gender } = req.body;
  if (!player_first_name || !player_last_name) {
    return res.status(400).json({ error: 'Missing required parameters' });
  }
  try {
    // Check if player already exists
    const checkQuery = {
      text: 'SELECT * FROM players WHERE player_first_name = $1 AND player_last_name = $2',
      values: [player_first_name, player_last_name]
    };
    const checkResult = await pool.query(checkQuery);
    if (checkResult.rows.length > 0) {
      return res.status(409).json({ error: 'Player already exists' });
    }
    // Add love field with default value of 0
    const insertQuery = {
      text: 'INSERT INTO players (player_first_name, player_last_name, health, rubles, charm, influence, imperial_favor, faith, xp, love, family_name, russian_title, court_position, rank, supernatural_status, player_gender, is_owner) VALUES ($1, $2, 100, 100, 0, 0, 0, 0, 0, 0, $3, \'Ninguno\', \'Ninguno\', \'Ninguno\', \'Ninguno\', $4, false) RETURNING *',
      values: [player_first_name, player_last_name, family_name || 'Desconocido', player_gender || 'Unknown']
    };
    const insertResult = await pool.query(insertQuery);
    res.status(201).json(insertResult.rows[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Update a player's numeric stat
app.post('/api/update_stat', async (req, res) => {
  const { player_first_name, player_last_name, stat_name, value } = req.body;
  if (!player_first_name || !player_last_name || !stat_name || value === undefined) {
    return res.status(400).json({ error: 'Missing required parameters' });
  }
  // Add love to the allowed stats list
  const allowedStats = ['health', 'rubles', 'charm', 'influence', 'imperial_favor', 'faith', 'xp', 'love'];
  if (!allowedStats.includes(stat_name)) {
    return res.status(400).json({ error: 'Invalid stat name' });
  }
  try {
    const query = {
      text: `UPDATE players SET ${stat_name} = $1 WHERE player_first_name = $2 AND player_last_name = $3 RETURNING *`,
      values: [value, player_first_name, player_last_name]
    };
    const result = await pool.query(query);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Update a player's field value (for non-numeric values)
app.post('/api/update_field', async (req, res) => {
  const { player_first_name, player_last_name, field_name, value } = req.body;
  if (!player_first_name || !player_last_name || !field_name || value === undefined) {
    return res.status(400).json({ error: 'Missing required parameters' });
  }
  const allowedFields = ['family_name', 'russian_title', 'court_position', 'rank', 'supernatural_status', 'player_gender'];
  if (!allowedFields.includes(field_name)) {
    return res.status(400).json({ error: 'Invalid field name' });
  }
  try {
    const query = {
      text: `UPDATE players SET ${field_name} = $1 WHERE player_first_name = $2 AND player_last_name = $3 RETURNING *`,
      values: [value, player_first_name, player_last_name]
    };
    const result = await pool.query(query);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Set owner flag for player
app.post('/api/set_owner', async (req, res) => {
  const { player_first_name, player_last_name, is_owner } = req.body;
  if (!player_first_name || !player_last_name || is_owner === undefined) {
    return res.status(400).json({ error: 'Missing required parameters' });
  }
  try {
    const query = {
      text: 'UPDATE players SET is_owner = $1 WHERE player_first_name = $2 AND player_last_name = $3 RETURNING *',
      values: [is_owner, player_first_name, player_last_name]
    };
    const result = await pool.query(query);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Start the server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
// Create tables if they don't exist on startup
async function initDatabase() {
  try {
    // Connect to check if the database is accessible
    const client = await pool.connect();
    
    // Create players table if it doesn't exist
    // Added love field to the table creation
    await client.query(`
      CREATE TABLE IF NOT EXISTS players (
        id SERIAL PRIMARY KEY,
        player_first_name TEXT NOT NULL,
        player_last_name TEXT NOT NULL,
        health INTEGER DEFAULT 100,
        rubles INTEGER DEFAULT 100,
        charm INTEGER DEFAULT 0,
        influence INTEGER DEFAULT 0,
        imperial_favor INTEGER DEFAULT 0,
        faith INTEGER DEFAULT 0,
        xp INTEGER DEFAULT 0,
        love INTEGER DEFAULT 0,
        family_name TEXT DEFAULT 'Desconocido',
        russian_title TEXT DEFAULT 'Ninguno',
        court_position TEXT DEFAULT 'Ninguno',
        rank TEXT DEFAULT 'Ninguno',
        supernatural_status TEXT DEFAULT 'Ninguno',
        player_gender TEXT DEFAULT 'Unknown',
        is_owner BOOLEAN DEFAULT false,
        UNIQUE(player_first_name, player_last_name)
      )
    `);
    // Add love column if it doesn't exist (for existing tables)
    try {
      await client.query(`
        ALTER TABLE players 
        ADD COLUMN IF NOT EXISTS love INTEGER DEFAULT 0
      `);
    } catch (columnErr) {
      console.log('Note: love column might already exist or could not be added:', columnErr.message);
    }
    console.log('Database initialized successfully');
    client.release();
  } catch (err) {
    console.error('Error initializing database:', err);
  }
}
// Initialize database on startup
initDatabase();
module.exports = app; // For testing purposes
