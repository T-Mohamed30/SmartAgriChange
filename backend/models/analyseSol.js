const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Capteur = require('./capteur');
const Parcelle = require('./parcelle');
const User = require('./user');

const AnalyseSol = sequelize.define('AnalyseSol', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  ph: DataTypes.FLOAT,
  humidite: DataTypes.FLOAT,
  temperature: DataTypes.FLOAT,
  ec: DataTypes.FLOAT,
  azote: DataTypes.FLOAT,
  phosphore: DataTypes.FLOAT,
  potassium: DataTypes.FLOAT,
  gps_latitude: DataTypes.FLOAT,
  gps_longitude: DataTypes.FLOAT,
  description: DataTypes.STRING,
  date_creation: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
});

// Relations
AnalyseSol.belongsTo(Parcelle, { foreignKey: 'id_parcelle' });
AnalyseSol.belongsTo(User, { foreignKey: 'id_utilisateur' });
AnalyseSol.belongsTo(Capteur, { foreignKey: 'id_capteur' });

module.exports = AnalyseSol;
