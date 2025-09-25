const express = require('express');
const router = express.Router();
const EspeceVegetaleController = require('../controllers/especeVegetaleController');
const auth = require('../middleware/auth');

// Toutes les routes nécessitent une authentification
router.use(auth);

// Routes pour les espèces végétales
router.get('/', EspeceVegetaleController.getAll);
router.get('/:id', EspeceVegetaleController.getById);
router.get('/:id/optimal-params', EspeceVegetaleController.getOptimalParams);

// Routes admin (à sécuriser davantage si nécessaire)
router.post('/', EspeceVegetaleController.create);
router.put('/:id', EspeceVegetaleController.update);
router.delete('/:id', EspeceVegetaleController.delete);

module.exports = router;
