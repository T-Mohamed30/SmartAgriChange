// backend/services/otpService.js

const otpStore = {}; // stocke les OTP par téléphone

// Fonction utilitaire pour le débogage
function debugStore() {
  console.log('=== CONTENU ACTUEL DU STOCKAGE OTP ===');
  console.log(JSON.stringify(otpStore, null, 2));
  console.log('======================================');
}

const otpService = {
  // Générer un OTP à 6 chiffres
  generateOTP() {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    console.log(`OTP généré pour le débogage: ${otp}`);
    return otp;
  },

  // Stocker l'OTP avec une durée d'expiration (10 minutes)
  storeOTP(telephone, otp) {
    otpStore[telephone] = {
      code: otp,
      expiresAt: Date.now() + 10 * 60 * 1000 // 10 minutes
    };
    console.log(`OTP stocké pour ${telephone}:`, otpStore[telephone]);
    debugStore();
  },

  // Vérifier l'OTP
  verifyOTP(telephone, otp) {
    console.log('=== DÉBUT VÉRIFICATION OTP ===');
    console.log('Téléphone:', telephone);
    console.log('OTP fourni:', otp);
    debugStore();
    
    const record = otpStore[telephone];
    
    if (!record) {
      console.log('❌ Aucun OTP trouvé pour ce numéro');
      return false;
    }
    
    console.log('OTP trouvé en base:', record);
    
    if (record.expiresAt < Date.now()) {
      console.log(`❌ OTP expiré (expiré à: ${new Date(record.expiresAt).toISOString()}, maintenant: ${new Date().toISOString()})`);
      delete otpStore[telephone];
      return false;
    }
    
    const isValid = record.code === otp;
    console.log(`🔍 Comparaison OTP: ${record.code} === ${otp} -> ${isValid ? '✅' : '❌'}`);
    console.log('=== FIN VÉRIFICATION OTP ===');
    return isValid;
  },

  // Supprimer l'OTP après utilisation
  removeOTP(telephone) {
    console.log('Suppression de l\'OTP pour:', telephone);
    delete otpStore[telephone];
  }
};

module.exports = otpService;
