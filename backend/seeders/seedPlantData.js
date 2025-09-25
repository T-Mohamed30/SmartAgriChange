const { Plante, Maladie, MorphologiePlante, SoinsCulture, ConditionsIdeales, ContexteEconomique } = require('../models');

async function seedPlantData() {
  try {
    // Seed Plantes
    const plantes = await Plante.bulkCreate([
      {
        nom_scientifique: 'Phaseolus vulgaris',
        nom_commun: 'Haricot',
        description: 'Le haricot commun est une plante herbacée annuelle largement cultivée pour ses gousses et ses graines comestibles. Originaire d\'Amérique, il constitue une source importante de protéines végétales dans de nombreuses régions du monde.',
        famille_botanique: 'Fabaceae',
        type: 'plante_herbacée',
        cycle_vie: 'annuel',
        galerie_photos: [
          'assets/images/Niebe_1.jpeg',
          'assets/images/Niebe_2.jpeg',
          'assets/images/Niebe_3.jpeg',
          'assets/images/Niebe_4.jpeg'
        ],
        est_active: true
      }
    ]);

    // Seed Maladies
    await Maladie.bulkCreate([
      {
        nom: 'Tâche brune (anthracnose)',
        description: 'L\'anthracnose du haricot est une maladie cryptogamique causée par le champignon Colletotrichum lindemuthianum. Elle entraîne des lésions brunes à noires sur les feuilles, les tiges et les gousses, réduisant fortement le rendement.',
        symptomes: [
          'Taches brun-noir sur les nervures des feuilles',
          'Lésions allongées sombres sur les tiges et pétioles',
          'Gousses tachées et enfoncées avec contour rouge-brun',
          'Graines décolorées et de mauvaise qualité'
        ],
        causes: [
          'Champignon Colletotrichum lindemuthianum',
          'Semences infectées',
          'Conditions fraîches et humides (pluie, irrigation par aspersion)',
          'Débris de culture contaminés'
        ],
        traitement: 'Utiliser des semences certifiées, pratiquer une rotation culturale, éliminer les résidus de culture, appliquer un fongicide adapté (ex. à base de cuivre) en cas d\'infection sévère.',
        prevention: 'Éviter d\'utiliser des graines contaminées, privilégier les rotations longues, maintenir une bonne aération des cultures, surveiller les champs pendant la saison des pluies.',
        plante_id: plantes[0].id,
        gravite: 'élevée'
      }
    ]);

    // Seed Morphologie
    await MorphologiePlante.bulkCreate([
      {
        plante_id: plantes[0].id,
        partie: 'racines',
        description: 'Racines pivotantes avec des nodules fixateurs d\'azote.'
      },
      {
        plante_id: plantes[0].id,
        partie: 'tiges',
        description: 'Tiges herbacées, dressées ou grimpantes selon les variétés.'
      },
      {
        plante_id: plantes[0].id,
        partie: 'feuilles',
        description: 'Feuilles composées trifoliées, vertes, légèrement velues.'
      },
      {
        plante_id: plantes[0].id,
        partie: 'fleurs',
        description: 'Fleurs papilionacées, généralement blanches, roses ou violettes.'
      },
      {
        plante_id: plantes[0].id,
        partie: 'fruits',
        description: 'Gousses allongées contenant plusieurs graines de formes et couleurs variées.'
      }
    ]);

    // Seed Soins Culture
    await SoinsCulture.bulkCreate([
      {
        plante_id: plantes[0].id,
        type_soin: 'arrosage',
        description: 'Maintenir le sol humide sans excès d\'eau.',
        frequence: '2 à 3 fois par semaine',
        saison: 'saison sèche'
      },
      {
        plante_id: plantes[0].id,
        type_soin: 'fertilisation',
        description: 'Apporter du compost organique et un apport équilibré en potassium et phosphore.',
        frequence: '2 fois pendant le cycle',
        saison: 'croissance et floraison'
      }
    ]);

    // Seed Conditions Ideales
    await ConditionsIdeales.bulkCreate([
      {
        plante_id: plantes[0].id,
        type_condition: 'température',
        description: 'Température optimale pour la croissance',
        valeur_min: 18,
        valeur_max: 28,
        unite: '°C'
      },
      {
        plante_id: plantes[0].id,
        type_condition: 'humidité',
        description: 'Humidité relative modérée pour éviter les maladies cryptogamiques',
        valeur_min: 50,
        valeur_max: 70,
        unite: '%'
      },
      {
        plante_id: plantes[0].id,
        type_condition: 'pH',
        description: 'pH optimal du sol',
        valeur_min: 6,
        valeur_max: 7.5,
        unite: ''
      },
      {
        plante_id: plantes[0].id,
        type_condition: 'lumière',
        description: 'Exposition en plein soleil',
        valeur_min: 6,
        valeur_max: 12,
        unite: 'heures/jour'
      }
    ]);

    // Seed Contexte Economique
    await ContexteEconomique.bulkCreate([
      {
        plante_id: plantes[0].id,
        importance_economique: 'Le haricot est une source essentielle de protéines végétales dans de nombreux pays d\'Afrique, d\'Amérique latine et d\'Asie.',
        contexte_local: 'Culture largement pratiquée dans les exploitations familiales et petits exploitants, souvent pour l\'autoconsommation et la vente locale.',
        valeur_marche: 'Marché important tant au niveau local qu\'international, prix variant selon la variété et la saison.',
        saison_production: 'Saison pluviale et intersaison irriguée'
      }
    ]);

    console.log('Plant data seeded successfully');
  } catch (error) {
    console.error('Error seeding plant data:', error);
  }
}

module.exports = seedPlantData;
