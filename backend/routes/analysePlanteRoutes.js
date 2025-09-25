const express = require('express');
const router = express.Router();
const AnalysePlanteController = require('../controllers/analysePlanteController');
const auth = require('../middleware/auth');
const multer = require('multer');
const path = require('path');

// configure multer storage
const storage = multer.diskStorage({
	destination: function (req, file, cb) {
		cb(null, path.join(__dirname, '..', 'uploads', 'plant_images'));
	},
	filename: function (req, file, cb) {
		const unique = Date.now() + '-' + Math.round(Math.random() * 1E9);
		cb(null, unique + path.extname(file.originalname));
	}
});

const upload = multer({ storage });

// Toutes les routes nécessitent une authentification
router.use(auth);

// Routes pour les analyses de plantes
router.get('/', AnalysePlanteController.getAllByUser);
router.get('/stats', AnalysePlanteController.getStats);
router.get('/parcelle/:parcelleId', AnalysePlanteController.getByParcelle);
router.get('/parcelle', AnalysePlanteController.getByParcelle); // Analyses sans parcelle
router.get('/:id', AnalysePlanteController.getById);

// Routes de modification
router.post('/', AnalysePlanteController.create);
// Endpoint pour upload et analyse (multipart/form-data)
router.post('/analyser', upload.single('image'), AnalysePlanteController.analyser);
router.put('/:id', AnalysePlanteController.update);
router.delete('/:id', AnalysePlanteController.delete);

module.exports = router;
