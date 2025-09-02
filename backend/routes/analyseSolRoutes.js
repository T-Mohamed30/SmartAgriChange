const express = require('express');
const router = express.Router();
const analyseSolController = require('../controllers/analyseSolController');
const auth = require('../middleware/auth');

// Appliquer le middleware d'authentification à toutes les routes
router.use(auth);

// Routes pour les analyses de sol
router.post('/analyses', analyseSolController.creerAnalyseSol);
router.get('/parcelles/:parcelle_id/historique', analyseSolController.getHistoriqueAnalyses);
router.get('/analyses/:id', analyseSolController.getAnalyseDetails);

// Routes pour les campagnes agricoles
router.post('/campagnes', analyseSolController.demarrerCampagne);

module.exports = router;
