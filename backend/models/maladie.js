const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Maladie = sequelize.define('Maladie', {
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
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  causes: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  traitement: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  prevention: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  plante_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'plantes',
      key: 'id'
    }
  },
  gravite: {
    type: DataTypes.ENUM('faible', 'moyenne', 'elevee'),
    defaultValue: 'moyenne'
  }
}, {
  tableName: 'maladies',
  timestamps: false
});

module.exports = Maladie;
