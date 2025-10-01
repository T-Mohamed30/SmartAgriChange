const express = require('express');
const router = express.Router({ mergeParams: true });
const ctrl = require('../controllers/attributPlanteController');
const { verifyToken } = require('../middleware/auth');

router.get('/', ctrl.getForPlante);
router.post('/', verifyToken, ctrl.createForPlante);

module.exports = router;
