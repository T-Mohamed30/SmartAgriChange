const fs = require('fs');
const path = require('path');
const { AnalysePlante, Image, Anomalie, AnalyseAnomalie, Plante } = require('../models');

const UPLOAD_DIR = path.join(__dirname, '..', 'uploads', 'analysis_images');
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

// Simple fake analyser : returns random score and empty anomalies for now
function fakeAnalyse() {
  const score = Math.floor(Math.random() * 61) + 40; // 40..100
  return { score_sante: score, details: {} };
}

exports.analyser = async (req, res) => {
  try {
    const { parcelle_id } = req.body; // Optional now
    let imagePath = null;

    // Multipart upload handled by multer (route will provide req.file)
    if (req.file && req.file.path) {
      imagePath = req.file.path.replace(/\\/g, '/');
    } else if (req.body.image_base64) {
      // Save base64 image
      const matches = req.body.image_base64.match(/^data:(image\/.+);base64,(.+)$/);
      const data = matches ? matches[2] : req.body.image_base64;
      const buffer = Buffer.from(data, 'base64');
      const filename = `analyse_${Date.now()}.jpg`;
      const dest = path.join(UPLOAD_DIR, filename);
      fs.writeFileSync(dest, buffer);
      imagePath = dest.replace(/\\/g, '/');
    }

  // Persist analyse (store minimal info)
  const analyse = await AnalysePlante.create({ id_utilisateur: req.user ? req.user.id : null, id_plante: 1 }); // Fake identified plant

    // Persist image record if present
    let imageUrl = null;
    if (imagePath) {
      // store image record with chemin as saved path
      await Image.create({ chemin: imagePath, entite_type: 'analyse', entite_id: analyse.id });
      // Build a public URL for the frontend. We assume uploads are served at /uploads
      const filename = require('path').basename(imagePath);
      imageUrl = `${req.protocol}://${req.get('host')}/uploads/analysis_images/${filename}`;
    }

    // Perform fake analysis and store score_sante
    const result = fakeAnalyse();
    analyse.score_sante = result.score_sante;
    await analyse.save();

    // Fetch identified plant
    const plante = await Plante.findByPk(analyse.id_plante);

    // Build response shaped for frontend AnalysePlante.fromJson
    const payload = {
      id: analyse.id,
      parcelle_id: parcelle_id || null,
      utilisateur_id: req.user ? req.user.id : null,
      image_url: imageUrl,
      plante_identifiee_id: analyse.id_plante || null,
      confiance_identification: null,
      anomalies_detectees: [],
      maladies_detectees: [],
      date_analyse: analyse.date_analyse ? analyse.date_analyse.toISOString() : new Date().toISOString(),
      statut: 'done',
      planteIdentifiee: plante ? {
        id: plante.id,
        nom_scientifique: plante.nom_latin || '',
        nom_commun: plante.nom || '',
        description: plante.description || null,
        famille_botanique: plante.famille_botanique || null,
        type: plante.type || null,
        cycle_vie: plante.cycle_de_vie || null,
        image_url: null,
        galerie_photos: null,
        est_active: true,
        maladies: null
      } : null
    };

    return res.status(201).json(payload);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

exports.getAnalyseById = async (req, res) => {
  try {
    // Load analyse and related images & optional identified plant
    const analyse = await AnalysePlante.findByPk(req.params.id, {
      include: [
        { model: Image, where: { entite_type: 'analyse', entite_id: req.params.id }, required: false, as: 'images' },
        { model: Plante, as: 'plante', required: false }
      ]
    });

    if (!analyse) return res.status(404).json({ error: 'Analyse not found' });

    // Build image_url from first image if exists
    let imageUrl = null;
    const images = await Image.findAll({ where: { entite_type: 'analyse', entite_id: analyse.id } });
    if (images && images.length > 0) {
      const filename = require('path').basename(images[0].chemin);
      imageUrl = `${req.protocol}://${req.get('host')}/uploads/analysis_images/${filename}`;
    }

    // Gather anomalies associated with this analyse
    const analyseAnomRows = await AnalyseAnomalie.findAll({ where: { id_analyse_plante: analyse.id } });
    const anomIds = analyseAnomRows.map(r => r.id_anomalie);
    const anomalies = anomIds.length ? await Anomalie.findAll({ where: { id: anomIds } }) : [];
    const anomalies_detectees = anomalies.map(a => a.nom);

    // For now maladies_detectees left empty (could be inferred from anomalies -> kategorization)
    const maladies_detectees = [];

    const payload = {
      id: analyse.id,
      parcelle_id: null,
      utilisateur_id: analyse.id_utilisateur || null,
      image_url: imageUrl,
      plante_identifiee_id: analyse.id_plante || null,
      confiance_identification: null,
      anomalies_detectees,
      maladies_detectees,
      date_analyse: analyse.date_analyse ? analyse.date_analyse.toISOString() : null,
      statut: analyse.score_sante != null ? 'done' : 'pending',
      planteIdentifiee: analyse.plante ? {
        id: analyse.plante.id,
        nom_scientifique: analyse.plante.nom_latin || analyse.plante.nom_latin || '',
        nom_commun: analyse.plante.nom || analyse.plante.nom || '',
        description: analyse.plante.description || null,
        famille_botanique: analyse.plante.famille_botanique || null,
        type: analyse.plante.type || null,
        cycle_vie: analyse.plante.cycle_de_vie || null,
        image_url: null,
        galerie_photos: null,
        est_active: true,
        maladies: null
      } : null
    };

    return res.json(payload);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
// Keep the file scoped to the simple functional exports above. Additional controller classes
// referencing other domain models were part of an earlier, larger feature set and are
// intentionally removed to prevent duplicate declarations and runtime errors.
