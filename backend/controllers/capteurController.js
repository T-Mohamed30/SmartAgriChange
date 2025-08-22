const { Capteur } = require('../models');

exports.createCapteur = async (req, res) => {
  try {
    const capteur = await Capteur.create(req.body);
    res.status(201).json(capteur);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllCapteurs = async (req, res) => {
  try {
    const capteurs = await Capteur.findAll();
    res.json(capteurs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getCapteurById = async (req, res) => {
  try {
    const capteur = await Capteur.findByPk(req.params.id);
    if (!capteur) return res.status(404).json({ error: 'Capteur not found' });
    res.json(capteur);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateCapteur = async (req, res) => {
  try {
    const [updated] = await Capteur.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Capteur not found' });
    const updatedCapteur = await Capteur.findByPk(req.params.id);
    res.json(updatedCapteur);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteCapteur = async (req, res) => {
  try {
    const deleted = await Capteur.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Capteur not found' });
    res.json({ message: 'Capteur deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
