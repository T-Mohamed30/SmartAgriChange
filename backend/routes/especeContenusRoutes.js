const express = require('express');
const router = express.Router();
const EspeceContenusController = require('../controllers/especeContenusController');
const auth = require('../middleware/auth');

// Toutes les routes nécessitent une authentification
router.use(auth);

// Routes pour les contenus des espèces végétales
router.get('/:especeId/contenus/:type', EspeceContenusController.getContenusByType);
router.get('/:especeId/contenus', EspeceContenusController.getAllContenus);
router.post('/:especeId/contenus', EspeceContenusController.create);
router.put('/contenus/:id', EspeceContenusController.update);
router.delete('/contenus/:id', EspeceContenusController.delete);

module.exports = router;
