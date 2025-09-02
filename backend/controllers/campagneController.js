const { Campagne, EtapeCampagne, EtapeCulture, Tache, Culture, Parcelle, Champ, AnalyseSol, RecommendationCulture } = require('../models');
const { Op } = require('sequelize');

/**
 * Crée une nouvelle campagne agricole à partir d'une recommandation
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.creerCampagne = async (req, res) => {
  try {
    const { analyse_id, culture_id, date_debut, notes } = req.body;
    const userId = req.user.id;

    // Vérifier que l'analyse existe et que l'utilisateur y a accès
    const analyse = await AnalyseSol.findOne({
      include: [{
        model: Parcelle,
        include: [{
          model: Champ,
          where: { id_utilisateur: userId },
          required: true
        }]
      }],
      where: { id: analyse_id }
    });

    if (!analyse) {
      return res.status(404).json({ error: 'Analyse non trouvée ou accès non autorisé' });
    }

    // Vérifier que la culture existe et est active
    const culture = await Culture.findOne({
      where: { id: culture_id, est_active: true }
    });

    if (!culture) {
      return res.status(404).json({ error: 'Culture non trouvée ou inactive' });
    }

    // Vérifier qu'il n'y a pas de campagne en cours pour cette parcelle
    const campagneExistante = await Campagne.findOne({
      where: {
        parcelle_id: analyse.parcelle_id,
        statut: ['planifiée', 'en_cours']
      }
    });

    if (campagneExistante) {
      return res.status(400).json({
        error: 'Une campagne est déjà en cours pour cette parcelle',
        campagne_id: campagneExistante.id
      });
    }

    // Créer la campagne
    const campagne = await Campagne.create({
      culture_id,
      parcelle_id: analyse.parcelle_id,
      utilisateur_id: userId,
      date_debut: new Date(date_debut),
      statut: 'planifiée',
      progression: 0,
      notes,
      analyse_sol_id: analyse_id
    });

    // Récupérer les étapes de la culture
    const etapesCulture = await EtapeCulture.findAll({
      where: { culture_id },
      order: [['ordre', 'ASC']],
      include: [{
        model: Tache,
        as: 'Taches',
        required: false
      }]
    });

    // Créer les étapes de la campagne
    let dateEtape = new Date(date_debut);
    
    for (const etapeCulture of etapesCulture) {
      // Calculer la date de fin de l'étape
      const dateFinEtape = new Date(dateEtape);
      dateFinEtape.setDate(dateFinEtape.getDate() + etapeCulture.duree_jours);
      
      // Créer l'étape de campagne
      const etapeCampagne = await EtapeCampagne.create({
        campagne_id: campagne.id,
        etape_culture_id: etapeCulture.id,
        nom: etapeCulture.nom,
        description: etapeCulture.description,
        duree_jours: etapeCulture.duree_jours,
        date_debut: new Date(dateEtape),
        date_fin: dateFinEtape,
        statut: 'à_faire',
        ordre: etapeCulture.ordre
      });

      // Créer les tâches de l'étape
      if (etapeCulture.Taches && etapeCulture.Taches.length > 0) {
        for (const tache of etapeCulture.Taches) {
          await Tache.create({
            etape_campagne_id: etapeCampagne.id,
            description: tache.description,
            priorite: tache.priorite,
            duree_estimee: tache.duree_estimee,
            materiel_requis: tache.materiel_requis,
            statut: 'à_faire'
          });
        }
      }

      // Mettre à jour la date de début pour l'étape suivante
      dateEtape = new Date(dateFinEtape);
      dateEtape.setDate(dateEtape.getDate() + 1); // Jour de transition entre les étapes
    }

    // Mettre à jour la date de fin de la campagne
    const dureeTotaleJours = etapesCulture.reduce((total, etape) => total + etape.duree_jours, 0);
    const dateFinCampagne = new Date(date_debut);
    dateFinCampagne.setDate(dateFinCampagne.getDate() + dureeTotaleJours);

    await campagne.update({
      date_fin: dateFinCampagne
    });

    // Récupérer la campagne créée avec toutes ses relations
    const campagneComplete = await Campagne.findByPk(campagne.id, {
      include: [
        {
          model: Culture,
          attributes: ['id', 'nom', 'duree_cycle_semaines', 'rendement_moyen']
        },
        {
          model: Parcelle,
          include: [{
            model: Champ,
            attributes: ['id', 'nom', 'localite']
          }]
        },
        {
          model: EtapeCampagne,
          include: [{
            model: Tache,
            as: 'Taches',
            required: false
          }],
          order: [['date_debut', 'ASC']]
        },
        {
          model: AnalyseSol,
          include: [{
            model: RecommendationCulture,
            where: { culture_id },
            limit: 1,
            required: false
          }]
        }
      ]
    });

    res.status(201).json({
      message: 'Campagne agricole créée avec succès',
      campagne: campagneComplete
    });

  } catch (error) {
    console.error('Erreur lors de la création de la campagne agricole:', error);
    res.status(500).json({
      error: 'Erreur lors de la création de la campagne agricole',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Récupère toutes les campagnes de l'utilisateur connecté
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.getCampagnesUtilisateur = async (req, res) => {
  try {
    const userId = req.user.id;
    const { statut } = req.query;

    const whereClause = { utilisateur_id: userId };
    
    if (statut) {
      whereClause.statut = statut;
    }

    const campagnes = await Campagne.findAll({
      where: whereClause,
      include: [
        {
          model: Culture,
          attributes: ['id', 'nom', 'image_url']
        },
        {
          model: Parcelle,
          attributes: ['id', 'nom'],
          include: [{
            model: Champ,
            attributes: ['id', 'nom', 'localite']
          }]
        },
        {
          model: EtapeCampagne,
          attributes: ['id', 'nom', 'statut', 'date_debut', 'date_fin'],
          order: [['date_debut', 'ASC']],
          limit: 1
        }
      ],
      order: [['date_debut', 'DESC']]
    });

    res.json(campagnes);

  } catch (error) {
    console.error('Erreur lors de la récupération des campagnes:', error);
    res.status(500).json({
      error: 'Erreur lors de la récupération des campagnes',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Récupère les détails d'une campagne spécifique
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.getCampagneDetails = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const campagne = await Campagne.findOne({
      where: { id, utilisateur_id: userId },
      include: [
        {
          model: Culture,
          attributes: ['id', 'nom', 'description', 'image_url', 'duree_cycle_semaines', 'rendement_moyen', 'type_engrais']
        },
        {
          model: Parcelle,
          attributes: ['id', 'nom', 'superficie'],
          include: [{
            model: Champ,
            attributes: ['id', 'nom', 'localite']
          }]
        },
        {
          model: EtapeCampagne,
          include: [{
            model: Tache,
            as: 'Taches',
            required: false
          }],
          order: [['date_debut', 'ASC']]
        },
        {
          model: AnalyseSol,
          include: [{
            model: RecommendationCulture,
            where: { culture_id: { [Op.col]: 'Campagne.culture_id' } },
            required: false,
            limit: 1
          }]
        }
      ]
    });

    if (!campagne) {
      return res.status(404).json({ error: 'Campagne non trouvée ou accès non autorisé' });
    }

    // Calculer la progression globale de la campagne
    const totalEtapes = campagne.EtapeCampagnes.length;
    if (totalEtapes > 0) {
      const etapesTerminees = campagne.EtapeCampagnes.filter(e => e.statut === 'terminée').length;
      campagne.progression = Math.round((etapesTerminees / totalEtapes) * 100);
      
      // Mettre à jour le statut de la campagne si nécessaire
      if (campagne.progression === 100 && campagne.statut !== 'terminée') {
        campagne.statut = 'terminée';
        await campagne.save();
      } else if (campagne.progression > 0 && campagne.statut === 'planifiée') {
        campagne.statut = 'en_cours';
        await campagne.save();
      }
    }

    res.json(campagne);

  } catch (error) {
    console.error('Erreur lors de la récupération des détails de la campagne:', error);
    res.status(500).json({
      error: 'Erreur lors de la récupération des détails de la campagne',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Met à jour le statut d'une étape de campagne
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.mettreAJourStatutEtape = async (req, res) => {
  try {
    const { id } = req.params;
    const { statut } = req.body;
    const userId = req.user.id;

    // Vérifier que l'étape appartient à une campagne de l'utilisateur
    const etape = await EtapeCampagne.findOne({
      include: [{
        model: Campagne,
        where: { utilisateur_id: userId },
        required: true
      }],
      where: { id }
    });

    if (!etape) {
      return res.status(404).json({ error: 'Étape non trouvée ou accès non autorisé' });
    }

    // Mettre à jour le statut de l'étape
    await etape.update({ statut });

    // Mettre à jour le statut des tâches de l'étape si l'étape est marquée comme terminée
    if (statut === 'terminée') {
      await Tache.update(
        { statut: 'terminée' },
        { where: { etape_campagne_id: id, statut: 'à_faire' } }
      );
    }

    // Récupérer la campagne mise à jour pour calculer la progression
    const campagne = await Campagne.findByPk(etape.campagne_id, {
      include: [{
        model: EtapeCampagne,
        attributes: ['id', 'statut']
      }]
    });

    // Calculer la nouvelle progression
    const totalEtapes = campagne.EtapeCampagnes.length;
    const etapesTerminees = campagne.EtapeCampagnes.filter(e => e.statut === 'terminée').length;
    const nouvelleProgression = Math.round((etapesTerminees / totalEtapes) * 100);

    // Mettre à jour la progression de la campagne
    await campagne.update({ progression: nouvelleProgression });

    // Mettre à jour le statut de la campagne si nécessaire
    if (nouvelleProgression === 100 && campagne.statut !== 'terminée') {
      await campagne.update({ 
        statut: 'terminée',
        date_fin: new Date()
      });
    } else if (nouvelleProgression > 0 && campagne.statut === 'planifiée') {
      await campagne.update({ statut: 'en_cours' });
    }

    res.json({ 
      message: 'Statut de l\'étape mis à jour avec succès',
      progression: nouvelleProgression,
      statutCampagne: campagne.statut
    });

  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut de l\'étape:', error);
    res.status(500).json({
      error: 'Erreur lors de la mise à jour du statut de l\'étape',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Met à jour le statut d'une tâche
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.mettreAJourStatutTache = async (req, res) => {
  try {
    const { id } = req.params;
    const { statut } = req.body;
    const userId = req.user.id;

    // Vérifier que la tâche appartient à une campagne de l'utilisateur
    const tache = await Tache.findOne({
      include: [{
        model: EtapeCampagne,
        required: true,
        include: [{
          model: Campagne,
          where: { utilisateur_id: userId },
          required: true
        }]
      }],
      where: { id }
    });

    if (!tache) {
      return res.status(404).json({ error: 'Tâche non trouvée ou accès non autorisé' });
    }

    // Mettre à jour le statut de la tâche
    await tache.update({ statut });

    // Vérifier si toutes les tâches de l'étape sont terminées
    const tachesEtape = await Tache.findAll({
      where: { etape_campagne_id: tache.etape_campagne_id }
    });

    const toutesTerminees = tachesEtape.every(t => t.statut === 'terminée');
    
    // Si toutes les tâches sont terminées, marquer l'étape comme terminée
    if (toutesTerminees) {
      await EtapeCampagne.update(
        { statut: 'terminée' },
        { where: { id: tache.etape_campagne_id } }
      );
      
      // Mettre à jour la progression de la campagne
      await this.mettreAJourProgressionCampagne(tache.EtapeCampagne.campagne_id);
    }

    res.json({ message: 'Statut de la tâche mis à jour avec succès' });

  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut de la tâche:', error);
    res.status(500).json({
      error: 'Erreur lors de la mise à jour du statut de la tâche',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Fonction utilitaire pour mettre à jour la progression d'une campagne
 * @param {number} campagneId - ID de la campagne
 */
async function mettreAJourProgressionCampagne(campagneId) {
  const campagne = await Campagne.findByPk(campagneId, {
    include: [{
      model: EtapeCampagne,
      attributes: ['id', 'statut']
    }]
  });

  if (!campagne) return;

  const totalEtapes = campagne.EtapeCampagnes.length;
  const etapesTerminees = campagne.EtapeCampagnes.filter(e => e.statut === 'terminée').length;
  const nouvelleProgression = Math.round((etapesTerminees / totalEtapes) * 100);

  // Mettre à jour la progression de la campagne
  await campagne.update({ progression: nouvelleProgression });

  // Mettre à jour le statut de la campagne si nécessaire
  if (nouvelleProgression === 100 && campagne.statut !== 'terminée') {
    await campagne.update({ 
      statut: 'terminée',
      date_fin: new Date()
    });
  } else if (nouvelleProgression > 0 && campagne.statut === 'planifiée') {
    await campagne.update({ statut: 'en_cours' });
  }

  return { progression: nouvelleProgression, statut: campagne.statut };
}

/**
 * Supprime une campagne agricole
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.supprimerCampagne = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Vérifier que la campagne appartient à l'utilisateur
    const campagne = await Campagne.findOne({
      where: { id, utilisateur_id: userId }
    });

    if (!campagne) {
      return res.status(404).json({ error: 'Campagne non trouvée ou accès non autorisé' });
    }

    // Supprimer la campagne (les contraintes CASCADE s'occuperont du reste)
    await campagne.destroy();

    res.json({ message: 'Campagne supprimée avec succès' });

  } catch (error) {
    console.error('Erreur lors de la suppression de la campagne:', error);
    res.status(500).json({
      error: 'Erreur lors de la suppression de la campagne',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};
