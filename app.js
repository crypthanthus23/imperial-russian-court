const express = require('express');
const app = express();
const cors = require('cors');
const config = require('./config.json');
const port = process.env.PORT || config.port;

// Habilitar CORS
app.use(cors());
app.use(express.json());

// Ruta para obtener la información del jugador
app.get('/api/get_player_info', (req, res) => {
    const playerFirstName = req.query.player_first_name;
    const playerLastName = req.query.player_last_name;

    // Simulación de datos completos del jugador
    const playerData = {
        player_name: `${playerFirstName} ${playerLastName}`,
        health: 100,
        rubles: 1000000,
        rank: 'Tsar',
        charm: 10,
        influence: 20,
        imperial_favor: 5,
        faith: 30,
        family_name: 'Romanov',
        russian_title: 'Emperor of All the Russias',
        court_position: 'Autocrat of All the Russias',
        wealth: 'High'
    };

    res.json(playerData);
});

// Iniciar servidor
app.listen(port, () => {
    console.log(`Servidor corriendo en http://localhost:${port}`);
});
