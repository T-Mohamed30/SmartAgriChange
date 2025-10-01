const { AttributPlante } = require('../models');

exports.getForPlante = async (req, res) => {
  try {
    const attrs = await AttributPlante.findAll({ where: { id_plante: req.params.planteId } });
    res.json(attrs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createForPlante = async (req, res) => {
  try {
    const body = { ...req.body, id_plante: req.params.planteId };
    const a = await AttributPlante.create(body);
    res.status(201).json(a);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};
