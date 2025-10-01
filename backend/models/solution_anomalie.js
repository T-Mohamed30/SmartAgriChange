const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SolutionAnomalie = sequelize.define('SolutionAnomalie', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  id_anomalie: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  type_solution: {
    type: DataTypes.ENUM('solution', 'prevention'),
    allowNull: false
  },
  contenu: {
    type: DataTypes.TEXT,
    allowNull: false
  }
}, {
  tableName: 'solutions_anomalie',
  timestamps: true
});

module.exports = SolutionAnomalie;
