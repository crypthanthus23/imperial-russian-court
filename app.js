const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const config = require('./config.json');

const app = express();
const port = process.env.PORT || config.port;

app.use(cors());
app.use(express.json());

// Crear un pool de conexiones para PostgreSQL
const pool = new Pool({
  connectionString: config.database_url,
  ssl: {
    rejectUnauthorized: false,
  }
});

// ===============================
// Endpoint para obtener la información del jugador
// ===============================
app.get('/api/get_player_info', async (req, res) => {
  const { player_first_name, player_last_name } = req.query;
  
  if (!player_first_name || !player_last_name) {
    return res.status(400).json({ error: 'Faltan parámetros de nombre' });
  }

  try {
    const result = await pool.query(
      `SELECT * FROM players WHERE player_first_name = $1 AND player_last_name = $2 LIMIT 1`,
      [player_first_name, player_last_name]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Jugador no encontrado' });
    }

    const player = result.rows[0];

    res.json({
      player_name: `${player.player_first_name} ${player.player_last_name}`,
      health: player.health,
      rubles: player.rubles,
      rank: player.rank,
      charm: player.charm,
      influence: player.influence,
      imperial_favor: player.imperial_favor,
      faith: player.faith,
      family_name: player.family_name,
      russian_title: player.russian_title,
      court_position: player.court_position,
      wealth: player.wealth
    });
  } catch (err) {
    console.error('Error consultando la base de datos:', err);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// ===============================
// Endpoint para registrar un jugador
// ===============================
app.post('/api/add_player', async (req, res) => {
  const { first_name, last_name } = req.body;

  if (!first_name || !last_name) {
    return res.status(400).json({ error: 'Faltan parámetros de nombre' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO players (player_first_name, player_last_name)
       VALUES ($1, $2)
       RETURNING *`,
      [first_name, last_name]
    );

    // Devolvemos 201 y el registro recién creado
    res.status(201).json({
      success: true,
      player: result.rows[0]
    });
  } catch (err) {
    console.error('Error en /api/add_player:', err);
    res.status(500).json({ success: false, error: 'Error interno del servidor' });
  }
});

// Iniciar el servidor en el puerto configurado
app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
