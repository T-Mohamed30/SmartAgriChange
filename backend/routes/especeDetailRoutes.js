const express = require('express');
const router = express.Router();
const EspeceDetailController = require('../controllers/especeDetailController');
const auth = require('../middleware/auth');

// Toutes les routes nécessitent une authentification
router.use(auth);

// Routes pour les détails des espèces végétales
router.get('/:especeId/details', EspeceDetailController.getDetailsByEspece);
router.get('/:especeId/morphologie', EspeceDetailController.getMorphologie);
router.get('/:especeId/soins', EspeceDetailController.getSoins);
router.get('/:especeId/conditions', EspeceDetailController.getConditions);
router.get('/:especeId/problemes', EspeceDetailController.getProblemes);
router.get('/:especeId/galerie', EspeceDetailController.getGalerie);

module.exports = router;
