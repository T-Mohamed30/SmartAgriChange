const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ProblemesSolutions = sequelize.define('ProblemesSolutions', {
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
  type_probleme: {
    type: DataTypes.ENUM('maladie', 'ravageur', 'carence', 'stress_abiotic', 'mauvaise_pratique'),
    allowNull: false
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  gravite: {
    type: DataTypes.ENUM('faible', 'moyen', 'eleve', 'critique'),
    allowNull: false
  },
  // Symptômes
  symptomes: {
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('symptomes');
      return v == null ? [] : v;
    }
  },
  // Causes possibles
  causes: {
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('causes');
      return v == null ? [] : v;
    }
  },
  // Solutions
  traitement: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  prevention: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  produits_recommandes: {
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('produits_recommandes');
      return v == null ? [] : v;
    }
  },
  // Images
  images_url: {
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('images_url');
      return v == null ? [] : v;
    }
  }
}, {
  tableName: 'problemes_solutions',
  timestamps: false
});

module.exports = ProblemesSolutions;
