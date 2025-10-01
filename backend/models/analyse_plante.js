const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AnalysePlante = sequelize.define('AnalysePlante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  id_utilisateur: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  id_plante: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  date_analyse: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  score_sante: {
    type: DataTypes.INTEGER,
    allowNull: true
  }
}, {
  tableName: 'analyses_plante',
  timestamps: true
});

module.exports = AnalysePlante;
