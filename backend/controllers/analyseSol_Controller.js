const { AnalyseSol } = require('../models');

exports.createAnalyseSol = async (req, res) => {
  try {
    const analyse = await AnalyseSol.create(req.body);
    res.status(201).json(analyse);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllAnalyseSol = async (req, res) => {
  try {
    const analyses = await AnalyseSol.findAll();
    res.json(analyses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getAnalyseSolById = async (req, res) => {
  try {
    const analyse = await AnalyseSol.findByPk(req.params.id);
    if (!analyse) return res.status(404).json({ error: 'Analyse not found' });
    res.json(analyse);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateAnalyseSol = async (req, res) => {
  try {
    const [updated] = await AnalyseSol.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Analyse not found' });
    const updatedAnalyse = await AnalyseSol.findByPk(req.params.id);
    res.json(updatedAnalyse);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteAnalyseSol = async (req, res) => {
  try {
    const deleted = await AnalyseSol.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Analyse not found' });
    res.json({ message: 'Analyse deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
