const express = require('express');
const router = express.Router();
const capteurController = require('../controllers/capteurController');

router.post('/', capteurController.createCapteur);
router.get('/', capteurController.getAllCapteurs);
router.get('/:id', capteurController.getCapteurById);
router.put('/:id', capteurController.updateCapteur);
router.delete('/:id', capteurController.deleteCapteur);

module.exports = router;
