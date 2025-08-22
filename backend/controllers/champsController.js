const { Champ } = require('../models');

exports.createChamps = async (req, res) => {
  try {
    const champ = await Champ.create(req.body);
    res.status(201).json(champ);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllChamps = async (req, res) => {
  try {
    const champs = await Champ.findAll();
    res.json(champs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getChampsById = async (req, res) => {
  try {
    const champ = await Champ.findByPk(req.params.id);
    if (!champ) return res.status(404).json({ error: 'Champ not found' });
    res.json(champ);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateChamps = async (req, res) => {
  try {
    const [updated] = await Champ.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Champ not found' });
    const updatedChamp = await Champ.findByPk(req.params.id);
    res.json(updatedChamp);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteChamps = async (req, res) => {
  try {
    const deleted = await Champ.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Champ not found' });
    res.json({ message: 'Champ deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
