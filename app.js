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
      text: 'SELECT player_first_name, player_last_name, health, rubles, charm, influence, imperial_favor, faith, xp, love, family_name, russian_title, court_position, rank_name, supernatural_status, player_gender, political_faction, is_owner, vitae_level, vitae_max, is_in_lethargy, generation FROM players WHERE player_first_name = $1 AND player_last_name = $2',
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
  const allowedStats = ['health', 'rubles', 'charm', 'influence', 'imperial_favor', 'faith', 'xp', 'love', 'vitae_level'];
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
  } else if (stat_name === 'vitae_level') {
    // Validate vitae level against vitae_max
    try {
      const maxVitaeQuery = {
        text: 'SELECT vitae_max FROM players WHERE player_first_name = $1 AND player_last_name = $2',
        values: [player_first_name, player_last_name]
      };
      const maxVitaeResult = await pool.query(maxVitaeQuery);
      
      if (maxVitaeResult.rows.length > 0) {
        const maxVitae = maxVitaeResult.rows[0].vitae_max || 100;
        validatedValue = Math.max(0, Math.min(maxVitae, validatedValue));
      }
    } catch (err) {
      console.error('Error validating vitae:', err);
    }
  }
  
  try {
    // Update the stat
    const query = {
      text: `UPDATE players SET ${stat_name} = $1 WHERE player_first_name = $2 AND player_last_name = $3 RETURNING *`,
      values: [validatedValue, player_first_name, player_last_name]
    };
    const result = await pool.query(query);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found' });
    }
    
    // If updating vitae, check for lethargy
    if (stat_name === 'vitae_level') {
      const isLethargy = validatedValue <= 0;
      
      // Update lethargy status
      await pool.query(
        'UPDATE players SET is_in_lethargy = $1 WHERE player_first_name = $2 AND player_last_name = $3',
        [isLethargy, player_first_name, player_last_name]
      );
      
      // Record lethargy in death records if applicable
      if (isLethargy) {
        const playerIdQuery = {
          text: 'SELECT id FROM players WHERE player_first_name = $1 AND player_last_name = $2',
          values: [player_first_name, player_last_name]
        };
        const playerIdResult = await pool.query(playerIdQuery);
        
        if (playerIdResult.rows.length > 0) {
          const playerId = playerIdResult.rows[0].id;
          
          await pool.query(
            'INSERT INTO death_records (player_id, death_type, cause_of_death) VALUES ($1, $2, $3)',
            [playerId, 'Lethargy', 'Entered lethargy due to lack of vitae']
          );
        }
      }
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
  // Include vampire fields in allowed fields
  const allowedFields = ['family_name', 'russian_title', 'court_position', 'rank_name', 'supernatural_status', 'player_gender', 'political_faction', 'is_in_lethargy'];
  if (!allowedFields.includes(field_name)) {
    return res.status(400).json({ error: 'Invalid field name' });
  }
  
  try {
    // Special handling for supernatural_status
    if (field_name === 'supernatural_status' && value === 'SecretVampire') {
      // Check if generation is set
      const genQuery = {
        text: 'SELECT generation FROM players WHERE player_first_name = $1 AND player_last_name = $2',
        values: [player_first_name, player_last_name]
      };
      
      const genResult = await pool.query(genQuery);
      
      // If becoming a vampire and no generation set, default to high generation
      if (genResult.rows.length > 0 && (genResult.rows[0].generation === null || genResult.rows[0].generation === undefined)) {
        await pool.query(
          'UPDATE players SET generation = $1, vitae_level = 100, vitae_max = 100 WHERE player_first_name = $2 AND player_last_name = $3',
          [13, player_first_name, player_last_name]
        );
      }
    }
    
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
// VAMPIRE SYSTEM - NEW ENDPOINTS
// Get clan information
app.get('/api/get_clan_info', async (req, res) => {
  const { clan_name } = req.query;
  
  try {
    let query;
    let result;
    
    if (clan_name) {
      // Get specific clan info
      query = {
        text: 'SELECT * FROM clans WHERE name = $1',
        values: [clan_name]
      };
      result = await pool.query(query);
      
      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Clan not found' });
      }
      
      // Get disciplines for this clan
      const disciplinesQuery = {
        text: `
          SELECT d.name, d.description, d.activation_words
          FROM disciplines d
          JOIN clan_disciplines cd ON d.id = cd.discipline_id
          JOIN clans c ON c.id = cd.clan_id
          WHERE c.name = $1
        `,
        values: [clan_name]
      };
      
      const disciplinesResult = await pool.query(disciplinesQuery);
      
      // Return clan with its disciplines
      const clanData = result.rows[0];
      clanData.disciplines = disciplinesResult.rows;
      
      res.json(clanData);
    } else {
      // Get all clans grouped by faction
      query = `
        SELECT faction, json_agg(json_build_object('name', name, 'description', description)) as clans
        FROM clans
        GROUP BY faction
      `;
      
      result = await pool.query(query);
      res.json(result.rows);
    }
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Get bloodline information
app.get('/api/get_bloodline', async (req, res) => {
  const { player_first_name, player_last_name } = req.query;
  
  if (!player_first_name || !player_last_name) {
    return res.status(400).json({ error: 'Missing player name parameters' });
  }
  
  try {
    // Get player ID
    const playerQuery = {
      text: 'SELECT id FROM players WHERE player_first_name = $1 AND player_last_name = $2',
      values: [player_first_name, player_last_name]
    };
    
    const playerResult = await pool.query(playerQuery);
    
    if (playerResult.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found' });
    }
    
    const playerId = playerResult.rows[0].id;
    
    // Get sire information
    const sireQuery = {
      text: `
        SELECT p.player_first_name, p.player_last_name, p.generation, p.supernatural_status, p.political_faction
        FROM players p
        JOIN bloodlines b ON p.id = b.sire_id
        WHERE b.progenie_id = $1
      `,
      values: [playerId]
    };
    
    const sireResult = await pool.query(sireQuery);
    
    // Get progenie information
    const progenieQuery = {
      text: `
        SELECT p.player_first_name, p.player_last_name, p.generation, p.supernatural_status, p.political_faction
        FROM players p
        JOIN bloodlines b ON p.id = b.progenie_id
        WHERE b.sire_id = $1
      `,
      values: [playerId]
    };
    
    const progenieResult = await pool.query(progenieQuery);
    
    // Construct bloodline response
    const bloodlineData = {
      player: { 
        first_name: player_first_name, 
        last_name: player_last_name 
      },
      sire: sireResult.rows.length > 0 ? sireResult.rows[0] : null,
      progenies: progenieResult.rows
    };
    
    res.json(bloodlineData);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Create bloodline link (sire-progenie relationship)
app.post('/api/create_bloodline', async (req, res) => {
  const { sire_first_name, sire_last_name, progenie_first_name, progenie_last_name } = req.body;
  
  if (!sire_first_name || !sire_last_name || !progenie_first_name || !progenie_last_name) {
    return res.status(400).json({ error: 'Missing required parameters' });
  }
  
  try {
    // Get sire info
    const sireQuery = {
      text: 'SELECT id, generation, supernatural_status, political_faction FROM players WHERE player_first_name = $1 AND player_last_name = $2',
      values: [sire_first_name, sire_last_name]
    };
    
    const sireResult = await pool.query(sireQuery);
    
    if (sireResult.rows.length === 0) {
      return res.status(404).json({ error: 'Sire not found' });
    }
    
    const sireId = sireResult.rows[0].id;
    const sireGeneration = sireResult.rows[0].generation;
    const sireClan = sireResult.rows[0].political_faction;
    
    if (sireResult.rows[0].supernatural_status !== 'SecretVampire') {
      return res.status(400).json({ error: 'Sire must be a vampire' });
    }
    
    // Get progenie info
    const progenieQuery = {
      text: 'SELECT id FROM players WHERE player_first_name = $1 AND player_last_name = $2',
      values: [progenie_first_name, progenie_last_name]
    };
    
    const progenieResult = await pool.query(progenieQuery);
    
    if (progenieResult.rows.length === 0) {
      return res.status(404).json({ error: 'Progenie not found' });
    }
    
    const progenieId = progenieResult.rows[0].id;
    
    // Check if progenie already has a sire
    const bloodlineCheckQuery = {
      text: 'SELECT * FROM bloodlines WHERE progenie_id = $1',
      values: [progenieId]
    };
    
    const bloodlineCheckResult = await pool.query(bloodlineCheckQuery);
    
    if (bloodlineCheckResult.rows.length > 0) {
      return res.status(409).json({ error: 'Progenie already has a sire' });
    }
    
    // Calculate new progenie generation
    const newGeneration = sireGeneration + 1;
    
    // Update progenie to be a vampire and set generation
    await pool.query(
      'UPDATE players SET supernatural_status = $1, generation = $2, political_faction = $3, vitae_level = 100, vitae_max = 100 WHERE id = $4',
      ['SecretVampire', newGeneration, sireClan, progenieId]
    );
    
    // Create bloodline entry
    const bloodlineQuery = {
      text: 'INSERT INTO bloodlines (sire_id, progenie_id, generation) VALUES ($1, $2, $3) RETURNING *',
      values: [sireId, progenieId, newGeneration]
    };
    
    const bloodlineResult = await pool.query(bloodlineQuery);
    
    res.status(201).json({
      message: 'Bloodline created successfully',
      bloodline: bloodlineResult.rows[0]
    });
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Record feeding action
app.post('/api/record_feeding', async (req, res) => {
  const { vampire_first_name, vampire_last_name, victim_first_name, victim_last_name, vitae_amount } = req.body;
  
  if (!vampire_first_name || !vampire_last_name || !victim_first_name || !victim_last_name || vitae_amount === undefined) {
    return res.status(400).json({ error: 'Missing required parameters' });
  }
  
  try {
    // Get vampire ID
    const vampireQuery = {
      text: 'SELECT id, vitae_level, vitae_max, supernatural_status FROM players WHERE player_first_name = $1 AND player_last_name = $2',
      values: [vampire_first_name, vampire_last_name]
    };
    
    const vampireResult = await pool.query(vampireQuery);
    
    if (vampireResult.rows.length === 0) {
      return res.status(404).json({ error: 'Vampire not found' });
    }
    
    if (vampireResult.rows[0].supernatural_status !== 'SecretVampire') {
      return res.status(400).json({ error: 'Feeder must be a vampire' });
    }
    
    const vampireId = vampireResult.rows[0].id;
    let vampireVitae = vampireResult.rows[0].vitae_level || 0;
    const vampireMaxVitae = vampireResult.rows[0].vitae_max || 100;
    
    // Get victim ID
    const victimQuery = {
      text: 'SELECT id, health FROM players WHERE player_first_name = $1 AND player_last_name = $2',
      values: [victim_first_name, victim_last_name]
    };
    
    const victimResult = await pool.query(victimQuery);
    
    if (victimResult.rows.length === 0) {
      return res.status(404).json({ error: 'Victim not found' });
    }
    
    const victimId = victimResult.rows[0].id;
    let victimHealth = victimResult.rows[0].health || 100;
    
    // Calculate new values
    const validVitaeAmount = Math.min(parseInt(vitae_amount), vampireMaxVitae - vampireVitae, victimHealth);
    vampireVitae += validVitaeAmount;
    victimHealth -= validVitaeAmount;
    
    // Update vampire vitae
    await pool.query(
      'UPDATE players SET vitae_level = $1, is_in_lethargy = false WHERE id = $2',
      [vampireVitae, vampireId]
    );
    
    // Update victim health
    await pool.query(
      'UPDATE players SET health = $1 WHERE id = $2',
      [victimHealth, victimId]
    );
    
    // Record feeding history
    const feedingQuery = {
      text: 'INSERT INTO feeding_history (vampire_id, victim_id, vitae_amount) VALUES ($1, $2, $3) RETURNING *',
      values: [vampireId, victimId, validVitaeAmount]
    };
    
    const feedingResult = await pool.query(feedingQuery);
    
    // Check if victim died from feeding
    if (victimHealth <= 0) {
      // Record death
      await pool.query(
        'INSERT INTO death_records (player_id, death_type, cause_of_death, killer_id) VALUES ($1, $2, $3, $4)',
        [victimId, 'Exsanguination', 'Died from blood loss due to vampire feeding', vampireId]
      );
    }
    
    res.json({
      message: 'Feeding recorded successfully',
      vitae_gained: validVitaeAmount,
      new_vitae_level: vampireVitae,
      victim_health: victimHealth,
      feeding_record: feedingResult.rows[0]
    });
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});
// Get clan members
app.get('/api/get_clan_members', async (req, res) => {
  const { clan_name } = req.query;
  
  if (!clan_name) {
    return res.status(400).json({ error: 'Missing clan name parameter' });
  }
  
  try {
    // Get all members of the clan
    const query = {
      text: `
        SELECT 
          player_first_name, 
          player_last_name, 
          family_name, 
          rank_name,
          generation
        FROM players 
        WHERE political_faction = $1 
        AND supernatural_status = 'SecretVampire'
        ORDER BY 
          CASE rank_name
            WHEN 'Prince' THEN 1
            WHEN 'Primogen' THEN 2
            WHEN 'Sheriff' THEN 3
            ELSE 4
          END,
          generation,
          family_name
      `,
      values: [clan_name]
    };
    
    const result = await pool.query(query);
    
    // Group by family
    const families = {};
    result.rows.forEach(member => {
      const familyName = member.family_name || 'No Family';
      
      if (!families[familyName]) {
        families[familyName] = [];
      }
      
      families[familyName].push(member);
    });
    
    res.json({
      clan: clan_name,
      total_members: result.rows.length,
      families: families
    });
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
        vitae_level INTEGER DEFAULT 100,
        vitae_max INTEGER DEFAULT 100,
        is_in_lethargy BOOLEAN DEFAULT FALSE,
        generation INTEGER DEFAULT NULL,
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
      
      await client.query(`ALTER TABLE players ADD COLUMN IF NOT EXISTS vitae_level INTEGER DEFAULT 100`);
      await client.query(`ALTER TABLE players ADD COLUMN IF NOT EXISTS vitae_max INTEGER DEFAULT 100`);
      await client.query(`ALTER TABLE players ADD COLUMN IF NOT EXISTS is_in_lethargy BOOLEAN DEFAULT FALSE`);
      await client.query(`ALTER TABLE players ADD COLUMN IF NOT EXISTS generation INTEGER DEFAULT NULL`);
      console.log("Vampire-specific columns added or verified");
      
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
    
    // Create or verify vampire tables
    await client.query(`
      CREATE TABLE IF NOT EXISTS clans (
        id SERIAL PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        faction TEXT NOT NULL,
        description TEXT,
        founder TEXT,
        tenebrous_lineage TEXT
      )
    `);
    console.log("Clans table created or verified");
    
    await client.query(`
      CREATE TABLE IF NOT EXISTS disciplines (
        id SERIAL PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        activation_words TEXT
      )
    `);
    console.log("Disciplines table created or verified");
    
    await client.query(`
      CREATE TABLE IF NOT EXISTS clan_disciplines (
        clan_id INTEGER REFERENCES clans(id),
        discipline_id INTEGER REFERENCES disciplines(id),
        PRIMARY KEY (clan_id, discipline_id)
      )
    `);
    console.log("Clan disciplines table created or verified");
    
    await client.query(`
      CREATE TABLE IF NOT EXISTS bloodlines (
        id SERIAL PRIMARY KEY,
        sire_id INTEGER REFERENCES players(id),
        progenie_id INTEGER REFERENCES players(id),
        generation INTEGER,
        creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(progenie_id)
      )
    `);
    console.log("Bloodlines table created or verified");
    
    await client.query(`
      CREATE TABLE IF NOT EXISTS feeding_history (
        id SERIAL PRIMARY KEY,
        vampire_id INTEGER REFERENCES players(id),
        victim_id INTEGER REFERENCES players(id),
        feeding_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        vitae_amount INTEGER
      )
    `);
    console.log("Feeding history table created or verified");
    
    await client.query(`
      CREATE TABLE IF NOT EXISTS death_records (
        id SERIAL PRIMARY KEY,
        player_id INTEGER REFERENCES players(id),
        death_type TEXT,
        death_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        cause_of_death TEXT,
        killer_id INTEGER REFERENCES players(id) NULL
      )
    `);
    console.log("Death records table created or verified");
    
    // Create views
    await client.query(`
      CREATE OR REPLACE VIEW vampire_hierarchy AS
      SELECT 
        p.id,
        p.player_first_name,
        p.player_last_name,
        p.supernatural_status,
        p.political_faction,
        p.family_name,
        p.rank_name,
        p.generation,
        sire.player_first_name as sire_first_name,
        sire.player_last_name as sire_last_name
      FROM 
        players p
      LEFT JOIN 
        bloodlines b ON p.id = b.progenie_id
      LEFT JOIN 
        players sire ON sire.id = b.sire_id
      WHERE 
        p.supernatural_status = 'SecretVampire'
    `);
    console.log("Vampire hierarchy view created or replaced");
    
    await client.query(`
      CREATE OR REPLACE VIEW clan_members AS
      SELECT 
        c.name as clan_name,
        c.faction,
        COUNT(p.id) as member_count
      FROM 
        clans c
      LEFT JOIN 
        players p ON c.name = p.political_faction
      WHERE
        p.supernatural_status = 'SecretVampire'
      GROUP BY 
        c.name, c.faction
    `);
    console.log("Clan members view created or replaced");
    
    await client.query(`
      CREATE OR REPLACE VIEW family_structure AS
      SELECT 
        p.political_faction as clan,
        p.family_name,
        COUNT(p.id) as family_members
      FROM 
        players p
      WHERE 
        p.supernatural_status = 'SecretVampire'
        AND p.family_name IS NOT NULL
        AND p.family_name != 'Desconocido'
      GROUP BY 
        p.political_faction, p.family_name
    `);
    console.log("Family structure view created or replaced");
    
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
  initDatabase().then(() => {
    console.log('Database fully initialized with vampire system');
  });
});
