const { WeatherData } = require('../models');
const { Op } = require('sequelize');

class WeatherController {
  // Récupérer les prévisions météorologiques pour une localisation
  static async getForecast(req, res) {
    try {
      const { location, days = 7 } = req.query;

      if (!location) {
        return res.status(400).json({
          success: false,
          message: 'Localisation requise'
        });
      }

      const endDate = new Date();
      endDate.setDate(endDate.getDate() + parseInt(days));

      const forecasts = await WeatherData.findAll({
        where: {
          location: {
            [Op.like]: `%${location}%`
          },
          forecast_date: {
            [Op.between]: [new Date(), endDate]
          }
        },
        order: [['forecast_date', 'ASC'], ['last_updated', 'DESC']]
      });

      // Grouper par date pour obtenir la prévision la plus récente
      const groupedForecasts = {};
      forecasts.forEach(forecast => {
        const dateKey = forecast.forecast_date.toISOString().split('T')[0];
        if (!groupedForecasts[dateKey] ||
            forecast.last_updated > groupedForecasts[dateKey].last_updated) {
          groupedForecasts[dateKey] = forecast;
        }
      });

      res.json({
        success: true,
        data: Object.values(groupedForecasts)
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des prévisions:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Récupérer les données météorologiques actuelles
  static async getCurrent(req, res) {
    try {
      const { location } = req.query;

      if (!location) {
        return res.status(400).json({
          success: false,
          message: 'Localisation requise'
        });
      }

      const currentWeather = await WeatherData.findOne({
        where: {
          location: {
            [Op.like]: `%${location}%`
          },
          forecast_date: {
            [Op.gte]: new Date()
          }
        },
        order: [['forecast_date', 'ASC'], ['last_updated', 'DESC']]
      });

      if (!currentWeather) {
        return res.status(404).json({
          success: false,
          message: 'Données météorologiques non trouvées'
        });
      }

      res.json({
        success: true,
        data: currentWeather
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des données actuelles:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Ajouter des données météorologiques (admin ou service externe)
  static async create(req, res) {
    try {
      const weatherData = req.body;

      const nouvelleDonnee = await WeatherData.create(weatherData);

      res.status(201).json({
        success: true,
        message: 'Données météorologiques ajoutées avec succès',
        data: nouvelleDonnee
      });
    } catch (error) {
      console.error('Erreur lors de l\'ajout des données météorologiques:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de l\'ajout'
      });
    }
  }

  // Mettre à jour des données météorologiques
  static async update(req, res) {
    try {
      const { id } = req.params;
      const updateData = req.body;

      const weatherData = await WeatherData.findByPk(id);

      if (!weatherData) {
        return res.status(404).json({
          success: false,
          message: 'Données météorologiques non trouvées'
        });
      }

      await weatherData.update(updateData);

      res.json({
        success: true,
        message: 'Données météorologiques mises à jour avec succès',
        data: weatherData
      });
    } catch (error) {
      console.error('Erreur lors de la mise à jour:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la mise à jour'
      });
    }
  }

  // Supprimer des données météorologiques
  static async delete(req, res) {
    try {
      const { id } = req.params;

      const weatherData = await WeatherData.findByPk(id);

      if (!weatherData) {
        return res.status(404).json({
          success: false,
          message: 'Données météorologiques non trouvées'
        });
      }

      await weatherData.destroy();

      res.json({
        success: true,
        message: 'Données météorologiques supprimées avec succès'
      });
    } catch (error) {
      console.error('Erreur lors de la suppression:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la suppression'
      });
    }
  }

  // Obtenir l'historique météorologique pour une localisation
  static async getHistory(req, res) {
    try {
      const { location, startDate, endDate } = req.query;

      if (!location || !startDate || !endDate) {
        return res.status(400).json({
          success: false,
          message: 'Localisation, date de début et date de fin requises'
        });
      }

      const history = await WeatherData.findAll({
        where: {
          location: {
            [Op.like]: `%${location}%`
          },
          forecast_date: {
            [Op.between]: [new Date(startDate), new Date(endDate)]
          }
        },
        order: [['forecast_date', 'ASC'], ['last_updated', 'DESC']]
      });

      res.json({
        success: true,
        data: history
      });
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'historique:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Obtenir les statistiques météorologiques
  static async getStats(req, res) {
    try {
      const { location, period = 30 } = req.query;

      if (!location) {
        return res.status(400).json({
          success: false,
          message: 'Localisation requise'
        });
      }

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - parseInt(period));

      const stats = await WeatherData.findAll({
        where: {
          location: {
            [Op.like]: `%${location}%`
          },
          forecast_date: {
            [Op.gte]: startDate
          }
        },
        attributes: [
          [sequelize.fn('AVG', sequelize.col('temperature')), 'temp_moyenne'],
          [sequelize.fn('MIN', sequelize.col('temperature')), 'temp_min'],
          [sequelize.fn('MAX', sequelize.col('temperature')), 'temp_max'],
          [sequelize.fn('AVG', sequelize.col('humidity')), 'humidite_moyenne'],
          [sequelize.fn('SUM', sequelize.col('precipitation')), 'precipitation_totale'],
          [sequelize.fn('AVG', sequelize.col('wind_speed')), 'vent_moyen']
        ],
        raw: true
      });

      res.json({
        success: true,
        data: {
          location: location,
          period: `${period} jours`,
          statistiques: stats[0]
        }
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des statistiques:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Synchroniser les données météorologiques (service externe)
  static async syncData(req, res) {
    try {
      // Ici on pourrait intégrer avec une API météorologique externe
      // comme OpenWeatherMap, WeatherAPI, etc.

      const { location } = req.body;

      if (!location) {
        return res.status(400).json({
          success: false,
          message: 'Localisation requise'
        });
      }

      // Simulation de données météorologiques
      const mockWeatherData = {
        location: location,
        temperature: 25 + Math.random() * 10, // 25-35°C
        condition: ['Ensoleillé', 'Nuageux', 'Pluvieux'][Math.floor(Math.random() * 3)],
        humidity: 60 + Math.random() * 30, // 60-90%
        wind_speed: Math.random() * 20, // 0-20 km/h
        precipitation: Math.random() * 5, // 0-5 mm
        forecast_date: new Date(Date.now() + 24 * 60 * 60 * 1000), // Demain
        last_updated: new Date()
      };

      const nouvelleDonnee = await WeatherData.create(mockWeatherData);

      res.json({
        success: true,
        message: 'Données météorologiques synchronisées avec succès',
        data: nouvelleDonnee
      });
    } catch (error) {
      console.error('Erreur lors de la synchronisation:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la synchronisation'
      });
    }
  }
}

module.exports = WeatherController;
