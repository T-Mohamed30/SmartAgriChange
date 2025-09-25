const express = require('express');
const router = express.Router();
const WeatherController = require('../controllers/weatherController');
const auth = require('../middleware/auth');

// Toutes les routes nécessitent une authentification
router.use(auth);

// Routes pour les données météorologiques
router.get('/forecast', WeatherController.getForecast);
router.get('/current', WeatherController.getCurrent);
router.get('/history', WeatherController.getHistory);
router.get('/stats', WeatherController.getStats);

// Routes admin (à sécuriser davantage si nécessaire)
router.post('/', WeatherController.create);
router.put('/:id', WeatherController.update);
router.delete('/:id', WeatherController.delete);

// Route de synchronisation
router.post('/sync', WeatherController.syncData);

module.exports = router;
