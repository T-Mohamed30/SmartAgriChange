const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SoinsCulture = sequelize.define('SoinsCulture', {
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
  type_soin: {
    type: DataTypes.ENUM('eau', 'fertilisation', 'taille', 'propagation', 'calendrier', 'protection', 'recolte'),
    allowNull: false
  },
  titre: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  instructions: {
    type: DataTypes.JSON,
    allowNull: true
  },
  frequence: {
    type: DataTypes.STRING,
    allowNull: true
  },
  periode_optimale: {
    type: DataTypes.STRING,
    allowNull: true
  },
  materiel_necessaire: {
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('materiel_necessaire');
      return v == null ? [] : v;
    }
  }
}, {
  tableName: 'soins_culture',
  timestamps: false
});

module.exports = SoinsCulture;
