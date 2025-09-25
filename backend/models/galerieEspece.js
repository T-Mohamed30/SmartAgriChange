const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const GalerieEspece = sequelize.define('GalerieEspece', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  espece_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'especes_vegetales',
      key: 'id'
    }
  },
  image_url: {
    type: DataTypes.STRING,
    allowNull: false
  },
  titre: {
    type: DataTypes.STRING,
    allowNull: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  type_image: {
    type: DataTypes.ENUM('morphologie', 'culture', 'probleme', 'recolte', 'generale'),
    allowNull: false,
    defaultValue: 'generale'
  },
  ordre_affichage: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0
  }
}, {
  tableName: 'galerie_espece',
  timestamps: false
});

module.exports = GalerieEspece;
