const express = require('express');
const router = express.Router();
const { AnalysePlante, AnalyseAnomalie, Anomalie, Image, Plante } = require('../models');
const path = require('path');

// Dev endpoint: create a simulated analyse and associate the 'Tâches brunes' anomalie
// This endpoint is intentionally NOT protected so it can be used during local development.
router.post('/simulate-analysis', async (req, res) => {
  try {
    // Optional body: { plante_id, image_url }
    const planteId = req.body.plante_id || null;
    const imageUrl = req.body.image_url || null; // can be remote or local path

    // Create analyse
    const analyse = await AnalysePlante.create({ id_utilisateur: null, id_plante: planteId });

    // If image_url provided and looks like a local uploaded file path, store an Image row
    if (imageUrl) {
      // If it's a full URL, we won't store chemin; otherwise, store as chemin
      if (!imageUrl.startsWith('http')) {
        await Image.create({ chemin: imageUrl, entite_type: 'analyse', entite_id: analyse.id });
      }
    }

    // Try to find the 'Tâches brunes' anomaly
    const anom = await Anomalie.findOne({ where: { nom: 'Tâches brunes' } });
    if (anom) {
      await AnalyseAnomalie.create({ id_analyse_plante: analyse.id, id_anomalie: anom.id });
    }

    // Build payload similar to getAnalyseById
    const images = imageUrl ? [{ chemin: imageUrl }] : [];
    const anomalies = anom ? [anom.nom] : [];

    const payload = {
      id: analyse.id,
      parcelle_id: null,
      utilisateur_id: null,
      image_url: imageUrl,
      plante_identifiee_id: planteId || null,
      confiance_identification: 0.85,
      anomalies_detectees: anomalies,
      maladies_detectees: [],
      date_analyse: new Date().toISOString(),
      statut: 'done',
      planteIdentifiee: null
    };

    return res.json(payload);
  } catch (err) {
    console.error('simulate-analysis error', err);
    return res.status(500).json({ error: err.message });
  }
});

module.exports = router;
