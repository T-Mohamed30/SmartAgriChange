const { Anomalie, SolutionAnomalie, sequelize } = require('../backend/models');

async function main() {
  try {
    await sequelize.authenticate();
    console.log('DB connected');
    const anomalies = await Anomalie.findAll({ order: [['id', 'ASC']] });
    if (!anomalies.length) {
      console.log('No anomalies found');
      process.exit(0);
    }
    for (const a of anomalies) {
      console.log(`Anomalie #${a.id}: ${a.nom}`);
      console.log(`  description: ${a.description}`);
      console.log(`  symptomes: ${a.symptomes}`);
      console.log(`  causes: ${a.causes}`);
      const sols = await SolutionAnomalie.findAll({ where: { id_anomalie: a.id } });
      if (!sols.length) {
        console.log('    (no solutions)');
      } else {
        for (const s of sols) console.log(`    solution(${s.type_solution}): ${s.contenu}`);
      }
    }
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

main();
