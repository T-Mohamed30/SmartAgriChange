const express = require('express');
const router = express.Router();
const parcelleController = require('../controllers/parcelleController');

router.post('/', parcelleController.createParcelle);
router.get('/', parcelleController.getAllParcelles);
router.get('/:id', parcelleController.getParcelleById);
router.put('/:id', parcelleController.updateParcelle);
router.delete('/:id', parcelleController.deleteParcelle);

module.exports = router;
