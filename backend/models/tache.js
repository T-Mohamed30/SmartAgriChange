const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Tache = sequelize.define('Tache', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  priorite: {
    type: DataTypes.ENUM('basse', 'moyenne', 'haute'),
    defaultValue: 'moyenne',
    allowNull: false
  },
  duree_estimee_heures: {
    type: DataTypes.FLOAT,
    allowNull: false,
    defaultValue: 1
  },
  materiel_requis: {
    type: DataTypes.JSON,
    allowNull: true,
    get() {
      const v = this.getDataValue('materiel_requis');
      return v == null ? [] : v;
    }
  },
  etape_culture_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'etapes_culture',
      key: 'id'
    }
  }
}, {
  tableName: 'taches',
  timestamps: true,
  underscored: true
});

module.exports = Tache;
