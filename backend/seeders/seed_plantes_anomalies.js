const { sequelize, Plante, CategorieAnomalie, Anomalie, SolutionAnomalie, AttributPlante } = require('../models');

async function seed() {
  await sequelize.sync();
  // Allow SQLite to wait on locks instead of failing immediately
  try {
    await sequelize.query("PRAGMA busy_timeout = 5000;");
  } catch (e) {
    // ignore if not supported
  }

  // Retry helper for transient SQLITE_BUSY
  async function retryOp(fn, attempts = 6, delayMs = 300) {
    for (let i = 0; i < attempts; i++) {
      try {
        return await fn();
      } catch (err) {
        const code = err && err.parent && err.parent.code ? err.parent.code : err && err.code ? err.code : null;
        if (code === 'SQLITE_BUSY') {
          await new Promise(r => setTimeout(r, delayMs));
          continue;
        }
        throw err;
      }
    }
    // final attempt
    return await fn();
  }

  // 1) Plante: Haricot (Niébé)
  let plante = await Plante.findOne({ where: { nom_latin: 'Vigna unguiculata' } });
  if (!plante) {
    plante = await Plante.create({
      nom: 'Haricot (Niébé)',
      nom_latin: 'Vigna unguiculata',
      famille_botanique: 'Fabaceae',
      genre: 'Vigna',
      ordre: 'Fabales',
      type: 'herbacée',
      cycle_de_vie: 'annuelle',
      zone_geographique: 'Afrique tropicale (Burkina Faso, zones soudano-sahéliennes)'
    });
  }

  // 2) Attributs détaillés (idempotent)
  const attributs = [
    // Morphologie
    { type_attribut: 'morphologie', libelle: 'Racines', valeur: 'Système racinaire pivotant profond, avec nodules fixateurs d’azote' },
    { type_attribut: 'morphologie', libelle: 'Tiges', valeur: 'Herbacées, rampantes ou grimpantes, parfois érigées selon variétés' },
    { type_attribut: 'morphologie', libelle: 'Feuilles', valeur: 'Composées trifoliées, vertes, de taille moyenne à grande' },
    { type_attribut: 'morphologie', libelle: 'Fleurs', valeur: 'Papilionacées, blanches, violettes ou jaunâtres' },
    { type_attribut: 'morphologie', libelle: 'Fruits', valeur: 'Gousses allongées (10–30 cm), contenant 8–20 graines' },
    // Soins
    { type_attribut: 'soins', libelle: 'Eau', valeur: 'Besoins modérés, tolérant la sécheresse, arrosage faible sauf au semis et floraison' },
    { type_attribut: 'soins', libelle: 'Fertilisation', valeur: "Apport modéré en phosphore et potassium ; fixation symbiotique de l’azote" },
    { type_attribut: 'soins', libelle: 'Taille/entretien', valeur: "Sarclage nécessaire en début de cycle ; éviter la compétition avec les adventices" },
    { type_attribut: 'soins', libelle: 'Propagation', valeur: 'Semis direct en poquet, 3–4 graines par trou, espacement 40–60 cm' },
    // Calendrier cultural
    { type_attribut: 'calendrier', libelle: 'Semis', valeur: 'Juin–juillet (pluvieux)' },
    { type_attribut: 'calendrier', libelle: 'Floraison', valeur: '40–50 jours après semis' },
    { type_attribut: 'calendrier', libelle: 'Récolte', valeur: 'Septembre–octobre' },
    // Conditions idéales
    { type_attribut: 'conditions', libelle: 'Température', valeur: '25–35 °C (tolère chaleur)' },
    { type_attribut: 'conditions', libelle: 'Sol', valeur: "Bien drainé, léger, tolérant sols pauvres, pH 5,5–6,5" },
    { type_attribut: 'conditions', libelle: 'Lumière', valeur: 'Plein soleil' },
    { type_attribut: 'zones', libelle: 'Zones de culture principales', valeur: 'Régions soudaniennes et sahéliennes du Burkina Faso' },
    { type_attribut: 'saisonnalite', libelle: 'Saisonnalité locale', valeur: "Culture pluviale de saison humide, parfois en contre-saison irriguée" },
    // Problèmes & solutions
    { type_attribut: 'problems', libelle: 'Maladies courantes', valeur: 'Taches brunes, fusariose, pourriture cendrée, anthracnose' },
    { type_attribut: 'problems', libelle: 'Ravageurs', valeur: 'Bruches (post-récolte), thrips, pucerons' },
    { type_attribut: 'problems', libelle: 'Carences fréquentes', valeur: 'Phosphore et potassium' },
    { type_attribut: 'problems', libelle: 'Solutions', valeur: 'Rotation culturale, semences résistantes, traitements fongicides sélectifs' },
    // Économie & contexte
    { type_attribut: 'economie', libelle: 'Prix marché local (Burkina Faso)', valeur: '400–1000 FCFA/kg selon saison et qualité' },
    { type_attribut: 'economie', libelle: 'Utilisation', valeur: 'Consommation humaine (grains secs, feuilles fraîches), alimentation animale' },
    { type_attribut: 'economie', libelle: 'Importance sociale', valeur: "Culture vivrière stratégique et source de revenus pour petits exploitants" }
  ];

  for (const att of attributs) {
    await retryOp(() => AttributPlante.findOrCreate({
      where: { id_plante: plante.id, libelle: att.libelle },
      defaults: { id_plante: plante.id, type_attribut: att.type_attribut, libelle: att.libelle, valeur: att.valeur }
    }));
  }

  // 3) Catégorie
  let cat = await CategorieAnomalie.findOne({ where: { nom: 'Maladies fongiques' } });
  if (!cat) cat = await CategorieAnomalie.create({ nom: 'Maladies fongiques', description: 'Maladies causées par champignons' });

  // 4) Anomalies spécifiques
  const anomalies = [
    {
      nom: 'Tâches brunes',
      description: 'Maladie foliaire entraînant des taches nécrotiques sur les feuilles',
      symptomes: 'Petites taches brunes arrondies, se rejoignant en plages nécrotiques, jaunissement, chute prématurée des feuilles',
      causes: 'Champignons (souvent Cercospora spp.), humidité élevée, semences infectées'
    },
    {
      nom: 'Fusariose',
      description: 'Flétrissement systémique causé par Fusarium oxysporum',
      symptomes: 'Jaunissement des feuilles, flétrissement progressif, brunissement vasculaire, mort des plants',
      causes: 'Champignon du sol, contamination par résidus infectés, sols mal drainés'
    },
    {
      nom: 'Pourriture cendrée',
      description: 'Pourriture des tiges et gousses due à un champignon',
      symptomes: "Lésions humides sur tiges/gousses, aspect cotonneux blanc (mycélium), scléros noirs",
      causes: 'Champignon Sclerotinia sclerotiorum, favorisé par forte humidité et sols argileux'
    }
  ];

  for (const data of anomalies) {
      const [a, created] = await Anomalie.findOrCreate({
        where: { nom: data.nom, id_categorie: cat.id },
        defaults: { description: data.description, symptomes: data.symptomes, causes: data.causes, id_categorie: cat.id }
      });

      if (!created) {
        // update existing anomaly to match provided authoritative text
        await a.update({ description: data.description, symptomes: data.symptomes, causes: data.causes });
      }

      // Solutions: prevention + treatment (find or create, but update if exists)
      const preventionText = data.nom === 'Tâches brunes'
        ? 'Utiliser semences certifiées, rotation culturale de 2–3 ans, espacement correct pour aération'
        : data.nom === 'Fusariose'
          ? 'Rotation culturale avec non-légumineuses, destruction des résidus infectés, semences résistantes'
          : 'Rotation culturale longue, éviter excès d’humidité, semis sur buttes';

      const solutionText = data.nom === 'Tâches brunes'
        ? 'Pulvérisations préventives de fongicides à base de cuivre ou mancozèbe'
        : data.nom === 'Fusariose'
          ? 'Amendements organiques; traitements fongiques limités (efficacité partielle)'
          : 'Arrachage et destruction des plants malades ; fongicides spécifiques en conditions sévères';

      const [pre, preCreated] = await retryOp(() => SolutionAnomalie.findOrCreate({ where: { id_anomalie: a.id, type_solution: 'prevention' }, defaults: { id_anomalie: a.id, type_solution: 'prevention', contenu: preventionText } }));
      if (!preCreated) await pre.update({ contenu: preventionText });

      const [sol, solCreated] = await retryOp(() => SolutionAnomalie.findOrCreate({ where: { id_anomalie: a.id, type_solution: 'solution' }, defaults: { id_anomalie: a.id, type_solution: 'solution', contenu: solutionText } }));
      if (!solCreated) await sol.update({ contenu: solutionText });

    // Solutions: prevention + traitement
    await retryOp(() => SolutionAnomalie.findOrCreate({ where: { id_anomalie: a.id, type_solution: 'prevention' }, defaults: { id_anomalie: a.id, type_solution: 'prevention', contenu: data.nom === 'Tâches brunes' ? 'Utiliser semences certifiées, rotation culturale de 2–3 ans, espacement correct pour aération' : data.nom === 'Fusariose' ? 'Rotation culturale avec non-légumineuses, destruction des résidus infectés, semences résistantes' : 'Rotation culturale longue, éviter excès d’humidité, semis sur buttes' } }));

    await retryOp(() => SolutionAnomalie.findOrCreate({ where: { id_anomalie: a.id, type_solution: 'solution' }, defaults: { id_anomalie: a.id, type_solution: 'solution', contenu: data.nom === 'Tâches brunes' ? 'Pulvérisations préventives de fongicides à base de cuivre ou mancozèbe' : data.nom === 'Fusariose' ? 'Amendements organiques; traitements fongiques limités (efficacité partielle)' : 'Arrachage et destruction des plants malades ; fongicides spécifiques en conditions sévères' } }));
  }

  console.log('Seeder planted: Niébé (Haricot) + 3 anomalies');
}

if (require.main === module) {
  seed().then(() => { console.log('Seed done'); process.exit(0); }).catch(e => { console.error(e); process.exit(1); });
}

module.exports = seed;
