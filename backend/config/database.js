// backend/config/database.js

const { Sequelize } = require('sequelize');
require('dotenv').config();

const env = process.env.NODE_ENV || 'development';

let sequelize;

if (env === 'offline') {
  // Mode OFFLINE : SQLite
  sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: './database_offline.sqlite', // fichier SQLite local
    logging: console.log, // ou false si tu veux désactiver les logs SQL
  });

  sequelize
    .authenticate()
    .then(() => console.log('✅ Connexion réussie en mode OFFLINE (SQLite) !'))
    .catch(err => console.error('❌ Erreur de connexion SQLite :', err));

} else {

  // Mode ONLINE : PostgreSQL
  sequelize = new Sequelize(
    process.env.PG_DATABASE,
    process.env.PG_USER,
    process.env.PG_PASSWORD,
    {
      host: process.env.PG_HOST,
      dialect: 'postgres',
      logging: console.log, // ou false
      dialectOptions: {
        // pour éviter les soucis de mot de passe SCRAM-SHA-256
        ssl: false,
      },
    }
  );

  sequelize
    .authenticate()
    .then(() => console.log('✅ Connexion réussie à PostgreSQL !'))
    .catch(err => console.error('❌ Erreur de connexion PostgreSQL :', err));
}

// Synchronisation automatique des tables
sequelize
  .sync({ alter: true })
  .then(() => console.log('📦 Tables synchronisées !'))
  .catch(err => console.error('❌ Erreur lors de la synchronisation des tables :', err));

module.exports = sequelize;
