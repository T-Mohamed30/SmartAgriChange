const { AnalysePlante, AnalyseAnomalie, Anomalie, Image, Plante, sequelize } = require('../backend/models');

async function main() {
  try {
    await sequelize.authenticate();
    // Optional args: node scripts/create_simulated_analysis.js [image_url]
    const imageUrl = process.argv[2] || 'http://10.0.2.2:3000/uploads/analysis_images/test.jpg';

    const analyse = await AnalysePlante.create({ id_utilisateur: null, id_plante: null });

    // Optionally create image row if not a full http URL
    if (imageUrl && !imageUrl.startsWith('http')) {
      await Image.create({ chemin: imageUrl, entite_type: 'analyse', entite_id: analyse.id });
    }

    const anom = await Anomalie.findOne({ where: { nom: 'Tâches brunes' } });
    if (anom) {
      await AnalyseAnomalie.create({ id_analyse_plante: analyse.id, id_anomalie: anom.id });
    }

    const payload = {
      id: analyse.id,
      parcelle_id: null,
      utilisateur_id: null,
      image_url: imageUrl,
      plante_identifiee_id: null,
      confiance_identification: 0.85,
      anomalies_detectees: anom ? [anom.nom] : [],
      maladies_detectees: [],
      date_analyse: new Date().toISOString(),
      statut: 'done',
      planteIdentifiee: null
    };

    console.log(JSON.stringify(payload, null, 2));
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

main();
