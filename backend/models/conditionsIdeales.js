const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ConditionsIdeales = sequelize.define('ConditionsIdeales', {
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
  type_condition: {
    type: DataTypes.ENUM('temperature', 'sol', 'lumiere', 'zones_culture', 'saisonnalite'),
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
  valeur_min: {
    type: DataTypes.STRING,
    allowNull: true
  },
  valeur_max: {
    type: DataTypes.STRING,
    allowNull: true
  },
  valeur_optimale: {
    type: DataTypes.STRING,
    allowNull: true
  },
  unite: {
    type: DataTypes.STRING,
    allowNull: true
  },
  conseils: {
    type: DataTypes.JSON,
    allowNull: true
  }
}, {
  tableName: 'conditions_ideales',
  timestamps: false
});

module.exports = ConditionsIdeales;
