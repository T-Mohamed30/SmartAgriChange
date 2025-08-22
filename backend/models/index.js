const sequelize = require('../config/database');

// Import des modèles
const User = require('./user');
const Champ = require('./champs');
const Parcelle = require('./parcelle');
const Capteur = require('./capteur');
const AnalyseSol = require('./analyseSol');
const Culture = require('./culture');
const RecommendationCulture = require('./recommendationCulture');
const CampagneAgricole = require('./campagneAgricole');

// ----------------- Relations -----------------

// User -> Champ : 1–N
User.hasMany(Champ, { foreignKey: 'id_utilisateur', onDelete: 'CASCADE' });
Champ.belongsTo(User, { foreignKey: 'id_utilisateur' });

// Champ -> Parcelle : 1–N
Champ.hasMany(Parcelle, { foreignKey: 'id_champ', onDelete: 'CASCADE' });
Parcelle.belongsTo(Champ, { foreignKey: 'id_champ' });

// Parcelle -> AnalyseSol : 1–N
Parcelle.hasMany(AnalyseSol, { foreignKey: 'id_parcelle', onDelete: 'SET NULL' });
AnalyseSol.belongsTo(Parcelle, { foreignKey: 'id_parcelle' });

// User -> AnalyseSol : 1–N
User.hasMany(AnalyseSol, { foreignKey: 'id_utilisateur', onDelete: 'SET NULL' });
AnalyseSol.belongsTo(User, { foreignKey: 'id_utilisateur' });

// Capteur -> AnalyseSol : 1–N
Capteur.hasMany(AnalyseSol, { foreignKey: 'id_capteur', onDelete: 'SET NULL' });
AnalyseSol.belongsTo(Capteur, { foreignKey: 'id_capteur' });

// AnalyseSol -> RecommendationCulture : 1–N
AnalyseSol.hasMany(RecommendationCulture, { foreignKey: 'id_analyse_sol', onDelete: 'CASCADE' });
RecommendationCulture.belongsTo(AnalyseSol, { foreignKey: 'id_analyse_sol' });

// Culture -> RecommendationCulture : 1–N
Culture.hasMany(RecommendationCulture, { foreignKey: 'id_culture', onDelete: 'CASCADE' });
RecommendationCulture.belongsTo(Culture, { foreignKey: 'id_culture' });

// Parcelle -> CampagneAgricole : 1–N
Parcelle.hasMany(CampagneAgricole, { foreignKey: 'id_parcelle', onDelete: 'CASCADE' });
CampagneAgricole.belongsTo(Parcelle, { foreignKey: 'id_parcelle' });

// Culture -> CampagneAgricole : 1–N
Culture.hasMany(CampagneAgricole, { foreignKey: 'id_culture', onDelete: 'CASCADE' });
CampagneAgricole.belongsTo(Culture, { foreignKey: 'id_culture' });

// Export des modèles
module.exports = {
  sequelize,
  User,
  Champ,
  Parcelle,
  Capteur,
  AnalyseSol,
  Culture,
  RecommendationCulture,
  CampagneAgricole
};
