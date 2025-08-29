const { Parcelle } = require('../models');

exports.createParcelle = async (req, res) => {
  try {
    // Mapping des champs pour compatibilité Flutter
    const { name, superficie, champId, nom, id_champ, ...rest } = req.body;
    const parcelle = await Parcelle.create({
      nom: nom || name,
      superficie,
      id_champ: id_champ || champId,
      ...rest
    });
    res.status(201).json({
      id: parcelle.id,
      name: parcelle.nom,
      superficie: parcelle.superficie,
      champId: parcelle.id_champ,
      date_creation: parcelle.date_creation
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllParcelles = async (req, res) => {
  try {
    const { champId } = req.query;
    let parcelles;
    if (champId) {
      parcelles = await Parcelle.findAll({ where: { id_champ: champId } });
    } else {
      parcelles = await Parcelle.findAll();
    }
    // Mapping pour le frontend
    const mapped = parcelles.map(parcelle => ({
      id: parcelle.id,
      name: parcelle.nom,
      superficie: parcelle.superficie,
      champId: parcelle.id_champ,
      date_creation: parcelle.date_creation
    }));
    res.json(mapped);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getParcelleById = async (req, res) => {
  try {
    const parcelle = await Parcelle.findByPk(req.params.id);
    if (!parcelle) return res.status(404).json({ error: 'Parcelle not found' });
    res.json({
      id: parcelle.id,
      name: parcelle.nom,
      superficie: parcelle.superficie,
      champId: parcelle.id_champ,
      date_creation: parcelle.date_creation
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateParcelle = async (req, res) => {
  try {
    const { name, superficie, champId, nom, id_champ, ...rest } = req.body;
    const [updated] = await Parcelle.update({
      nom: nom || name,
      superficie,
      id_champ: id_champ || champId,
      ...rest
    }, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Parcelle not found' });
    const updatedParcelle = await Parcelle.findByPk(req.params.id);
    res.json({
      id: updatedParcelle.id,
      name: updatedParcelle.nom,
      superficie: updatedParcelle.superficie,
      champId: updatedParcelle.id_champ,
      date_creation: updatedParcelle.date_creation
    });
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
