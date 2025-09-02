const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Campagne = sequelize.define('Campagne', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  date_debut: {
    type: DataTypes.DATE,
    allowNull: false
  },
  date_fin: DataTypes.DATE,
  statut: {
    type: DataTypes.ENUM('planifiée', 'en_cours', 'terminée', 'annulée'),
    defaultValue: 'planifiée',
    allowNull: false
  },
  progression: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: {
      min: 0,
      max: 100
    }
  },
  culture_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'cultures',
      key: 'id'
    }
  },
  parcelle_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'parcelles',
      key: 'id'
    }
  },
  utilisateur_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'utilisateurs',
      key: 'id'
    }
  }
}, {
  tableName: 'campagnes',
  timestamps: true,
  underscored: true
});

module.exports = Campagne;
