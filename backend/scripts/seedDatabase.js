const sequelize = require('../config/database');
const bcrypt = require('bcryptjs');
const User = require('../models/user');
const Champ = require('../models/champs');
const Parcelle = require('../models/parcelle');
const Capteur = require('../models/capteur');

async function seedMinimal() {
  try {
    console.log('🚀 Démarrage du seeding minimal (User, Champ, Parcelle, Capteur)...');

    // Synchroniser la base de données (force: true écrase la base existante)
    console.log('📦 Synchronisation des tables...');
    await sequelize.sync({ force: true });
    console.log('✅ Tables synchronisées !');

    // Créer un utilisateur de test
    const passwordHash = await bcrypt.hash('password123', 10);
    const [user] = await User.findOrCreate({
      where: { telephone: '700000000' },
      defaults: {
        nom: 'Admin',
        prenom: 'Test',
        telephone: '700000000',
        mot_de_passe: passwordHash,
        role: 'admin'
      }
    });

    // Créer un champ et une parcelle
    const [champ] = await Champ.findOrCreate({
      where: { nom: 'Champ de test', localite: 'Localité test' },
      defaults: { date_creation: new Date(), nom: 'Champ de test', localite: 'Localité test', id_utilisateur: user.id }
    });

    const [parcelle] = await Parcelle.findOrCreate({
      where: { nom: 'Parcelle test', superficie: 1.0 },
      defaults: { nom: 'Parcelle test', superficie: 1.0, id_champ: champ.id }
    });

    // Créer un capteur
    const [capteur] = await Capteur.findOrCreate({
      where: { code_serie: 'CAP-TEST-001' },
      defaults: { code_serie: 'CAP-TEST-001', type: 'portatif' }
    });

    console.log('\n✅ Seed minimal terminé :');
    console.log(`- Utilisateur: ${user.telephone} (mot de passe: password123)`);
    console.log(`- Champ: ${champ.nom}`);
    console.log(`- Parcelle: ${parcelle.nom}`);
    console.log(`- Capteur: ${capteur.code_serie}`);

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Erreur lors du seeding minimal :', error);
    process.exit(1);
  }
}

seedMinimal();
