const { Parcelle } = require('../models');

exports.createParcelle = async (req, res) => {
  try {
    const parcelle = await Parcelle.create(req.body);
    res.status(201).json(parcelle);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllParcelles = async (req, res) => {
  try {
    const parcelles = await Parcelle.findAll();
    res.json(parcelles);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getParcelleById = async (req, res) => {
  try {
    const parcelle = await Parcelle.findByPk(req.params.id);
    if (!parcelle) return res.status(404).json({ error: 'Parcelle not found' });
    res.json(parcelle);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateParcelle = async (req, res) => {
  try {
    const [updated] = await Parcelle.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Parcelle not found' });
    const updatedParcelle = await Parcelle.findByPk(req.params.id);
    res.json(updatedParcelle);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteParcelle = async (req, res) => {
  try {
    const deleted = await Parcelle.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Parcelle not found' });
    res.json({ message: 'Parcelle deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
