const { DataTypes } = require('sequelize');
const sequelize = require('../config/database'); // à adapter à ta config

const Capteur = sequelize.define('Capteur', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  code_serie: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  type: {
    type: DataTypes.STRING, // ex: "portatif", "fixe"
    allowNull: false
  },
  date_activation: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
});

module.exports = Capteur;
