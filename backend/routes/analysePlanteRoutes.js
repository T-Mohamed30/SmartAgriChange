const express = require('express');
const router = express.Router();
const analyseController = require('../controllers/analysePlanteController');
const { verifyToken } = require('../middleware/auth');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
	destination: function (req, file, cb) {
		cb(null, path.join(__dirname, '..', 'uploads', 'analysis_images'));
	},
	filename: function (req, file, cb) {
		const ext = path.extname(file.originalname) || '.jpg';
		cb(null, `upload_${Date.now()}${ext}`);
	}
});

const upload = multer({ storage });

// POST multipart or JSON (image_base64)
router.post('/analyser', verifyToken, upload.single('image'), analyseController.analyser);
router.get('/:id', verifyToken, analyseController.getAnalyseById);
router.get('/', verifyToken, async (req, res) => res.json({ message: 'Liste minimale: utilisez /:id pour récupérer une analyse' }));

module.exports = router;
