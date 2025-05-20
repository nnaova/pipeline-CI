require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Données simulées des capteurs
let sensors = [
  { id: 1, name: 'Température', location: 'Salle serveur', value: 22.5, unit: '°C' },
  { id: 2, name: 'Humidité', location: 'Salle serveur', value: 45, unit: '%' },
  { id: 3, name: 'CO2', location: 'Bureau principal', value: 800, unit: 'ppm' },
  { id: 4, name: 'Luminosité', location: 'Extérieur', value: 12000, unit: 'lux' }
];

// Routes
app.get('/', (req, res) => {
  res.json({ status: 'API fonctionnelle', version: '1.0.0' });
});

// Obtenir tous les capteurs
app.get('/api/sensors', (req, res) => {
  res.json(sensors);
});

// Obtenir un capteur par ID
app.get('/api/sensors/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const sensor = sensors.find(s => s.id === id);
  
  if (!sensor) {
    return res.status(404).json({ error: 'Capteur non trouvé' });
  }
  
  res.json(sensor);
});

// Ajouter une nouvelle mesure de capteur
app.post('/api/sensors', (req, res) => {
  const { name, location, value, unit } = req.body;
  
  if (!name || !location || value === undefined || !unit) {
    return res.status(400).json({ error: 'Données incomplètes' });
  }
  
  const newSensor = {
    id: sensors.length + 1,
    name,
    location,
    value,
    unit
  };
  
  sensors.push(newSensor);
  res.status(201).json(newSensor);
});

// Mettre à jour un capteur
app.put('/api/sensors/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { name, location, value, unit } = req.body;
  
  const sensorIndex = sensors.findIndex(s => s.id === id);
  
  if (sensorIndex === -1) {
    return res.status(404).json({ error: 'Capteur non trouvé' });
  }
  
  const updatedSensor = {
    ...sensors[sensorIndex],
    name: name || sensors[sensorIndex].name,
    location: location || sensors[sensorIndex].location,
    value: value !== undefined ? value : sensors[sensorIndex].value,
    unit: unit || sensors[sensorIndex].unit
  };
  
  sensors[sensorIndex] = updatedSensor;
  res.json(updatedSensor);
});

// Démarrage du serveur
// Vérifier si le fichier est exécuté directement (pas importé comme module dans les tests)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Serveur démarré sur le port ${PORT}`);
  });
}

module.exports = app; // Pour les tests
