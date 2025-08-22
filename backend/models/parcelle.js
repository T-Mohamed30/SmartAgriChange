const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Champ = require('./champs');

const Parcelle = sequelize.define('Parcelle', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  superficie: {
    type: DataTypes.FLOAT,
    allowNull: false
  },
  date_creation: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'parcelles',
  timestamps: false
});

// Relation : un champ contient plusieurs parcelles
Champ.hasMany(Parcelle, { foreignKey: 'id_champ', as: 'parcelles' });
Parcelle.belongsTo(Champ, { foreignKey: 'id_champ', as: 'champ' });

module.exports = Parcelle;
