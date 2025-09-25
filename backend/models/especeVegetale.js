const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const EspeceVegetale = sequelize.define('EspeceVegetale', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nom_scientifique: {
    type: DataTypes.STRING,
    allowNull: false
  },
  nom_commun: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  famille_botanique: {
    type: DataTypes.STRING,
    allowNull: true
  },
  type: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      isIn: [['culture', 'plante_sauvage', 'arbre_fruitier']]
    }
  },
  cycle_vie: {
    type: DataTypes.STRING,
    allowNull: true
  },
  image_url: {
    type: DataTypes.STRING,
    allowNull: true
  },
  est_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  // Paramètres optimaux
  ph_min: {
    type: DataTypes.DECIMAL(3,1),
    allowNull: true
  },
  ph_max: {
    type: DataTypes.DECIMAL(3,1),
    allowNull: true
  },
  temp_min: {
    type: DataTypes.DECIMAL(4,1),
    allowNull: true
  },
  temp_max: {
    type: DataTypes.DECIMAL(4,1),
    allowNull: true
  },
  humidite_min: {
    type: DataTypes.DECIMAL(5,2),
    allowNull: true
  },
  humidite_max: {
    type: DataTypes.DECIMAL(5,2),
    allowNull: true
  },
  azote_min: {
    type: DataTypes.DECIMAL(6,2),
    allowNull: true
  },
  azote_max: {
    type: DataTypes.DECIMAL(6,2),
    allowNull: true
  },
  phosphore_min: {
    type: DataTypes.DECIMAL(6,2),
    allowNull: true
  },
  phosphore_max: {
    type: DataTypes.DECIMAL(6,2),
    allowNull: true
  },
  potassium_min: {
    type: DataTypes.DECIMAL(6,2),
    allowNull: true
  },
  potassium_max: {
    type: DataTypes.DECIMAL(6,2),
    allowNull: true
  },
  rendement_estime: {
    type: DataTypes.STRING,
    allowNull: true
  },
  // Données économiques
  prix_marche_min: {
    type: DataTypes.DECIMAL(8,2),
    allowNull: true
  },
  prix_marche_max: {
    type: DataTypes.DECIMAL(8,2),
    allowNull: true
  },
  utilisations: {
    type: DataTypes.TEXT,
    allowNull: true,
    get() {
      const value = this.getDataValue('utilisations');
      return value ? JSON.parse(value) : [];
    },
    set(val) {
      this.setDataValue('utilisations', JSON.stringify(val || []));
    }
  },
  importance_sociale: {
    type: DataTypes.TEXT,
    allowNull: true,
    get() {
      const value = this.getDataValue('importance_sociale');
      return value ? JSON.parse(value) : [];
    },
    set(val) {
      this.setDataValue('importance_sociale', JSON.stringify(val || []));
    }
  }
}, {
  tableName: 'especes_vegetales',
  timestamps: false
});

module.exports = EspeceVegetale;
