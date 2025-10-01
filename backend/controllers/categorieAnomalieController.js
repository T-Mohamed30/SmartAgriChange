const { CategorieAnomalie } = require('../models');

exports.getAll = async (req, res) => {
  try {
    const cats = await CategorieAnomalie.findAll();
    res.json(cats);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getById = async (req, res) => {
  try {
    const cat = await CategorieAnomalie.findByPk(req.params.id);
    if (!cat) return res.status(404).json({ error: 'Categorie not found' });
    res.json(cat);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.create = async (req, res) => {
  try {
    const cat = await CategorieAnomalie.create(req.body);
    res.status(201).json(cat);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.update = async (req, res) => {
  try {
    const [updated] = await CategorieAnomalie.update(req.body, { where: { id: req.params.id } });
    if (!updated) return res.status(404).json({ error: 'Categorie not found' });
    const cat = await CategorieAnomalie.findByPk(req.params.id);
    res.json(cat);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const deleted = await CategorieAnomalie.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ error: 'Categorie not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
