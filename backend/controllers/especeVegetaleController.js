const { EspeceVegetale, MaladieProbleme, GaleriePhoto } = require('../models');
const { Op } = require('sequelize');

class EspeceVegetaleController {
  // Récupérer toutes les espèces végétales
  static async getAll(req, res) {
    try {
      const { type, search } = req.query;
      let whereClause = { est_active: true };

      if (type) {
        whereClause.type = type;
      }

      if (search) {
        whereClause[Op.or] = [
          { nom_commun: { [Op.like]: `%${search}%` } },
          { nom_scientifique: { [Op.like]: `%${search}%` } }
        ];
      }

      const especes = await EspeceVegetale.findAll({
        where: whereClause,
        include: [
          {
            model: MaladieProbleme,
            as: 'maladies',
            attributes: ['id', 'nom', 'type', 'gravite']
          },
          {
            model: GaleriePhoto,
            as: 'galerie',
            attributes: ['id', 'image_url', 'type', 'description'],
            limit: 4
          }
        ],
        order: [['nom_commun', 'ASC']]
      });

      res.json({
        success: true,
        data: especes
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des espèces végétales:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Récupérer une espèce végétale par ID
  static async getById(req, res) {
    try {
      const { id } = req.params;

      const espece = await EspeceVegetale.findByPk(id, {
        include: [
          {
            model: MaladieProbleme,
            as: 'maladies',
            order: [['gravite', 'DESC']]
          },
          {
            model: GaleriePhoto,
            as: 'galerie',
            order: [['type', 'ASC']]
          }
        ]
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      res.json({
        success: true,
        data: espece
      });
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'espèce végétale:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Créer une nouvelle espèce végétale (admin)
  static async create(req, res) {
    try {
      const especeData = req.body;

      const nouvelleEspece = await EspeceVegetale.create(especeData);

      res.status(201).json({
        success: true,
        message: 'Espèce végétale créée avec succès',
        data: nouvelleEspece
      });
    } catch (error) {
      console.error('Erreur lors de la création de l\'espèce végétale:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la création'
      });
    }
  }

  // Mettre à jour une espèce végétale (admin)
  static async update(req, res) {
    try {
      const { id } = req.params;
      const updateData = req.body;

      const espece = await EspeceVegetale.findByPk(id);

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      await espece.update(updateData);

      res.json({
        success: true,
        message: 'Espèce végétale mise à jour avec succès',
        data: espece
      });
    } catch (error) {
      console.error('Erreur lors de la mise à jour:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la mise à jour'
      });
    }
  }

  // Supprimer une espèce végétale (admin)
  static async delete(req, res) {
    try {
      const { id } = req.params;

      const espece = await EspeceVegetale.findByPk(id);

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      // Soft delete
      await espece.update({ est_active: false });

      res.json({
        success: true,
        message: 'Espèce végétale supprimée avec succès'
      });
    } catch (error) {
      console.error('Erreur lors de la suppression:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la suppression'
      });
    }
  }

  // Récupérer les paramètres optimaux d'une espèce
  static async getOptimalParams(req, res) {
    try {
      const { id } = req.params;

      const espece = await EspeceVegetale.findByPk(id, {
        attributes: [
          'ph_min', 'ph_max', 'temp_min', 'temp_max',
          'humidite_min', 'humidite_max', 'azote_min', 'azote_max',
          'phosphore_min', 'phosphore_max', 'potassium_min', 'potassium_max'
        ]
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      res.json({
        success: true,
        data: espece
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des paramètres optimaux:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }
}

module.exports = EspeceVegetaleController;
