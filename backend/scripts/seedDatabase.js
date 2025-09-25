const sequelize = require('../config/database');
const seedEspeceContenus = require('../seeders/especeContenusSeeder');

async function runSeeders() {
  try {
    console.log('🚀 Démarrage du seeding de la base de données...\n');

    // Synchroniser la base de données d'abord
    console.log('📦 Synchronisation des tables...');
    await sequelize.sync({ force: true });
    console.log('✅ Tables synchronisées !\n');

    await seedEspeceContenus();

    console.log('\n✅ Tous les seeders ont été exécutés avec succès !');
    console.log('📱 Vous pouvez maintenant tester l\'API avec les données du manguier');

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Erreur lors de l\'exécution des seeders :', error);
    process.exit(1);
  }
}

runSeeders();
