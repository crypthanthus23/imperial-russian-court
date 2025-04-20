const express = require('express');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;
// Middleware
app.use(bodyParser.json());
app.use(cors());
// Root endpoint
app.get('/', (req, res) => {
  res.send('Imperial Russian Court API is running. Try /api/status for more information.');
});
// Database connection using environment variable
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});
// Log database connection attempt
console.log("Attempting to connect to database...");
// Test the connection immediately
pool.query('SELECT NOW() as time', (err, res) => {
  if (err) {
    console.error('Database connection test failed:', err);
  } else {
    console.log('Database connection successful. Server time:', res.rows[0].time);
  }
});
// Enhanced status endpoint
app.get('/api/status', (req, res) => {
  // Test database connection directly when status is requested
  pool.query('SELECT NOW() as time', (err, dbResult) => {
    res.json({
      status: 'API is running',
      timestamp: new Date(),
      database_connected: err ? false : true,
      database_error: err ? err.message : null,
      database_time: dbResult ? dbResult.rows[0].time : null,
      server_info: {
        node_version: process.version,
        platform: process.platform
      }
    });
  });
});
// Get player information
app.get('/api/get_player_info', async (req, res) => {
  const { player_first_name, player_last_name } = req.query;
  if (!player_first_name || !player_last_name) {
    return res.status(400).json({ error: 'Missing player name parameters' });
  }
  try {
    const query = {
      text: 'SELECT player_first_name, player_last_name, health, rubles, charm, influence, imperial_favor, faith, xp, love, family_name, russian_title, court_position, rank_name, supernatural_status, player_gender, political_faction, is_owner FROM players WHERE player_first_name = $1 AND player_last_name = $2',
      values: [player_first_name, player_last_name]
    };
    const result = await pool.query(query);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found' });
    }
    
    // Validate health value before returning
    let player = result.rows[0];
    if (player.health !== undefined) {
      const originalHealth = player.health;
      player.health = Math.max(0, Math.min(100, player.health));
      
      // Log if health was corrected
      if (originalHealth !== player.health) {
        console.log(`Health corrected on get_player_info: ${originalHealth} → ${player.health} for ${player_first_name} ${player_last_name}`);
        
        // Update the database with the corrected value
        await pool.query(
          'UPDATE players SET health = $1 WHERE player_first_name = $2 AND player_last_name = $3',
          [player.health, player_first_name, player_last_name]
        );
      }
    }
    
    res.json(player);
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
      text: 'INSERT INTO players (player_first_name, player_last_name, health, rubles, charm, influence, imperial_favor, faith, xp, love, family_name, russian_title, court_position, rank_name, supernatural_status, player_gender, political_faction, is_owner) VALUES ($1, $2, 100, 100, 0, 0, 0, 0, 0, 0, $3, \'Ninguno\', \'Ninguno\', \'Ninguno\', \'Ninguno\', $4, \'Ninguno\', false) RETURNING *',
      values: [player_first_name, player_last_name, family_name || 'Desconocido', player_gender || 'Unknown']
    };
    const insertResult = await pool.query(insertQuery);
    res.status(201).json(insertResult.rows[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Update a player's numeric stat - with validation
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
  
  // Validate stat values based on type
  let validatedValue = parseInt(value, 10);
  
  // Handle NaN case
  if (isNaN(validatedValue)) {
    return res.status(400).json({ error: 'Invalid numeric value' });
  }
  
  // Validate different stats based on their acceptable ranges
  const originalValue = validatedValue;
  
  if (stat_name === 'health') {
    // Health is 0-100
    validatedValue = Math.max(0, Math.min(100, validatedValue));
    if (originalValue !== validatedValue) {
      console.log(`Health validation: Original=${originalValue}, Validated=${validatedValue} for ${player_first_name} ${player_last_name}`);
    }
  } else if (['charm', 'influence', 'imperial_favor', 'faith', 'love'].includes(stat_name)) {
    // These stats should not be negative
    validatedValue = Math.max(0, validatedValue);
  }
  
  try {
    const query = {
      text: `UPDATE players SET ${stat_name} = $1 WHERE player_first_name = $2 AND player_last_name = $3 RETURNING *`,
      values: [validatedValue, player_first_name, player_last_name]
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
  // Include political_faction in allowed fields and changed rank to rank_name
  const allowedFields = ['family_name', 'russian_title', 'court_position', 'rank_name', 'supernatural_status', 'player_gender', 'political_faction'];
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
// Create tables if they don't exist on startup
async function initDatabase() {
  let client;
  try {
    console.log("Attempting to initialize database...");
    // Connect to check if the database is accessible
    client = await pool.connect();
    console.log("Database connection established successfully");
    
    // Create players table if it doesn't exist - changed rank to rank_name
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
        rank_name TEXT DEFAULT 'Ninguno',
        supernatural_status TEXT DEFAULT 'Ninguno',
        player_gender TEXT DEFAULT 'Unknown',
        political_faction TEXT DEFAULT 'Ninguno',
        is_owner BOOLEAN DEFAULT false,
        UNIQUE(player_first_name, player_last_name)
      )
    `);
    console.log("Players table created or verified");
    
    // Add columns if they don't exist
    try {
      await client.query(`ALTER TABLE players ADD COLUMN IF NOT EXISTS love INTEGER DEFAULT 0`);
      console.log("Love column added or verified");
      
      await client.query(`ALTER TABLE players ADD COLUMN IF NOT EXISTS political_faction TEXT DEFAULT 'Ninguno'`);
      console.log("Political faction column added or verified");
      
      // Remove the gender check constraint if it exists
      try {
        await client.query(`
          ALTER TABLE players DROP CONSTRAINT IF EXISTS players_player_gender_check;
        `);
        console.log("Gender constraint removed or not present");
      } catch (genderErr) {
        console.log('Note: Gender constraint operation error:', genderErr.message);
      }
      
      // Add check constraints for health
      try {
        await client.query(`
          DO $$ 
          BEGIN
            -- Check if health constraint exists
            IF NOT EXISTS (
              SELECT 1 FROM pg_constraint 
              WHERE conname = 'players_health_check'
            ) THEN
              ALTER TABLE players ADD CONSTRAINT players_health_check 
              CHECK (health >= 0 AND health <= 100);
            END IF;
          END $$;
        `);
        console.log("Health constraint added or verified");
        
        // Fix any existing health values that are out of range
        await client.query(`
          UPDATE players SET health = 
            CASE 
              WHEN health < 0 THEN 0
              WHEN health > 100 THEN 100
              ELSE health
            END
          WHERE health < 0 OR health > 100;
        `);
        console.log("Any invalid health values have been corrected");
        
      } catch (constraintErr) {
        console.log('Note: Constraint operations error:', constraintErr.message);
      }
      
    } catch (columnErr) {
      console.log('Note: Column operations error:', columnErr.message);
    }
    console.log('Database initialized successfully');
  } catch (err) {
    console.error('Error initializing database:', err);
  } finally {
    if (client) {
      client.release();
    }
  }
}
// Start the server
const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
  // Initialize database after server starts
  initDatabase();
});
module.exports = app;
