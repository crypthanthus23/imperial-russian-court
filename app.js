const express = require('express');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;
// Middleware
app.use(bodyParser.json());
app.use(cors());
// Log database connection attempt
console.log("Trying to connect to database with DATABASE_URL:", 
            process.env.DATABASE_URL ? 
            process.env.DATABASE_URL.replace(/:[^:]*@/, ':****@') : // Hide password in logs
            "No DATABASE_URL provided");
// PostgreSQL connection with better error handling
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});
// Test database connection
pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});
// Test endpoint to verify server is running
app.get('/api/status', (req, res) => {
  res.json({ 
    status: 'API is running', 
    timestamp: new Date(),
    database_connected: pool ? true : false
  });
});
// Get player information
app.get('/api/get_player_info', async (req, res) => {
  const { player_first_name, player_last_name } = req.query;
  if (!player_first_name || !player_last_name) {
    return res.status(400).json({ error: 'Missing player name parameters' });
  }
  try {
    // Updated to include love and political_faction fields
    const query = {
      text: 'SELECT player_first_name, player_last_name, health, rubles, charm, influence, imperial_favor, faith, xp, love, family_name, russian_title, court_position, rank, supernatural_status, player_gender, political_faction, is_owner FROM players WHERE player_first_name = $1 AND player_last_name = $2',
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
    // Add love and political_faction fields with default values
    const insertQuery = {
      text: 'INSERT INTO players (player_first_name, player_last_name, health, rubles, charm, influence, imperial_favor, faith, xp, love, family_name, russian_title, court_position, rank, supernatural_status, player_gender, political_faction, is_owner) VALUES ($1, $2, 100, 100, 0, 0, 0, 0, 0, 0, $3, \'Ninguno\', \'Ninguno\', \'Ninguno\', \'Ninguno\', $4, \'Ninguno\', false) RETURNING *',
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
  // Include love in the allowed stats list
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
  // Include political_faction in allowed fields
  const allowedFields = ['family_name', 'russian_title', 'court_position', 'rank', 'supernatural_status', 'player_gender', 'political_faction'];
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
// Start the server first, so we can serve API even if database connection fails
const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
// Create tables if they don't exist on startup
async function initDatabase() {
  let client;
  try {
    console.log("Attempting to initialize database...");
    // Connect to check if the database is accessible
    client = await pool.connect();
    console.log("Database connection established successfully");
    
    // Create players table if it doesn't exist
    // Include love and political_faction fields
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
        political_faction TEXT DEFAULT 'Ninguno',
        is_owner BOOLEAN DEFAULT false,
        UNIQUE(player_first_name, player_last_name)
      )
    `);
    console.log("Players table created or verified");
    // Add love column if it doesn't exist (for existing tables)
    try {
      await client.query(`
        ALTER TABLE players 
        ADD COLUMN IF NOT EXISTS love INTEGER DEFAULT 0
      `);
      console.log("Love column added or verified");
    } catch (columnErr) {
      console.log('Note: love column might already exist or could not be added:', columnErr.message);
    }
    // Add political_faction column if it doesn't exist (for existing tables)
    try {
      await client.query(`
        ALTER TABLE players 
        ADD COLUMN IF NOT EXISTS political_faction TEXT DEFAULT 'Ninguno'
      `);
      console.log("Political faction column added or verified");
    } catch (columnErr) {
      console.log('Note: political_faction column might already exist or could not be added:', columnErr.message);
    }
    console.log('Database initialized successfully');
  } catch (err) {
    console.error('Error initializing database:', err);
    // Don't crash the server - continue to run API with database error
  } finally {
    if (client) {
      client.release();
    }
  }
}
// Initialize database on startup
initDatabase();
// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    pool.end(() => {
      console.log('Database pool shut down');
      process.exit(0);
    });
  });
});
module.exports = app; // For testing purposes
