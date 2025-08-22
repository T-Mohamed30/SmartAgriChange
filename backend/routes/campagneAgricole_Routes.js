const express = require('express');
const router = express.Router();
const campagneAgricoleController = require('../controllers/campagneAgricole_Controller');

router.post('/', campagneAgricoleController.createCampagneAgricole);
router.get('/', campagneAgricoleController.getAllCampagnesAgricoles);
router.get('/:id', campagneAgricoleController.getCampagneAgricoleById);
router.put('/:id', campagneAgricoleController.updateCampagneAgricole);
router.delete('/:id', campagneAgricoleController.deleteCampagneAgricole);

module.exports = router;
