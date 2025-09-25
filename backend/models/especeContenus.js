const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const EspeceContenus = sequelize.define('EspeceContenus', {
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
  type_contenu: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      isIn: [['morphologie', 'soins', 'conditions', 'problemes', 'economie', 'galerie']]
    }
  },
  titre: {
    type: DataTypes.STRING,
    allowNull: false
  },
  contenu: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  ordre_affichage: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0
  }
}, {
  tableName: 'espece_contenus',
  timestamps: false
});

module.exports = EspeceContenus;
