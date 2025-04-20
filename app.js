const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const config = require('./config.json');
const app = express();
const port = process.env.PORT || config.port;
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true })); // Add this for form data parsing
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
      wealth: player.wealth,
      supernatural_status: player.supernatural_status
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
    // Verificar si el jugador ya existe en la base de datos
    const checkPlayer = await pool.query(
      `SELECT * FROM players WHERE player_first_name = $1 AND player_last_name = $2`,
      [first_name, last_name]
    );
    if (checkPlayer.rows.length > 0) {
      return res.status(400).json({ error: 'Este jugador ya está registrado' });
    }
    // Insertar el nuevo jugador si no existe en la base de datos
    const result = await pool.query(
      `INSERT INTO players (player_first_name, player_last_name, health, rubles, charm, influence, imperial_favor, faith, wealth, family_name, russian_title, court_position, supernatural_status, rank)
       VALUES ($1, $2, 100, 100, 10, 10, 10, 10, 'Moderate', 'Desconocido', 'Ninguno', 'Ninguno', 'Ninguno', 'Ninguno')
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
// ===============================
// Endpoint para actualizar una estadística numérica del jugador
// ===============================
app.post('/api/update_stat', async (req, res) => {
  // Support for both body and query parameters (for LSL compatibility)
  const player_first_name = req.body.player_first_name || req.query.player_first_name;
  const player_last_name = req.body.player_last_name || req.query.player_last_name;
  const statName = req.body.stat || req.query.stat;
  const statAmount = req.body.amount || req.query.amount;
  
  if (!player_first_name || !player_last_name || !statName || statAmount === undefined) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos' });
  }
  // Validar que la estadística sea una de las permitidas
  const allowedStats = ['health', 'rubles', 'charm', 'influence', 'imperial_favor', 'faith', 'wealth'];
  if (!allowedStats.includes(statName)) {
    return res.status(400).json({ error: 'Nombre de estadística inválido' });
  }
  try {
    // Primero obtenemos el valor actual
    const currentResult = await pool.query(
      `SELECT ${statName} FROM players WHERE player_first_name = $1 AND player_last_name = $2`,
      [player_first_name, player_last_name]
    );
    if (currentResult.rows.length === 0) {
      return res.status(404).json({ error: 'Jugador no encontrado' });
    }
    const currentValue = currentResult.rows[0][statName] || 0;
    const newValue = currentValue + parseInt(statAmount, 10);
    // Actualizamos la estadística
    await pool.query(
      `UPDATE players SET ${statName} = $1 WHERE player_first_name = $2 AND player_last_name = $3`,
      [newValue, player_first_name, player_last_name]
    );
    res.json({
      action: 'update_stat',
      stat: statName,
      new_value: newValue,
      change: parseInt(statAmount, 10)
    });
  } catch (err) {
    console.error('Error actualizando estadística:', err);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});
// ===============================
// Endpoint para actualizar un campo de texto del jugador
// ===============================
app.post('/api/update_field', async (req, res) => {
  // Support for both body and query parameters (for LSL compatibility)
  const player_first_name = req.body.player_first_name || req.query.player_first_name;
  const player_last_name = req.body.player_last_name || req.query.player_last_name;
  const fieldName = req.body.field || req.query.field;
  const fieldValue = req.body.value || req.query.value;
  
  if (!player_first_name || !player_last_name || !fieldName || fieldValue === undefined) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos' });
  }
  // Validar que el campo sea uno de los permitidos
  const allowedFields = ['family_name', 'russian_title', 'court_position', 'supernatural_status', 'rank'];
  if (!allowedFields.includes(fieldName)) {
    return res.status(400).json({ error: 'Nombre de campo inválido' });
  }
  try {
    // Comprobar si el jugador existe
    const checkPlayer = await pool.query(
      `SELECT * FROM players WHERE player_first_name = $1 AND player_last_name = $2`,
      [player_first_name, player_last_name]
    );
    if (checkPlayer.rows.length === 0) {
      return res.status(404).json({ error: 'Jugador no encontrado' });
    }
    // Actualizamos el campo
    await pool.query(
      `UPDATE players SET ${fieldName} = $1 WHERE player_first_name = $2 AND player_last_name = $3`,
      [fieldValue, player_first_name, player_last_name]
    );
    res.json({
      action: 'update_field',
      field: fieldName,
      value: fieldValue
    });
  } catch (err) {
    console.error('Error actualizando campo:', err);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});
// ===============================
// Endpoint de estado del API
// ===============================
app.get('/api/status', (req, res) => {
  res.json({
    status: 'active',
    message: 'Imperial Russian Court API is running',
    version: '1.0'
  });
});
// Iniciar el servidor en el puerto configurado
app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
