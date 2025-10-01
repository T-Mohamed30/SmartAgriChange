const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AttributPlante = sequelize.define('AttributPlante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  id_plante: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  type_attribut: {
    type: DataTypes.ENUM('morphologie', 'soins', 'calendrier', 'conditions', 'zones', 'saisonnalite', 'problems', 'economie'),
    allowNull: false
  },
  libelle: {
    type: DataTypes.STRING,
    allowNull: false
  },
  valeur: {
    type: DataTypes.STRING,
    allowNull: false
  },
  valeur_num: {
    type: DataTypes.DECIMAL,
    allowNull: true
  },
  unite: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  tableName: 'attributs_plante',
  timestamps: true
});

module.exports = AttributPlante;
