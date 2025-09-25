const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./user');
const Parcelle = require('./parcelle');
const EspeceVegetale = require('./especeVegetale');

const AnalysePlante = sequelize.define('AnalysePlante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  parcelle_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: Parcelle,
      key: 'id'
    }
  },
  utilisateur_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: 'id'
    }
  },
  espece_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: EspeceVegetale,
      key: 'id'
    }
  },
  image_url: {
    type: DataTypes.STRING,
    allowNull: false
  },
  confiance_identification: {
    type: DataTypes.DECIMAL(3,2),
    allowNull: true
  },
  anomalies_detectees: {
    // SQLite doesn't support ARRAY; store as JSON for compatibility with Postgres/SQLite
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('anomalies_detectees');
      return v == null ? [] : v;
    }
  },
  maladies_detectees: {
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('maladies_detectees');
      return v == null ? [] : v;
    }
  },
  date_analyse: {
    type: DataTypes.DATE,
    allowNull: false
  }
}, {
  tableName: 'analyses_plantes',
  timestamps: false
});

// Relations
User.hasMany(AnalysePlante, { foreignKey: 'utilisateur_id', as: 'analyses_plantes' });
AnalysePlante.belongsTo(User, { foreignKey: 'utilisateur_id', as: 'utilisateur' });

Parcelle.hasMany(AnalysePlante, { foreignKey: 'parcelle_id', as: 'analyses_plantes' });
AnalysePlante.belongsTo(Parcelle, { foreignKey: 'parcelle_id', as: 'parcelle' });

EspeceVegetale.hasMany(AnalysePlante, { foreignKey: 'espece_id', as: 'analyses_plantes' });
AnalysePlante.belongsTo(EspeceVegetale, { foreignKey: 'espece_id', as: 'espece' });

module.exports = AnalysePlante;
