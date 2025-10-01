const { AnalyseAnomalie, Anomalie } = require('../models');

exports.addAnomaliesToAnalyse = async (req, res) => {
  try {
    const analyseId = req.params.analyseId;
    const { anomalieIds } = req.body;
    if (!Array.isArray(anomalieIds)) return res.status(400).json({ error: 'anomalieIds must be an array' });

    // Insert each pair (ignore duplicates)
    for (const aId of anomalieIds) {
      await AnalyseAnomalie.findOrCreate({ where: { id_analyse_plante: analyseId, id_anomalie: aId } });
    }

    const associated = await AnalyseAnomalie.findAll({ where: { id_analyse_plante: analyseId } });
    res.json(associated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getAnomaliesForAnalyse = async (req, res) => {
  try {
    const analyseId = req.params.analyseId;
    const rows = await AnalyseAnomalie.findAll({ where: { id_analyse_plante: analyseId } });
    const ids = rows.map(r => r.id_anomalie);
    const anomalies = await Anomalie.findAll({ where: { id: ids } });
    res.json(anomalies);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
