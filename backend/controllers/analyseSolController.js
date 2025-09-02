const { AnalyseSol, Culture, RecommendationCulture, Parcelle, Campagne } = require('../models');

/**
 * Calcule le pourcentage de compatibilité d'une culture avec les données du sol
 * @param {Object} culture - Modèle Culture avec les plages idéales
 * @param {Object} analyseData - Données d'analyse du sol
 * @returns {Object} - { score: number, details: Object, message: string }
 */
function calculerCompatibilite(culture, analyseData) {
  let scoreTotal = 0;
  let criteresTotal = 0;
  const details = {};
  
  // Fonction pour calculer le score d'un critère
  const calculerScoreCritere = (valeur, min, max, poids = 1) => {
    if (valeur === null || valeur === undefined) return 0;
    if (valeur >= min && valeur <= max) return 1 * poids;
    
    // Calculer l'écart relatif
    const ecart = valeur < min ? (valeur - min) / min : (valeur - max) / max;
    return Math.max(0, 1 - Math.abs(ecart)) * poids;
  };

  // pH (poids important)
  if (culture.ph_min !== null && culture.ph_max !== null && analyseData.ph) {
    const score = calculerScoreCritere(analyseData.ph, culture.ph_min, culture.ph_max, 1.5);
    scoreTotal += score;
    details.ph = { score, ideal: `${culture.ph_min}-${culture.ph_max}`, actuel: analyseData.ph };
    criteresTotal += 1.5;
  }

  // Humidité (poids moyen)
  if (culture.humidite_min !== null && culture.humidite_max !== null && analyseData.humidite) {
    const score = calculerScoreCritere(analyseData.humidite, culture.humidite_min, culture.humidite_max, 1);
    scoreTotal += score;
    details.humidite = { score, ideal: `${culture.humidite_min}-${culture.humidite_max}%`, actuel: `${analyseData.humidite}%` };
    criteresTotal += 1;
  }

  // Température (poids important)
  if (culture.temperature_min !== null && culture.temperature_max !== null && analyseData.temperature) {
    const score = calculerScoreCritere(analyseData.temperature, culture.temperature_min, culture.temperature_max, 1.5);
    scoreTotal += score;
    details.temperature = { score, ideal: `${culture.temperature_min}-${culture.temperature_max}°C`, actuel: `${analyseData.temperature}°C` };
    criteresTotal += 1.5;
  }

  // Conductivité électrique (poids moyen)
  if (culture.ec_min !== null && culture.ec_max !== null && analyseData.conductivite) {
    const score = calculerScoreCritere(analyseData.conductivite, culture.ec_min, culture.ec_max, 1);
    scoreTotal += score;
    details.conductivite = { score, ideal: `${culture.ec_min}-${culture.ec_max} dS/m`, actuel: `${analyseData.conductivite} dS/m` };
    criteresTotal += 1;
  }

  // Éléments nutritifs (poids moyen)
  const elements = ['azote', 'phosphore', 'potassium'];
  elements.forEach(element => {
    const min = culture[`${element}_min`];
    const max = culture[`${element}_max`];
    const valeur = analyseData[`${element}`];
    
    if (min !== null && max !== null && valeur !== undefined) {
      const score = calculerScoreCritere(valeur, min, max, 0.8);
      scoreTotal += score;
      details[element] = { score, ideal: `${min}-${max} ppm`, actuel: `${valeur} ppm` };
      criteresTotal += 0.8;
    }
  });

  // Calcul du score final (0-100)
  const scoreFinal = criteresTotal > 0 ? Math.round((scoreTotal / criteresTotal) * 100) : 0;
  
  // Générer un message de recommandation
  let message = '';
  if (scoreFinal >= 80) {
    message = `Excellente compatibilité avec ${culture.nom}. Votre sol est idéal pour cette culture.`;
  } else if (scoreFinal >= 60) {
    message = `Bonne compatibilité avec ${culture.nom}. Quelques ajustements mineurs pourraient améliorer les résultats.`;
  } else if (scoreFinal >= 40) {
    message = `Compatibilité moyenne avec ${culture.nom}. Des améliorations sont nécessaires pour de bons rendements.`;
  } else {
    message = `Faible compatibilité avec ${culture.nom}. Des modifications importantes du sol sont nécessaires.`;
  }

  return {
    score: scoreFinal,
    details,
    message
  };
}

/**
 * Enregistre une nouvelle analyse de sol et génère des recommandations
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.creerAnalyseSol = async (req, res) => {
  try {
    const { parcelle_id, capteur_id, ph, humidite, temperature, conductivite, azote, phosphore, potassium, observations } = req.body;
    const userId = req.user.id;

    // Vérifier que la parcelle appartient à l'utilisateur
    const parcelle = await Parcelle.findOne({
      include: [{
        model: Champ,
        where: { id_utilisateur: userId },
        required: true
      }],
      where: { id: parcelle_id }
    });

    if (!parcelle) {
      return res.status(404).json({ error: 'Parcelle non trouvée ou accès non autorisé' });
    }

    // Créer l'analyse de sol
    const analyse = await AnalyseSol.create({
      parcelle_id,
      utilisateur_id: userId,
      capteur_id: capteur_id || null,
      ph,
      humidite,
      temperature,
      conductivite,
      azote,
      phosphore,
      potassium,
      observations,
      date_analyse: new Date()
    });

    // Récupérer toutes les cultures actives
    const cultures = await Culture.findAll({
      where: { est_active: true }
    });

    // Préparer les données pour le calcul de compatibilité
    const analyseData = {
      ph,
      humidite,
      temperature,
      conductivite,
      azote,
      phosphore,
      potassium
    };

    // Calculer la compatibilité pour chaque culture
    const recommandations = [];
    for (const culture of cultures) {
      const compatibilite = calculerCompatibilite(culture, analyseData);
      
      // Enregistrer la recommandation en base de données
      const recommandation = await RecommendationCulture.create({
        analyse_sol_id: analyse.id,
        culture_id: culture.id,
        score_compatibilite: compatibilite.score,
        details: compatibilite.details,
        recommandation: compatibilite.message,
        date_creation: new Date()
      });

      recommandations.push({
        culture_id: culture.id,
        nom: culture.nom,
        score: compatibilite.score,
        details: compatibilite.details,
        message: compatibilite.message,
        rendement_moyen: culture.rendement_moyen,
        type_engrais: culture.type_engrais
      });
    }

    // Trier les recommandations par score décroissant
    recommandations.sort((a, b) => b.score - a.score);

    res.status(201).json({
      message: 'Analyse du sol enregistrée avec succès',
      analyse_id: analyse.id,
      recommandations
    });

  } catch (error) {
    console.error('Erreur lors de la création de l\'analyse du sol:', error);
    res.status(500).json({
      error: 'Erreur lors de la création de l\'analyse du sol',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Récupère l'historique des analyses pour une parcelle
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.getHistoriqueAnalyses = async (req, res) => {
  try {
    const { parcelle_id } = req.params;
    const userId = req.user.id;

    // Vérifier que la parcelle appartient à l'utilisateur
    const parcelle = await Parcelle.findOne({
      include: [{
        model: Champ,
        where: { id_utilisateur: userId },
        required: true
      }],
      where: { id: parcelle_id }
    });

    if (!parcelle) {
      return res.status(404).json({ error: 'Parcelle non trouvée ou accès non autorisé' });
    }

    // Récupérer les analyses avec les recommandations
    const analyses = await AnalyseSol.findAll({
      where: { parcelle_id },
      include: [
        {
          model: RecommendationCulture,
          include: [{
            model: Culture,
            attributes: ['id', 'nom', 'image_url']
          }],
          order: [['score_compatibilite', 'DESC']],
          limit: 3 // Seulement les 3 meilleures recommandations par analyse
        }
      ],
      order: [['date_analyse', 'DESC']]
    });

    res.json(analyses);

  } catch (error) {
    console.error('Erreur lors de la récupération de l\'historique des analyses:', error);
    res.status(500).json({
      error: 'Erreur lors de la récupération de l\'historique des analyses',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Détails d'une analyse spécifique avec recommandations
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.getAnalyseDetails = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Récupérer l'analyse avec vérification des droits
    const analyse = await AnalyseSol.findOne({
      include: [
        {
          model: Parcelle,
          include: [{
            model: Champ,
            where: { id_utilisateur: userId },
            required: true
          }]
        },
        {
          model: RecommendationCulture,
          include: [{
            model: Culture,
            attributes: ['id', 'nom', 'description', 'image_url', 'type_engrais', 'rendement_moyen', 'besoins_eau', 'resistance_secheresse']
          }],
          order: [['score_compatibilite', 'DESC']]
        }
      ],
      where: { id }
    });

    if (!analyse) {
      return res.status(404).json({ error: 'Analyse non trouvée ou accès non autorisé' });
    }

    // Formater la réponse
    const result = {
      id: analyse.id,
      date_analyse: analyse.date_analyse,
      observations: analyse.observations,
      donnees: {
        ph: analyse.ph,
        humidite: analyse.humidite,
        temperature: analyse.temperature,
        conductivite: analyse.conductivite,
        azote: analyse.azote,
        phosphore: analyse.phosphore,
        potassium: analyse.potassium
      },
      recommandations: analyse.RecommendationCultures.map(rec => ({
        culture_id: rec.Culture.id,
        nom: rec.Culture.nom,
        description: rec.Culture.description,
        image_url: rec.Culture.image_url,
        score: rec.score_compatibilite,
        details: rec.details,
        recommandation: rec.recommandation,
        type_engrais: rec.Culture.type_engrais,
        rendement_moyen: rec.Culture.rendement_moyen,
        besoins_eau: rec.Culture.besoins_eau,
        resistance_secheresse: rec.Culture.resistance_secheresse
      })),
      parcelle: {
        id: analyse.Parcelle.id,
        nom: analyse.Parcelle.nom,
        champ: {
          id: analyse.Parcelle.Champ.id,
          nom: analyse.Parcelle.Champ.nom,
          localite: analyse.Parcelle.Champ.localite
        }
      }
    };

    res.json(result);

  } catch (error) {
    console.error('Erreur lors de la récupération des détails de l\'analyse:', error);
    res.status(500).json({
      error: 'Erreur lors de la récupération des détails de l\'analyse',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Démarrer une campagne agricole à partir d'une recommandation
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 */
exports.demarrerCampagne = async (req, res) => {
  try {
    const { analyse_id, culture_id, date_debut } = req.body;
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
      progression: 0
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
        date_debut: new Date(dateEtape),
        date_fin: dateFinEtape,
        statut: 'à_faire'
      });

      // Mettre à jour la date de début pour l'étape suivante
      dateEtape = new Date(dateFinEtape);
      dateEtape.setDate(dateEtape.getDate() + 1); // Jour de transition entre les étapes
    }

    // Mettre à jour la date de fin de la campagne
    const derniereEtape = etapesCulture[etapesCulture.length - 1];
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
            model: EtapeCulture,
            include: [{
              model: Tache,
              as: 'Taches',
              required: false
            }]
          }],
          order: [['date_debut', 'ASC']]
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
