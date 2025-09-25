const {
  EspeceVegetale,
  Morphologie,
  SoinsCulture,
  ConditionsIdeales,
  ProblemesSolutions,
  GalerieEspece
} = require('../models');

class EspeceDetailController {
  // Récupérer tous les détails d'une espèce végétale
  static async getDetailsByEspece(req, res) {
    try {
      const { especeId } = req.params;
      const userId = req.user.id;

      // Vérifier que l'espèce existe et est accessible
      const espece = await EspeceVegetale.findOne({
        where: { id: especeId, est_active: true }
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      // Récupérer toutes les informations détaillées
      const [morphologie, soins, conditions, problemes, galerie] = await Promise.all([
        Morphologie.findAll({
          where: { espece_id: especeId },
          order: [['partie', 'ASC']]
        }),
        SoinsCulture.findAll({
          where: { espece_id: especeId },
          order: [['type_soin', 'ASC']]
        }),
        ConditionsIdeales.findAll({
          where: { espece_id: especeId },
          order: [['type_condition', 'ASC']]
        }),
        ProblemesSolutions.findAll({
          where: { espece_id: especeId },
          order: [['type_probleme', 'ASC'], ['gravite', 'DESC']]
        }),
        GalerieEspece.findAll({
          where: { espece_id: especeId },
          order: [['ordre_affichage', 'ASC']]
        })
      ]);

      // Organiser les données par catégorie
      const details = {
        espece: espece,
        morphologie: {
          racines: morphologie.filter(m => m.partie === 'racines'),
          tronc: morphologie.filter(m => m.partie === 'tronc'),
          feuilles: morphologie.filter(m => m.partie === 'feuilles'),
          fleurs: morphologie.filter(m => m.partie === 'fleurs'),
          fruits: morphologie.filter(m => m.partie === 'fruits'),
          autres: morphologie.filter(m => !['racines', 'tronc', 'feuilles', 'fleurs', 'fruits'].includes(m.partie))
        },
        soins: {
          eau: soins.filter(s => s.type_soin === 'eau'),
          fertilisation: soins.filter(s => s.type_soin === 'fertilisation'),
          taille: soins.filter(s => s.type_soin === 'taille'),
          propagation: soins.filter(s => s.type_soin === 'propagation'),
          calendrier: soins.filter(s => s.type_soin === 'calendrier'),
          autres: soins.filter(s => !['eau', 'fertilisation', 'taille', 'propagation', 'calendrier'].includes(s.type_soin))
        },
        conditions: {
          temperature: conditions.filter(c => c.type_condition === 'temperature'),
          sol: conditions.filter(c => c.type_condition === 'sol'),
          lumiere: conditions.filter(c => c.type_condition === 'lumiere'),
          zones: conditions.filter(c => c.type_condition === 'zones_culture'),
          saisonnalite: conditions.filter(c => c.type_condition === 'saisonnalite')
        },
        problemes: {
          maladies: problemes.filter(p => p.type_probleme === 'maladie'),
          ravageurs: problemes.filter(p => p.type_probleme === 'ravageur'),
          carences: problemes.filter(p => p.type_probleme === 'carence'),
          autres: problemes.filter(p => !['maladie', 'ravageur', 'carence'].includes(p.type_probleme))
        },
        galerie: galerie
      };

      res.json({
        success: true,
        data: details
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des détails de l\'espèce:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Récupérer seulement la morphologie d'une espèce
  static async getMorphologie(req, res) {
    try {
      const { especeId } = req.params;

      const espece = await EspeceVegetale.findOne({
        where: { id: especeId, est_active: true }
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      const morphologie = await Morphologie.findAll({
        where: { espece_id: especeId },
        order: [['partie', 'ASC']]
      });

      res.json({
        success: true,
        data: morphologie
      });
    } catch (error) {
      console.error('Erreur lors de la récupération de la morphologie:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Récupérer seulement les soins d'une espèce
  static async getSoins(req, res) {
    try {
      const { especeId } = req.params;

      const espece = await EspeceVegetale.findOne({
        where: { id: especeId, est_active: true }
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      const soins = await SoinsCulture.findAll({
        where: { espece_id: especeId },
        order: [['type_soin', 'ASC']]
      });

      res.json({
        success: true,
        data: soins
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des soins:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Récupérer seulement les conditions idéales d'une espèce
  static async getConditions(req, res) {
    try {
      const { especeId } = req.params;

      const espece = await EspeceVegetale.findOne({
        where: { id: especeId, est_active: true }
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      const conditions = await ConditionsIdeales.findAll({
        where: { espece_id: especeId },
        order: [['type_condition', 'ASC']]
      });

      res.json({
        success: true,
        data: conditions
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des conditions:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Récupérer seulement les problèmes d'une espèce
  static async getProblemes(req, res) {
    try {
      const { especeId } = req.params;

      const espece = await EspeceVegetale.findOne({
        where: { id: especeId, est_active: true }
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      const problemes = await ProblemesSolutions.findAll({
        where: { espece_id: especeId },
        order: [['type_probleme', 'ASC'], ['gravite', 'DESC']]
      });

      res.json({
        success: true,
        data: problemes
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des problèmes:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Récupérer seulement la galerie d'une espèce
  static async getGalerie(req, res) {
    try {
      const { especeId } = req.params;

      const espece = await EspeceVegetale.findOne({
        where: { id: especeId, est_active: true }
      });

      if (!espece) {
        return res.status(404).json({
          success: false,
          message: 'Espèce végétale non trouvée'
        });
      }

      const galerie = await GalerieEspece.findAll({
        where: { espece_id: especeId },
        order: [['ordre_affichage', 'ASC']]
      });

      res.json({
        success: true,
        data: galerie
      });
    } catch (error) {
      console.error('Erreur lors de la récupération de la galerie:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }
}

module.exports = EspeceDetailController;
