const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Culture = sequelize.define('Culture', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  type_sol_ideal: DataTypes.STRING,
  ph_min: DataTypes.FLOAT,
  ph_max: DataTypes.FLOAT,
  humidite_min: DataTypes.FLOAT,
  humidite_max: DataTypes.FLOAT,
  temperature_min: DataTypes.FLOAT,
  temperature_max: DataTypes.FLOAT,
  ec_min: DataTypes.FLOAT,
  ec_max: DataTypes.FLOAT,
  azote_min: DataTypes.FLOAT,
  azote_max: DataTypes.FLOAT,
  phosphore_min: DataTypes.FLOAT,
  phosphore_max: DataTypes.FLOAT,
  potassium_min: DataTypes.FLOAT,
  potassium_max: DataTypes.FLOAT,
  type_engrais: DataTypes.STRING,
  duree_cycle_semaines: DataTypes.INTEGER,
  rendement_moyen: {
    type: DataTypes.STRING,
    allowNull: true
  },
  besoins_eau: {
    type: DataTypes.STRING,
    allowNull: true
  },
  resistance_secheresse: {
    type: DataTypes.STRING,
    allowNull: true
  },
  saison_ideale: DataTypes.ENUM('Saison des pluies', 'Saison sèche fraîche', 'Saison sèche chaude')
});

module.exports = Culture;
