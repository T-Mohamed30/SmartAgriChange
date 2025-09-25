const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Morphologie = sequelize.define('Morphologie', {
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
  partie: {
    type: DataTypes.ENUM('racines', 'tronc', 'feuilles', 'fleurs', 'fruits', 'tige', 'bourgeons', 'ecorce'),
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  caracteristiques: {
    type: DataTypes.JSON,
    allowNull: true
  },
  image_url: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  tableName: 'morphologies',
  timestamps: false
});

module.exports = Morphologie;
