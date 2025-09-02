const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const EtapeCulture = sequelize.define('EtapeCulture', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: DataTypes.TEXT,
  duree_jours: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  ordre: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  culture_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'cultures',
      key: 'id'
    }
  }
}, {
  tableName: 'etapes_culture',
  timestamps: true,
  underscored: true
});

module.exports = EtapeCulture;
