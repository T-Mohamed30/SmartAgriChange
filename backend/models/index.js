const sequelize = require('../config/database');

// Import des modèles conservés
const User = require('./user');
const Champ = require('./champs');
const Parcelle = require('./parcelle');
const Capteur = require('./capteur');

// Nouveaux modèles
const Plante = require('./plante');
const AttributPlante = require('./attribut_plante');
const AnalysePlante = require('./analyse_plante');
const Anomalie = require('./anomalie');
const SolutionAnomalie = require('./solution_anomalie');
const CategorieAnomalie = require('./categorie_anomalie');
const AnalyseAnomalie = require('./analyse_anomalie');
const Image = require('./image');

// Relations minimales
User.hasMany(Champ, { foreignKey: 'id_utilisateur', onDelete: 'CASCADE' });
Champ.belongsTo(User, { foreignKey: 'id_utilisateur' });

Champ.hasMany(Parcelle, { foreignKey: 'id_champ', onDelete: 'CASCADE' });
Parcelle.belongsTo(Champ, { foreignKey: 'id_champ' });

// Relations plantes
Plante.hasMany(AttributPlante, { foreignKey: 'id_plante', as: 'attributs' });
AttributPlante.belongsTo(Plante, { foreignKey: 'id_plante', as: 'plante' });

Plante.hasMany(Image, { foreignKey: 'entite_id', scope: { entite_type: 'plante' }, as: 'images' });

AnalysePlante.belongsTo(Plante, { foreignKey: 'id_plante', as: 'plante' });
AnalysePlante.belongsTo(User, { foreignKey: 'id_utilisateur', as: 'utilisateur' });

// Export des modèles
module.exports = {
  sequelize,
  User,
  Champ,
  Parcelle,
  Capteur,
  Plante,
  AttributPlante,
  AnalysePlante,
  Anomalie,
  SolutionAnomalie,
  CategorieAnomalie,
  AnalyseAnomalie,
  Image
};
