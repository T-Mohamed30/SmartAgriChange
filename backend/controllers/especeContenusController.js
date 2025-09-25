const { EspeceVegetale, EspeceContenus } = require('../models');

class EspeceContenusController {
  // Récupérer tous les contenus d'une espèce par type
  static async getContenusByType(req, res) {
    try {
      const { especeId, type } = req.params;

      // Vérifier que l'espèce existe
      const espece = await EspeceVegetale.findOne({
        where: { id: especeId, est_active: true }
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      const contenus = await EspeceContenus.findAll({
        where: {
          espece_id: especeId,
          type_contenu: type
        },
        order: [['ordre_affichage', 'ASC']]
      });

      res.json({
        success: true,
        data: contenus
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des contenus:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Récupérer tous les contenus d'une espèce (tous types)
  static async getAllContenus(req, res) {
    try {
      const { especeId } = req.params;

      // Vérifier que l'espèce existe
      const espece = await EspeceVegetale.findOne({
        where: { id: especeId, est_active: true }
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      const contenus = await EspeceContenus.findAll({
        where: { espece_id: especeId },
        order: [['type_contenu', 'ASC'], ['ordre_affichage', 'ASC']]
      });

      // Organiser par type
      const organized = {
        morphologie: contenus.filter(c => c.type_contenu === 'morphologie'),
        soins: contenus.filter(c => c.type_contenu === 'soins'),
        conditions: contenus.filter(c => c.type_contenu === 'conditions'),
        problemes: contenus.filter(c => c.type_contenu === 'problemes'),
        economie: contenus.filter(c => c.type_contenu === 'economie'),
        galerie: contenus.filter(c => c.type_contenu === 'galerie')
      };

      res.json({
        success: true,
        data: organized
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des contenus:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Créer un nouveau contenu
  static async create(req, res) {
    try {
      const { especeId } = req.params;
      const contenuData = {
        ...req.body,
        espece_id: especeId
      };

      const nouveauContenu = await EspeceContenus.create(contenuData);

      res.status(201).json({
        success: true,
        message: 'Contenu créé avec succès',
        data: nouveauContenu
      });
    } catch (error) {
      console.error('Erreur lors de la création du contenu:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la création'
      });
    }
  }

  // Mettre à jour un contenu
  static async update(req, res) {
    try {
      const { id } = req.params;
      const updateData = req.body;

      const contenu = await EspeceContenus.findByPk(id);

      if (!contenu) {
        return res.status(404).json({
          success: false,
          message: 'Contenu non trouvé'
        });
      }

      await contenu.update(updateData);

      res.json({
        success: true,
        message: 'Contenu mis à jour avec succès',
        data: contenu
      });
    } catch (error) {
      console.error('Erreur lors de la mise à jour:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la mise à jour'
      });
    }
  }

  // Supprimer un contenu
  static async delete(req, res) {
    try {
      const { id } = req.params;

      const contenu = await EspeceContenus.findByPk(id);

      if (!contenu) {
        return res.status(404).json({
          success: false,
          message: 'Contenu non trouvé'
        });
      }

      await contenu.destroy();

      res.json({
        success: true,
        message: 'Contenu supprimé avec succès'
      });
    } catch (error) {
      console.error('Erreur lors de la suppression:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la suppression'
      });
    }
  }
}

module.exports = EspeceContenusController;
