const express = require('express');
const router = express.Router();
const campagneController = require('../controllers/campagneController');
const auth = require('../middleware/auth');

// Appliquer le middleware d'authentification à toutes les routes
router.use(auth);

// Routes pour les campagnes
router.post('/', campagneController.creerCampagne);
router.get('/', campagneController.getCampagnesUtilisateur);
router.get('/:id', campagneController.getCampagneDetails);
router.put('/:id/etapes/:etapeId/statut', campagneController.mettreAJourStatutEtape);
router.put('/:id/taches/:tacheId/statut', campagneController.mettreAJourStatutTache);
router.delete('/:id', campagneController.supprimerCampagne);

module.exports = router;
