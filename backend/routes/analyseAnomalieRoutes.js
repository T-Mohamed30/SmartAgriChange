const express = require('express');
const router = express.Router({ mergeParams: true });
const ctrl = require('../controllers/analyseAnomalieController');
const { verifyToken } = require('../middleware/auth');

router.post('/', verifyToken, ctrl.addAnomaliesToAnalyse);
router.get('/', verifyToken, ctrl.getAnomaliesForAnalyse);

module.exports = router;
