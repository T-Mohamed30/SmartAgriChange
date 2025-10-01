const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const CategorieAnomalie = sequelize.define('CategorieAnomalie', {
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
  }
}, {
  tableName: 'categories_anomalie',
  timestamps: true
});

module.exports = CategorieAnomalie;
