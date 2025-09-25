const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const EspeceVegetale = require('./especeVegetale');

const GaleriePhoto = sequelize.define('GaleriePhoto', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  espece_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: EspeceVegetale,
      key: 'id'
    }
  },
  image_url: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.STRING,
    allowNull: true
  },
  type: {
    type: DataTypes.ENUM('feuille', 'fleur', 'fruit', 'maladie', 'autre'),
    allowNull: false
  }
}, {
  tableName: 'galerie_photos',
  timestamps: false
});

// Relations
EspeceVegetale.hasMany(GaleriePhoto, { foreignKey: 'espece_id', as: 'galerie' });
GaleriePhoto.belongsTo(EspeceVegetale, { foreignKey: 'espece_id', as: 'espece' });

module.exports = GaleriePhoto;
