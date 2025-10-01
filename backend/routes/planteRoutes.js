const express = require('express');
const router = express.Router();
const planteController = require('../controllers/planteController');

router.post('/', planteController.createPlante);
router.get('/', planteController.getPlantes);
router.get('/:id', planteController.getPlanteById);

module.exports = router;
