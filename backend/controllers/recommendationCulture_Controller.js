const { Recommendation } = require('../models');

exports.createRecommendation = async (req, res) => {
  try {
    const recommendation = await Recommendation.create(req.body);
    res.status(201).json(recommendation);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllRecommendations = async (req, res) => {
  try {
    const recommendations = await Recommendation.findAll();
    res.json(recommendations);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getRecommendationById = async (req, res) => {
  try {
    const recommendation = await Recommendation.findByPk(req.params.id);
    if (!recommendation) return res.status(404).json({ error: 'Recommendation not found' });
    res.json(recommendation);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateRecommendation = async (req, res) => {
  try {
    const [updated] = await Recommendation.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Recommendation not found' });
    const updatedRecommendation = await Recommendation.findByPk(req.params.id);
    res.json(updatedRecommendation);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteRecommendation = async (req, res) => {
  try {
    const deleted = await Recommendation.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Recommendation not found' });
    res.json({ message: 'Recommendation deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
