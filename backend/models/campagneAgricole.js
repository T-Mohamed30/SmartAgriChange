const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Parcelle = require('./parcelle');
const Culture = require('./culture');

const CampagneAgricole = sequelize.define('CampagneAgricole', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  date_debut: DataTypes.DATE,
  date_fin: DataTypes.DATE,
  statut: DataTypes.ENUM('En préparation', 'En cours', 'Terminé'),
  rendement: DataTypes.FLOAT
});

// Relations
CampagneAgricole.belongsTo(Parcelle, { foreignKey: 'id_parcelle' });
CampagneAgricole.belongsTo(Culture, { foreignKey: 'id_culture' });

module.exports = CampagneAgricole;
