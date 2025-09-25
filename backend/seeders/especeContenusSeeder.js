const { EspeceVegetale, EspeceContenus } = require('../models');

async function seedEspeceContenus() {
  try {
    console.log('🌱 Seeding des contenus des espèces...');

    // Vérifier si l'espèce manguier existe
    let espece = await EspeceVegetale.findOne({
      where: { nom_commun: 'Manguier' }
    });

    if (!espece) {
      console.log('⚠️  Espèce "Manguier" non trouvée. Création...');
      espece = await EspeceVegetale.create({
        nom_commun: 'Manguier',
        nom_scientifique: 'Mangifera indica',
        description: 'Arbre fruitier tropical produisant la mangue',
        image_url: 'https://example.com/manguier.jpg',
        est_active: true
      });
    }

    // Données pour la morphologie
    const morphologieData = [
      {
        type_contenu: 'morphologie',
        titre: 'Racines',
        contenu: 'Le manguier possède un système racinaire pivotant profond qui peut atteindre 6 mètres. Les racines sont robustes et s\'adaptent bien aux sols tropicaux.',
        ordre_affichage: 1
      },
      {
        type_contenu: 'morphologie',
        titre: 'Tronc',
        contenu: 'Tronc droit et cylindrique pouvant atteindre 30-40 cm de diamètre. L\'écorce est rugueuse, brun grisâtre avec des fissures longitudinales.',
        ordre_affichage: 2
      },
      {
        type_contenu: 'morphologie',
        titre: 'Feuilles',
        contenu: 'Feuilles alternes, simples, oblongues-lancéolées, mesurant 15-30 cm de long. Elles sont coriaces, vert foncé et brillantes sur le dessus.',
        ordre_affichage: 3
      },
      {
        type_contenu: 'morphologie',
        titre: 'Fleurs',
        contenu: 'Fleurs petites, jaune verdâtre, regroupées en panicules terminaux. Floraison abondante de décembre à mars selon les régions.',
        ordre_affichage: 4
      },
      {
        type_contenu: 'morphologie',
        titre: 'Fruits',
        contenu: 'Drupe charnue de forme variable (ovale, ronde, oblongue), pesant 200g à 2kg. La chair est juteuse, sucrée, de couleur jaune orangé.',
        ordre_affichage: 5
      }
    ];

    // Données pour les soins
    const soinsData = [
      {
        type_contenu: 'soins',
        titre: 'Arrosage',
        contenu: 'Arroser régulièrement pendant les 2-3 premières années. Ensuite, tolère bien la sécheresse. Éviter l\'excès d\'eau qui peut causer la pourriture des racines.',
        ordre_affichage: 1
      },
      {
        type_contenu: 'soins',
        titre: 'Fertilisation',
        contenu: 'Apporter un engrais NPK équilibré au début de la saison des pluies. Éviter l\'excès d\'azote qui favorise la végétation au détriment de la fructification.',
        ordre_affichage: 2
      },
      {
        type_contenu: 'soins',
        titre: 'Taille',
        contenu: 'Tailler légèrement après la récolte pour maintenir la forme. Éliminer les branches mortes ou malades. Conserver une forme ouverte pour une bonne circulation d\'air.',
        ordre_affichage: 3
      },
      {
        type_contenu: 'soins',
        titre: 'Protection',
        contenu: 'Protéger contre les ravageurs (mouche des fruits, cochenilles) et maladies (anthracnose, oïdium). Traitements préventifs recommandés.',
        ordre_affichage: 4
      }
    ];

    // Données pour les conditions
    const conditionsData = [
      {
        type_contenu: 'conditions',
        titre: 'Climat',
        contenu: 'Climat tropical chaud, température optimale 24-30°C. Sensible au froid (ne supporte pas <15°C). Besoin d\'une saison sèche pour la floraison.',
        ordre_affichage: 1
      },
      {
        type_contenu: 'conditions',
        titre: 'Sol',
        contenu: 'Sols bien drainés, légèrement acides à neutres (pH 5.5-7.5). Évite les sols lourds et mal drainés. Préfère les sols profonds et fertiles.',
        ordre_affichage: 2
      },
      {
        type_contenu: 'conditions',
        titre: 'Luminosité',
        contenu: 'Exposition ensoleillée, minimum 6-8 heures de soleil par jour. Ne supporte pas l\'ombre prolongée qui réduit la production.',
        ordre_affichage: 3
      }
    ];

    // Données pour les problèmes
    const problemesData = [
      {
        type_contenu: 'problemes',
        titre: 'Anthracnose',
        contenu: 'Maladie cryptogamique causant des taches noires sur feuilles et fruits. Traitement : fongicides à base de cuivre, élimination des parties atteintes.',
        ordre_affichage: 1
      },
      {
        type_contenu: 'problemes',
        titre: 'Mouche des fruits',
        contenu: 'Ravageur pondant dans les fruits mûrs. Traitement : sacs en papier sur les fruits, pièges à phéromones, traitements insecticides.',
        ordre_affichage: 2
      },
      {
        type_contenu: 'problemes',
        titre: 'Carence en zinc',
        contenu: 'Feuilles petites avec nervures vertes et limbe jaune. Traitement : apport d\'oligo-éléments, pulvérisation foliaire de sulfate de zinc.',
        ordre_affichage: 3
      }
    ];

    // Données pour l'économie
    const economieData = [
      {
        type_contenu: 'economie',
        titre: 'Production',
        contenu: 'Un manguier adulte produit 100-300 kg de fruits par an selon la variété et les conditions. La production commence 4-6 ans après plantation.',
        ordre_affichage: 1
      },
      {
        type_contenu: 'economie',
        titre: 'Prix marché',
        contenu: 'Prix moyen : 500-1500 FCFA/kg selon la saison et la qualité. Pics de prix en contre-saison. Marché local important.',
        ordre_affichage: 2
      },
      {
        type_contenu: 'economie',
        titre: 'Utilisations',
        contenu: 'Consommation fraîche, jus, confitures, séchage. Sous-produits : bois, feuilles (médecine traditionnelle), noyaux (huile).',
        ordre_affichage: 3
      },
      {
        type_contenu: 'economie',
        titre: 'Importance économique',
        contenu: 'Culture majeure en zones tropicales. Source de revenus pour petits producteurs. Exportation possible vers l\'Europe (contre-saison).',
        ordre_affichage: 4
      }
    ];

    // Insérer toutes les données
    const allData = [...morphologieData, ...soinsData, ...conditionsData, ...problemesData, ...economieData];

    for (const data of allData) {
      await EspeceContenus.findOrCreate({
        where: {
          espece_id: espece.id,
          type_contenu: data.type_contenu,
          titre: data.titre
        },
        defaults: {
          ...data,
          espece_id: espece.id
        }
      });
    }

    console.log('✅ Seeding terminé avec succès !');
    console.log(`📊 ${allData.length} contenus ajoutés pour l'espèce ${espece.nom_commun}`);

  } catch (error) {
    console.error('❌ Erreur lors du seeding :', error);
  }
}

module.exports = seedEspeceContenus;
