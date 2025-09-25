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
  analyse_sol_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'analyses_sols',
      key: 'id'
    }
  },
  culture_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'cultures',
      key: 'id'
    }
  },
  score_compatibilite: {
    type: DataTypes.DECIMAL(5,2),
    allowNull: false
  },
  details: {
    type: DataTypes.JSON,
    allowNull: true
  },
  recommandation: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  date_creation: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
});

// Relations
RecommendationCulture.belongsTo(AnalyseSol, { foreignKey: 'id_analyse_sol' });
RecommendationCulture.belongsTo(Culture, { foreignKey: 'id_culture' });

module.exports = RecommendationCulture;
