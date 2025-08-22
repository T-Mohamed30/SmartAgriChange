const express = require('express');
const router = express.Router();
const champsController = require('../controllers/champsController');

router.post('/', champsController.createChamps);
router.get('/', champsController.getAllChamps);
router.get('/:id', champsController.getChampsById);
router.put('/:id', champsController.updateChamps);
router.delete('/:id', champsController.deleteChamps);

module.exports = router;
