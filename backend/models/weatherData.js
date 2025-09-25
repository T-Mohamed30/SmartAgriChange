const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const WeatherData = sequelize.define('WeatherData', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  location: {
    type: DataTypes.STRING,
    allowNull: false
  },
  temperature: {
    type: DataTypes.DECIMAL(4,1),
    allowNull: false
  },
  condition: {
    type: DataTypes.STRING,
    allowNull: false
  },
  icon_code: {
    type: DataTypes.STRING,
    allowNull: true
  },
  humidity: {
    type: DataTypes.DECIMAL(5,2),
    allowNull: true
  },
  wind_speed: {
    type: DataTypes.DECIMAL(5,2),
    allowNull: true
  },
  precipitation: {
    type: DataTypes.DECIMAL(5,2),
    allowNull: true
  },
  forecast_date: {
    type: DataTypes.DATE,
    allowNull: false
  },
  last_updated: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'weather_data',
  timestamps: false
});

module.exports = WeatherData;
