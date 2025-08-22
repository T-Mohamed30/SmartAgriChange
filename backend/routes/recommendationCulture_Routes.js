const express = require('express');
const router = express.Router();
const recommendationCultureController = require('../controllers/recommendationCulture_Controller');

router.post('/', recommendationCultureController.createRecommendation);
router.get('/', recommendationCultureController.getAllRecommendations);
router.get('/:id', recommendationCultureController.getRecommendationById);
router.put('/:id', recommendationCultureController.updateRecommendation);
router.delete('/:id', recommendationCultureController.deleteRecommendation);

module.exports = router;
