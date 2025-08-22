const { sequelize } = require('./models');

async function syncDB() {
  try {
    await sequelize.authenticate();
    console.log('Connexion à la base réussie !');

    await sequelize.sync({ alter: true }); // alter: true pour mettre à jour le schéma sans perdre les données
    console.log('Tous les modèles ont été synchronisés !');
    
    process.exit(0);
  } catch (error) {
    console.error('Erreur lors de la synchronisation :', error);
  }
}

syncDB();
