const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./user');

const Champ = sequelize.define('Champ', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  localite: {
    type: DataTypes.STRING,
    allowNull: false
  },
  date_creation: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'champs',
  timestamps: false
});

// Relation : un utilisateur possède plusieurs champs
User.hasMany(Champ, { foreignKey: 'id_utilisateur', as: 'champs' });
Champ.belongsTo(User, { foreignKey: 'id_utilisateur', as: 'utilisateur' });

module.exports = Champ;
