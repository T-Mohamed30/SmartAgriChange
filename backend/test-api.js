const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testAPI() {
  try {
    console.log('🧪 Test de l\'API SmartAgriChange...\n');

    // Test 1: Récupérer toutes les espèces végétales
    console.log('1️⃣ Test GET /especes-vegetales');
    try {
      const response = await axios.get(`${BASE_URL}/especes-vegetales`);
      console.log(`✅ ${response.data.length} espèces trouvées`);
    } catch (error) {
      console.log('❌ Erreur:', error.response?.data?.message || error.message);
    }

    // Test 2: Récupérer les contenus d'une espèce
    console.log('\n2️⃣ Test GET /espece-contenus/:especeId');
    try {
      const response = await axios.get(`${BASE_URL}/espece-contenus/1`);
      console.log(`✅ ${response.data.length} contenus trouvés pour l'espèce 1`);
    } catch (error) {
      console.log('❌ Erreur:', error.response?.data?.message || error.message);
    }

    // Test 3: Récupérer les contenus par type
    console.log('\n3️⃣ Test GET /espece-contenus/:especeId/:type');
    try {
      const response = await axios.get(`${BASE_URL}/espece-contenus/1/morphologie`);
      console.log(`✅ Contenu morphologie trouvé: ${response.data.titre}`);
    } catch (error) {
      console.log('❌ Erreur:', error.response?.data?.message || error.message);
    }

    console.log('\n🏁 Tests terminés !');

  } catch (error) {
    console.error('❌ Erreur générale:', error.message);
  }
}

testAPI();
