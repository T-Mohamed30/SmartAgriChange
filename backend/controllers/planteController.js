const { Plante, AttributPlante, Image } = require('../models');

exports.createPlante = async (req, res) => {
  try {
    const plante = await Plante.create(req.body);
    return res.status(201).json(plante);
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
};

exports.getPlantes = async (req, res) => {
  try {
    const plantes = await Plante.findAll({ include: [{ model: AttributPlante, as: 'attributs' }] });
    return res.json(plantes);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

exports.getPlanteById = async (req, res) => {
  try {
    const plante = await Plante.findByPk(req.params.id, { include: [{ model: AttributPlante, as: 'attributs' }] });
    if (!plante) return res.status(404).json({ error: 'Plante not found' });
    return res.json(plante);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
