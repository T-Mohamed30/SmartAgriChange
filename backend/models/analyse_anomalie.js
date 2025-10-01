const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AnalyseAnomalie = sequelize.define('AnalyseAnomalie', {
  id_analyse_plante: {
    type: DataTypes.INTEGER,
    primaryKey: true
  },
  id_anomalie: {
    type: DataTypes.INTEGER,
    primaryKey: true
  }
}, {
  tableName: 'analyse_anomalie',
  timestamps: false
});

module.exports = AnalyseAnomalie;
