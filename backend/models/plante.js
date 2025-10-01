const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Plante = sequelize.define('Plante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  nom_latin: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false
  },
  famille_botanique: {
    type: DataTypes.STRING,
    allowNull: false
  },
  genre: {
    type: DataTypes.STRING,
    allowNull: true
  },
  ordre: {
    type: DataTypes.STRING,
    allowNull: true
  },
  type: {
    type: DataTypes.STRING,
    allowNull: false
  },
  cycle_de_vie: {
    type: DataTypes.STRING,
    allowNull: false
  },
  zone_geographique: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  tableName: 'plantes',
  timestamps: true
});

module.exports = Plante;
