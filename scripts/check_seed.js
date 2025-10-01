const { Plante, Anomalie, sequelize } = require('../backend/models');

async function main() {
  try {
    await sequelize.authenticate();
    console.log('DB connected');

    const plante = await Plante.findOne({ where: { nom_latin: 'Vigna unguiculata' } });
    if (plante) {
      console.log(`Plante found: id=${plante.id}, nom='${plante.nom}', nom_latin='${plante.nom_latin}'`);
    } else {
      console.log('Plante Vigna unguiculata not found');
    }

    const anomalies = await Anomalie.findAll({ order: [['id','ASC']] });
    console.log(`Anomalies count: ${anomalies.length}`);
    for (const a of anomalies) {
      console.log(`- #${a.id}: ${a.nom}`);
    }

    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

main();
