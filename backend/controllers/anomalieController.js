const { Anomalie, SolutionAnomalie } = require('../models');

exports.getAll = async (req, res) => {
  try {
    const where = {};
    if (req.query.categorieId) where.id_categorie = req.query.categorieId;
    const list = await Anomalie.findAll({ where });
    res.json(list);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getById = async (req, res) => {
  try {
    const a = await Anomalie.findByPk(req.params.id);
    if (!a) return res.status(404).json({ error: 'Anomalie not found' });
    const solutions = await SolutionAnomalie.findAll({ where: { id_anomalie: a.id } });
    res.json({ ...a.toJSON(), solutions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.create = async (req, res) => {
  try {
    const a = await Anomalie.create(req.body);
    res.status(201).json(a);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.update = async (req, res) => {
  try {
    const [updated] = await Anomalie.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Anomalie not found' });
    const a = await Anomalie.findByPk(req.params.id);
    res.json(a);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const deleted = await Anomalie.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Anomalie not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
