const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ContexteEconomique = sequelize.define('ContexteEconomique', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  plante_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'plantes',
      key: 'id'
    }
  },
  importance_economique: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  contexte_local: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  valeur_marche: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  saison_production: {
    type: DataTypes.ENUM('toute_annee', 'saison_pluies', 'saison_seche', 'printemps', 'ete', 'automne', 'hiver'),
    allowNull: true
  }
}, {
  tableName: 'contexte_economique',
  timestamps: false
});

module.exports = ContexteEconomique;
