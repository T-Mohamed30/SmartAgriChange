const { SolutionAnomalie } = require('../models');

exports.getAllForAnomalie = async (req, res) => {
  try {
    const solutions = await SolutionAnomalie.findAll({ where: { id_anomalie: req.params.anomalieId } });
    res.json(solutions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createForAnomalie = async (req, res) => {
  try {
    const body = { ...req.body, id_anomalie: req.params.anomalieId };
    const s = await SolutionAnomalie.create(body);
    res.status(201).json(s);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.update = async (req, res) => {
  try {
    const [updated] = await SolutionAnomalie.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Solution not found' });
    const s = await SolutionAnomalie.findByPk(req.params.id);
    res.json(s);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const deleted = await SolutionAnomalie.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Solution not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
