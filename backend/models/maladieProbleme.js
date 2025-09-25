const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const EspeceVegetale = require('./especeVegetale');

const MaladieProbleme = sequelize.define('MaladieProbleme', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  espece_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: EspeceVegetale,
      key: 'id'
    }
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  type: {
    type: DataTypes.ENUM('maladie', 'ravageur', 'carence'),
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  symptomes: {
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('symptomes');
      return v == null ? [] : v;
    }
  },
  causes: {
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('causes');
      return v == null ? [] : v;
    }
  },
  traitement: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  prevention: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  gravite: {
    type: DataTypes.ENUM('faible', 'moyen', 'eleve'),
    allowNull: false
  }
}, {
  tableName: 'maladies_problemes',
  timestamps: false
});

// Relations
EspeceVegetale.hasMany(MaladieProbleme, { foreignKey: 'espece_id', as: 'maladies' });
MaladieProbleme.belongsTo(EspeceVegetale, { foreignKey: 'espece_id', as: 'espece' });

module.exports = MaladieProbleme;
