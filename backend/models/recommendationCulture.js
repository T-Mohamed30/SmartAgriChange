const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const AnalyseSol = require('./analyseSol');
const Culture = require('./culture');

const RecommendationCulture = sequelize.define('RecommendationCulture', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  compatibilite: DataTypes.DECIMAL(5,2), // %
  conseils: DataTypes.TEXT
});

// Relations
RecommendationCulture.belongsTo(AnalyseSol, { foreignKey: 'id_analyse_sol' });
RecommendationCulture.belongsTo(Culture, { foreignKey: 'id_culture' });

module.exports = RecommendationCulture;
