const express = require('express');
const router = express.Router({ mergeParams: true });
const ctrl = require('../controllers/solutionAnomalieController');
const { verifyToken } = require('../middleware/auth');

router.get('/', ctrl.getAllForAnomalie);
router.post('/', verifyToken, ctrl.createForAnomalie);

// separate update/delete by id
const express2 = require('express');
const outer = express2.Router();
outer.put('/:id', verifyToken, ctrl.update);
outer.delete('/:id', verifyToken, ctrl.delete);

module.exports = { nested: router, single: outer };
