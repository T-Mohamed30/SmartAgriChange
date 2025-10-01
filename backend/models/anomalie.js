const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Anomalie = sequelize.define('Anomalie', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  symptomes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  causes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  id_categorie: {
    type: DataTypes.INTEGER,
    allowNull: true
  }
}, {
  tableName: 'anomalies',
  timestamps: true
});

module.exports = Anomalie;
