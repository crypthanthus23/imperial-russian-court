const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const config = require('./config.json');
const app = express();
const port = process.env.PORT || config.port;

// Habilitar CORS y configurar body-parser
app.use(cors());
app.use(express.json());

// Configuración de la base de datos
const pool = new Pool({
  connectionString: config.database_url,
});

// Ruta para obtener la información del jugador desde PostgreSQL
app.get('/api/get_player_info', async (req, res) => {
  const { player_first_name, player_last_name } = req.query;

  try {
    const result = await pool.query(
      `SELECT * FROM players WHERE player_first_name = $1 AND player_last_name = $2 LIMIT 1`,
      [player_first_name, player_last_name]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Jugador no encontrado' });
    }

    const player = result.rows[0];

    // Enviar los datos del jugador en formato JSON
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

// Iniciar el servidor
app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
