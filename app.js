const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const port = process.env.PORT || 3000;

// Middleware para manejar JSON
app.use(bodyParser.json());

// Rutas de ejemplo
app.get('/', (req, res) => {
    res.send('¡Servidor Node.js funcionando correctamente!');
});

app.listen(port, () => {
    console.log(`Servidor ejecutándose en http://localhost:${port}`);
});
