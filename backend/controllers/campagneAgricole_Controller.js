const { CampagneAgricole } = require('../models');

exports.createCampagneAgricole = async (req, res) => {
  try {
    const campagne = await CampagneAgricole.create(req.body);
    res.status(201).json(campagne);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllCampagnesAgricoles = async (req, res) => {
  try {
    const campagnes = await CampagneAgricole.findAll();
    res.json(campagnes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getCampagneAgricoleById = async (req, res) => {
  try {
    const campagne = await CampagneAgricole.findByPk(req.params.id);
    if (!campagne) return res.status(404).json({ error: 'Campagne not found' });
    res.json(campagne);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateCampagneAgricole = async (req, res) => {
  try {
    const [updated] = await CampagneAgricole.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Campagne not found' });
    const updatedCampagne = await CampagneAgricole.findByPk(req.params.id);
    res.json(updatedCampagne);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteCampagneAgricole = async (req, res) => {
  try {
    const deleted = await CampagneAgricole.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Campagne not found' });
    res.json({ message: 'Campagne deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
