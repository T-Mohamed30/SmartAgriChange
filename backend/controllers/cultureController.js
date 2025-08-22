const { Culture } = require('../models');

exports.createCulture = async (req, res) => {
  try {
    const culture = await Culture.create(req.body);
    res.status(201).json(culture);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllCultures = async (req, res) => {
  try {
    const cultures = await Culture.findAll();
    res.json(cultures);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getCultureById = async (req, res) => {
  try {
    const culture = await Culture.findByPk(req.params.id);
    if (!culture) return res.status(404).json({ error: 'Culture not found' });
    res.json(culture);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateCulture = async (req, res) => {
  try {
    const [updated] = await Culture.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Culture not found' });
    const updatedCulture = await Culture.findByPk(req.params.id);
    res.json(updatedCulture);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteCulture = async (req, res) => {
  try {
    const deleted = await Culture.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Culture not found' });
    res.json({ message: 'Culture deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
