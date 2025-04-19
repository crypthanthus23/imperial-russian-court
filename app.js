const express = require('express');
const app = express();
const cors = require('cors');
const config = require('./config.json');
const port = process.env.PORT || config.port;  // Usar el puerto configurado

// Habilitar CORS para permitir solicitudes desde cualquier origen
app.use(cors());

// Middleware para parsear los datos de la solicitud como JSON
app.use(express.json());

// Ruta para obtener la información del jugador
app.get('/api/get_player_info', (req, res) => {
    const playerFirstName = req.query.player_first_name;
    const playerLastName = req.query.player_last_name;

    // Lógica para simular la obtención de la información del jugador
    const playerData = {
        player_name: playerFirstName + " " + playerLastName,
        health: 100,
        rubles: 1000000,
        rank: 'Tsar'
    };

    // Devolver los datos como respuesta JSON
    res.json(playerData);
});

// Iniciar el servidor
app.listen(port, () => {
    console.log(`Servidor corriendo en http://localhost:${port}`);
});
