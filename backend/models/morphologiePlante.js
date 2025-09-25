const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MorphologiePlante = sequelize.define('MorphologiePlante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  plante_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'plantes',
      key: 'id'
    }
  },
  partie: {
    type: DataTypes.ENUM('racines', 'tronc', 'feuilles', 'fleurs', 'fruits'),
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  image_url: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  tableName: 'morphologie_plantes',
  timestamps: false
});

module.exports = MorphologiePlante;
