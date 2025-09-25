const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const AnalyseSol = require('./analyseSol');
const EspeceVegetale = require('./especeVegetale');

const Recommandation = sequelize.define('Recommandation', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  analyse_sol_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: AnalyseSol,
      key: 'id'
    }
  },
  espece_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: EspeceVegetale,
      key: 'id'
    }
  },
  score_compatibility: {
    type: DataTypes.DECIMAL(3,2),
    allowNull: false
  },
  details: {
    type: DataTypes.JSONB,
    allowNull: true
  }
}, {
  tableName: 'recommandations',
  timestamps: false
});

// Relations
AnalyseSol.hasMany(Recommandation, { foreignKey: 'analyse_sol_id', as: 'recommandations' });
Recommandation.belongsTo(AnalyseSol, { foreignKey: 'analyse_sol_id', as: 'analyse_sol' });

EspeceVegetale.hasMany(Recommandation, { foreignKey: 'espece_id', as: 'recommandations' });
Recommandation.belongsTo(EspeceVegetale, { foreignKey: 'espece_id', as: 'espece' });

module.exports = Recommandation;
