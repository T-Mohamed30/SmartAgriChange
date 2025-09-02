const express = require('express');
const router = express.Router();
const analyseSolController = require('../controllers/analyseSol_Controller');

router.post('/', analyseSolController.createAnalyseSol);
router.get('/', analyseSolController.getAllAnalyseSol);
router.get('/:id', analyseSolController.getAnalyseSolById);
router.put('/:id', analyseSolController.updateAnalyseSol);
router.delete('/:id', analyseSolController.deleteAnalyseSol);

module.exports = router;
