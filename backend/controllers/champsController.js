const { Champ } = require('../models');

exports.createChamps = async (req, res) => {
  try {
    // Mapping des champs pour compatibilité Flutter
    const { name, location, nom, localite, ...rest } = req.body;
    const champ = await Champ.create({
      nom: nom || name,
      localite: localite || location,
      ...rest
    });
    res.status(201).json({
      id: champ.id,
      name: champ.nom,
      location: champ.localite,
      date_creation: champ.date_creation
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllChamps = async (req, res) => {
  try {
    const champs = await Champ.findAll();
    // Mapping pour le frontend
    const mapped = champs.map(champ => ({
      id: champ.id,
      name: champ.nom,
      location: champ.localite,
      date_creation: champ.date_creation
    }));
    res.json(mapped);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getChampsById = async (req, res) => {
  try {
    const champ = await Champ.findByPk(req.params.id);
    if (!champ) return res.status(404).json({ error: 'Champ not found' });
    res.json({
      id: champ.id,
      name: champ.nom,
      location: champ.localite,
      date_creation: champ.date_creation
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateChamps = async (req, res) => {
  try {
    const { name, location, nom, localite, ...rest } = req.body;
    const [updated] = await Champ.update({
      nom: nom || name,
      localite: localite || location,
      ...rest
    }, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Champ not found' });
    const updatedChamp = await Champ.findByPk(req.params.id);
    res.json({
      id: updatedChamp.id,
      name: updatedChamp.nom,
      location: updatedChamp.localite,
      date_creation: updatedChamp.date_creation
    });
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
