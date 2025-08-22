const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const User = sequelize.define('Utilisateur', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  prenom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  telephone: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  mot_de_passe: {
    type: DataTypes.STRING,
    allowNull: false
  },
  role: {
    type: DataTypes.ENUM('agriculteur', 'admin'),
    defaultValue: 'agriculteur'
  },
  langue: {
    type: DataTypes.STRING,
    defaultValue: 'fr'
  },
  date_inscription: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  otp_code: {
    type: DataTypes.STRING,
    allowNull: true
  },
  otp_expiration: {
    type: DataTypes.DATE,
    allowNull: true
  },
  otp_verified: {
   type: DataTypes.BOOLEAN,
   defaultValue: false
}
}, {
  tableName: 'utilisateur',
  timestamps: false
});

module.exports = User;
