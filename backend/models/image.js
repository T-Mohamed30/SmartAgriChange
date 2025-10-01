const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Image = sequelize.define('Image', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  chemin: {
    type: DataTypes.STRING,
    allowNull: false
  },
  entite_type: {
    type: DataTypes.ENUM('plante', 'anomalie', 'analyse'),
    allowNull: false
  },
  entite_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
}, {
  tableName: 'images',
  timestamps: true,
  indexes: [{ fields: ['entite_type', 'entite_id'] }]
});

module.exports = Image;
