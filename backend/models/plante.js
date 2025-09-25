const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Plante = sequelize.define('Plante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nom_scientifique: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  nom_commun: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  famille_botanique: {
    type: DataTypes.STRING,
    allowNull: true
  },
  type: {
    type: DataTypes.ENUM('arbre', 'arbuste', 'plante_herbacée', 'plante_grimpante', 'céréale', 'légume', 'fruit', 'autre'),
    allowNull: true
  },
  cycle_vie: {
    type: DataTypes.ENUM('annuel', 'bisannuel', 'vivace', 'pérenne'),
    allowNull: true
  },
  image_url: {
    type: DataTypes.STRING,
    allowNull: true
  },
  galerie_photos: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  est_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'plantes',
  timestamps: false
});

module.exports = Plante;
