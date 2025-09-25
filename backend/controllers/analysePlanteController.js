const { AnalysePlante, Parcelle, User, EspeceVegetale, MaladieProbleme } = require('../models');
const { Op } = require('sequelize');

class AnalysePlanteController {
  // Récupérer toutes les analyses de plantes d'un utilisateur
  static async getAllByUser(req, res) {
    try {
      const userId = req.user.id;

      const analyses = await AnalysePlante.findAll({
        where: { utilisateur_id: userId },
        include: [
          {
            model: Parcelle,
            as: 'parcelle',
            include: [{
              model: User,
              as: 'utilisateur',
              attributes: ['id', 'nom', 'prenom']
            }]
          },
          {
            model: EspeceVegetale,
            as: 'espece',
            attributes: ['id', 'nom_commun', 'nom_scientifique', 'image_url']
          }
        ],
        order: [['date_analyse', 'DESC']]
      });

      res.json({
        success: true,
        data: analyses
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des analyses de plantes:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Récupérer une analyse de plante par ID
  static async getById(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      const analyse = await AnalysePlante.findOne({
        where: { id, utilisateur_id: userId },
        include: [
          {
            model: Parcelle,
            as: 'parcelle'
          },
          {
            model: EspeceVegetale,
            as: 'espece',
            include: [{
              model: MaladieProbleme,
              as: 'maladies'
            }]
          }
        ]
      });

      if (!analyse) {
        return res.status(404).json({
          success: false,
          message: 'Analyse de plante non trouvée'
        });
      }

      res.json({
        success: true,
        data: analyse
      });
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'analyse de plante:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Créer une nouvelle analyse de plante
  static async create(req, res) {
    try {
      const userId = req.user.id;
      const analyseData = {
        ...req.body,
        utilisateur_id: userId
      };

      const nouvelleAnalyse = await AnalysePlante.create(analyseData);

      // Analyser automatiquement les maladies détectées
      if (analyseData.maladies_detectees && analyseData.maladies_detectees.length > 0) {
        await AnalysePlanteController.analyzeDetectedDiseases(nouvelleAnalyse);
      }

      res.status(201).json({
        success: true,
        message: 'Analyse de plante créée avec succès',
        data: nouvelleAnalyse
      });
    } catch (error) {
      console.error('Erreur lors de la création de l\'analyse de plante:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la création'
      });
    }
  }

  // Endpoint pour analyser une plante via upload multipart/form-data
  static async analyser(req, res) {
    try {
      const userId = req.user.id;

      // Support both file upload and base64 in body
      let imageUrl = null;
      if (req.file) {
        // store relative path to serve later
        imageUrl = `/uploads/plant_images/${req.file.filename}`;
      } else if (req.body.image_base64) {
        // In this branch we could decode and save, but for now keep null or a placeholder
        imageUrl = req.body.image_url || null;
      } else if (req.body.image_url) {
        imageUrl = req.body.image_url;
      }

      const analyseData = {
        parcelle_id: req.body.parcelle_id || null,
        utilisateur_id: userId,
        espece_id: req.body.espece_id || null,
        image_url: imageUrl || '',
        confiance_identification: null,
        anomalies_detectees: null,
        maladies_detectees: null,
        date_analyse: new Date()
      };

      // Simulate call to IA service (stub)
      // In a real implementation, send the image path or bytes to the AI service and parse the response
      const simulatedIaResult = {
        espece_id: req.body.espece_id || null,
        confiance: req.body.confiance || 0.85,
        maladies_detectees: req.body.maladies_detectees ? JSON.parse(req.body.maladies_detectees) : [],
        anomalies_detectees: req.body.anomalies_detectees ? JSON.parse(req.body.anomalies_detectees) : []
      };

      analyseData.espece_id = simulatedIaResult.espece_id;
      analyseData.confiance_identification = simulatedIaResult.confiance;
      analyseData.maladies_detectees = simulatedIaResult.maladies_detectees;
      analyseData.anomalies_detectees = simulatedIaResult.anomalies_detectees;

      const nouvelleAnalyse = await AnalysePlante.create(analyseData);

      // Trigger disease analysis if any
      if (analyseData.maladies_detectees && analyseData.maladies_detectees.length > 0) {
        await AnalysePlanteController.analyzeDetectedDiseases(nouvelleAnalyse);
      }

      res.status(201).json({
        success: true,
        message: 'Analyse de plante créée et analysée (simulé)',
        data: nouvelleAnalyse
      });
    } catch (error) {
      console.error('Erreur lors de l\'analyse via upload:', error);
      res.status(500).json({ success: false, message: 'Erreur lors de l\'analyse' });
    }
  }

  // Mettre à jour une analyse de plante
  static async update(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;
      const updateData = req.body;

      const analyse = await AnalysePlante.findOne({
        where: { id, utilisateur_id: userId }
      });

      if (!analyse) {
        return res.status(404).json({
          success: false,
          message: 'Analyse de plante non trouvée'
        });
      }

      await analyse.update(updateData);

      res.json({
        success: true,
        message: 'Analyse de plante mise à jour avec succès',
        data: analyse
      });
    } catch (error) {
      console.error('Erreur lors de la mise à jour:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la mise à jour'
      });
    }
  }

  // Supprimer une analyse de plante
  static async delete(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      const analyse = await AnalysePlante.findOne({
        where: { id, utilisateur_id: userId }
      });

      if (!analyse) {
        return res.status(404).json({
          success: false,
          message: 'Analyse de plante non trouvée'
        });
      }

      await analyse.destroy();

      res.json({
        success: true,
        message: 'Analyse de plante supprimée avec succès'
      });
    } catch (error) {
      console.error('Erreur lors de la suppression:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la suppression'
      });
    }
  }

  // Analyser les maladies détectées et faire des recommandations
  static async analyzeDetectedDiseases(analyse) {
    try {
      if (!analyse.espece_id || !analyse.maladies_detectees) return;

      // Récupérer les maladies correspondantes de la base de données
      const maladiesDetectees = await MaladieProbleme.findAll({
        where: {
          espece_id: analyse.espece_id,
          nom: {
            [Op.in]: analyse.maladies_detectees
          }
        }
      });

      // Ajouter les détails des maladies à l'analyse
      await analyse.update({
        anomalies_detectees: analyse.maladies_detectees
      });

      // Générer des recommandations de traitement
      for (const maladie of maladiesDetectees) {
        // Ici on pourrait créer des notifications ou des recommandations spécifiques
        console.log(`Maladie détectée: ${maladie.nom} - Gravité: ${maladie.gravite}`);
        console.log(`Traitement recommandé: ${maladie.traitement}`);
        console.log(`Prévention: ${maladie.prevention}`);
      }

    } catch (error) {
      console.error('Erreur lors de l\'analyse des maladies détectées:', error);
    }
  }

  // Récupérer les analyses récentes d'une parcelle (ou toutes les analyses sans parcelle)
  static async getByParcelle(req, res) {
    try {
      const { parcelleId } = req.params;
      const userId = req.user.id;

      let whereCondition = { utilisateur_id: userId };

      if (parcelleId) {
        // Vérifier que la parcelle appartient à l'utilisateur
        const parcelle = await Parcelle.findOne({
          where: { id: parcelleId },
          include: [{
            model: User,
            as: 'utilisateur',
            where: { id: userId }
          }]
        });

        if (!parcelle) {
          return res.status(404).json({
            success: false,
            message: 'Parcelle non trouvée ou accès non autorisé'
          });
        }

        whereCondition.parcelle_id = parcelleId;
      } else {
        // Si pas de parcelleId, récupérer les analyses sans parcelle
        whereCondition.parcelle_id = null;
      }

      const analyses = await AnalysePlante.findAll({
        where: whereCondition,
        include: [
          {
            model: EspeceVegetale,
            as: 'espece'
          }
        ],
        order: [['date_analyse', 'DESC']],
        limit: 10
      });

      res.json({
        success: true,
        data: analyses
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des analyses par parcelle:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur'
      });
    }
  }

  // Obtenir des statistiques sur les analyses de plantes
  static async getStats(req, res) {
    try {
      const userId = req.user.id;

      const stats = await AnalysePlante.findAll({
        where: { utilisateur_id: userId },
        attributes: [
          [sequelize.fn('COUNT', sequelize.col('id')), 'total_analyses'],
          [sequelize.fn('COUNT', sequelize.fn('DISTINCT', sequelize.col('parcelle_id'))), 'parcelles_analysees'],
          [sequelize.fn('COUNT', sequelize.fn('DISTINCT', sequelize.col('espece_id'))), 'especes_identifiees'],
          [sequelize.fn('AVG', sequelize.col('confiance_identification')), 'confiance_moyenne']
        ],
        raw: true
      });

      // Statistiques par mois (30 derniers jours)
      const recentStats = await AnalysePlante.findAll({
        where: {
          utilisateur_id: userId,
          date_analyse: {
            [Op.gte]: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
          }
        },
        attributes: [
          [sequelize.fn('DATE', sequelize.col('date_analyse')), 'date'],
          [sequelize.fn('COUNT', sequelize.col('id')), 'count']
        ],
        group: [sequelize.fn('DATE', sequelize.col('date_analyse'))],
        order: [sequelize.fn('DATE', sequelize.col('date_analyse'))],
        raw: true
      });

      res.json({
        success: true,
        data: {
          general: stats[0],
          recent_activity: recentStats
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
}

module.exports = AnalysePlanteController;
