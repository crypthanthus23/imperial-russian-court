const express = require('express');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;
// Middleware
app.use(bodyParser.json());
app.use(cors());
// Log environment and connection details (safely)
console.log('Node environment:', process.env.NODE_ENV);
console.log('DATABASE_URL environment variable is: ' + (process.env.DATABASE_URL ? 'set' : 'not set'));
if (process.env.DATABASE_URL) {
  const sanitizedUrl = process.env.DATABASE_URL.replace(/:[^:]*@/, ':****@');
  console.log('Sanitized DATABASE_URL:', sanitizedUrl);
}
// PostgreSQL connection with proper SSL configuration for Render
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false  // Required for Render PostgreSQL
  }
});
// Test database connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Database connection test failed:', err);
  } else {
    console.log('Database connection successful. Server time:', res.rows[0].now);
  }
});
// Rest of your existing code...
// (Your API endpoints remain the same)
// Start the server
app.listen(port, () => {
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
    // Add columns if they don't exist
    try {
      await client.query(`ALTER TABLE players ADD COLUMN IF NOT EXISTS love INTEGER DEFAULT 0`);
      await client.query(`ALTER TABLE players ADD COLUMN IF NOT EXISTS political_faction TEXT DEFAULT 'Ninguno'`);
      console.log("New columns added or verified");
    } catch (columnErr) {
      console.log('Note: Columns could not be added:', columnErr.message);
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
// Initialize database on startup
initDatabase();
module.exports = app;
