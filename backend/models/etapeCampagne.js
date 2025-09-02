const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const EtapeCampagne = sequelize.define('EtapeCampagne', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  date_debut: DataTypes.DATE,
  date_fin: DataTypes.DATE,
  statut: {
    type: DataTypes.ENUM('à_faire', 'en_cours', 'terminée', 'en_retard'),
    defaultValue: 'à_faire',
    allowNull: false
  },
  campagne_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'campagnes',
      key: 'id'
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
  tableName: 'etapes_campagne',
  timestamps: true,
  underscored: true
});

module.exports = EtapeCampagne;
