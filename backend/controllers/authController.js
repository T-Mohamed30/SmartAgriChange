const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const otpService = require('../services/otpService');

const authController = {
  // INSCRIPTION AVEC OTP
  register: async (req, res) => {
    try {
      const { nom, prenom, telephone, mot_de_passe } = req.body;
      
      console.log('=== DÉBUT INSCRIPTION ===');
      console.log('Données reçues pour l\'inscription:', { 
        nom, 
        prenom, 
        telephone: telephone,
        mot_de_passe: mot_de_passe ? '***' : 'non fourni' 
      });

      // Vérifier si l'utilisateur existe déjà
      const existingUser = await User.findOne({ where: { telephone } });
      if (existingUser) {
        console.log('❌ Utilisateur existe déjà avec ce numéro');
        return res.status(400).json({ 
          success: false,
          message: "Ce numéro de téléphone est déjà utilisé." 
        });
      }

      // Générer OTP
      const otp = otpService.generateOTP();
      console.log(`📱 OTP généré pour ${telephone}: ${otp}`);
      
      // Stocker l'OTP
      otpService.storeOTP(telephone, otp);

      // Stocker temporairement les infos dans la session
      const registrationData = { 
        nom, 
        prenom, 
        telephone,
        mot_de_passe: mot_de_passe,
        timestamp: new Date().toISOString()
      };
      
      req.session.registrationData = registrationData;
      
      // Sauvegarder la session explicitement
      req.session.save(err => {
        if (err) {
          console.error('❌ Erreur lors de la sauvegarde de la session:', err);
          return res.status(500).json({ 
            success: false, 
            message: 'Erreur serveur lors de la création de la session' 
          });
        }
        
        console.log('✅ Données stockées en session:', registrationData);
        console.log('🆔 Session ID:', req.sessionID);
        
        return res.status(200).json({ 
          success: true,
          message: "OTP envoyé. Veuillez vérifier votre téléphone.",
          otp: process.env.NODE_ENV === 'development' ? otp : undefined // Ne renvoyer l'OTP qu'en développement
        });
      });
    } catch (err) {
      console.error('Erreur lors de l\'inscription:', err);
      return res.status(500).json({ 
        success: false,
        message: "Erreur lors de l'inscription.",
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
      });
    }
  },

  // VERIFICATION OTP & CREATION UTILISATEUR
  verifyOtp: async (req, res) => {
    try {
      console.log('=== DÉBUT VÉRIFICATION OTP ===');
      
      const { telephone, otp } = req.body;
      
      // Vérifier que les champs requis sont présents
      if (!telephone || !otp) {
        console.log('❌ Données manquantes:', { telephone, otp });
        return res.status(400).json({ 
          success: false,
          message: "Numéro de téléphone et OTP sont requis." 
        });
      }
      
      console.log('📱 Données reçues:', { 
        telephone, 
        otp,
        hasOtp: !!otp,
        otpLength: otp ? otp.length : 0
      });
      
      console.log('🆔 Session ID:', req.sessionID);
      console.log('🔍 Données de session:', JSON.stringify(req.session, null, 2));
      
      // Vérifier si les données d'inscription sont présentes dans la session
      if (!req.session.registrationData) {
        console.log('❌ ERREUR: Aucune donnée d\'inscription trouvée en session');
        return res.status(400).json({ 
          success: false,
          message: "Session expirée. Veuillez recommencer l'inscription." 
        });
      }

      if (req.session.registrationData.telephone !== telephone) {
        console.log('❌ ERREUR: Numéro de téléphone ne correspond pas à la session');
        console.log('📱 Téléphone session:', req.session.registrationData.telephone);
        console.log('📱 Téléphone fourni:', telephone);
        return res.status(400).json({ 
          success: false,
          message: "Numéro de téléphone invalide." 
        });
      }

      console.log('🔍 Vérification de l\'OTP...');
      const isOtpValid = otpService.verifyOTP(telephone, otp);
      
      if (!isOtpValid) {
        console.log('❌ ERREUR: OTP invalide ou expiré');
        return res.status(400).json({ 
          success: false,
          message: "OTP invalide ou expiré." 
        });
      }

      console.log('✅ OTP vérifié avec succès');
      
      // Vérifier à nouveau que le numéro n'est pas déjà utilisé (double vérification)
      const existingUser = await User.findOne({ where: { telephone } });
      if (existingUser) {
        console.log('❌ Numéro déjà utilisé:', telephone);
        // Nettoyer la session en cas d'erreur
        delete req.session.registrationData;
        otpService.removeOTP(telephone);
        
        return res.status(400).json({ 
          success: false,
          message: "Ce numéro de téléphone est déjà utilisé par un autre compte." 
        });
      }
      
      // Hasher le mot de passe
      const hashedPassword = await bcrypt.hash(req.session.registrationData.mot_de_passe, 10);
      console.log('🔑 Mot de passe hashé avec succès');
      
      // Créer l'utilisateur
      console.log('👤 Création de l\'utilisateur...');
      const user = await User.create({
        nom: req.session.registrationData.nom,
        prenom: req.session.registrationData.prenom,
        telephone: req.session.registrationData.telephone,
        mot_de_passe: hashedPassword,
        role: 'agriculteur' 
      });

      // Nettoyer la session
      delete req.session.registrationData;
      otpService.removeOTP(telephone);

      console.log('Session nettoyée');
      // Générer le token JWT
      const token = jwt.sign(
        { id: user.id, role: user.role },
        process.env.JWT_SECRET || "votre_secret_tres_securise",
        { expiresIn: "7d" }
      );

      return res.status(201).json({ 
        success: true,
        message: "Inscription réussie.",
        token,
        user: {
          id: user.id,
          nom: user.nom,
          prenom: user.prenom,
          telephone: user.telephone,
          role: user.role
        }
      });
    } catch (err) {
      console.error('Erreur lors de la vérification OTP:', err);
      return res.status(500).json({ 
        success: false,
        message: "Erreur lors de la vérification OTP."+err.message,
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
      });
    }
  },

  // CONNEXION
  login: async (req, res) => {
    try {
      const { telephone, mot_de_passe } = req.body;

      // Vérifier si l'utilisateur existe
      const user = await User.findOne({ 
        where: { telephone },
        attributes: { exclude: ['createdAt', 'updatedAt'] }
      });

      if (!user) {
        return res.status(400).json({ 
          success: false,
          message: "Identifiants invalides." 
        });
      }

      // Vérifier le mot de passe
      const isPasswordValid = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
      if (!isPasswordValid) {
        return res.status(400).json({ 
          success: false,
          message: "Identifiants invalides." 
        });
      }

      // Générer le token JWT
      const token = jwt.sign(
        { id: user.id, role: user.role },
        process.env.JWT_SECRET || "votre_secret_tres_securise",
        { expiresIn: "7d" }
      );

      // Ne pas renvoyer le mot de passe dans la réponse
      const userResponse = user.get({ plain: true });
      delete userResponse.mot_de_passe;

      return res.status(200).json({ 
        success: true,
        message: "Connexion réussie.", 
        token,
        user: userResponse
      });
    } catch (err) {
      console.error('Erreur lors de la connexion:', err);
      return res.status(500).json({ 
        success: false,
        message: "Erreur lors de la connexion.",
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
      });
    }
  },

  // PROFIL UTILISATEUR
  getProfile: async (req, res) => {
    try {
      // L'utilisateur est disponible dans req.user grâce au middleware d'authentification
      const user = await User.findByPk(req.user.id, {
        attributes: { exclude: ['mot_de_passe', 'createdAt', 'updatedAt'] }
      });

      if (!user) {
        return res.status(404).json({
          success: false,
          message: "Utilisateur non trouvé."
        });
      }

      return res.status(200).json({
        success: true,
        user
      });
    } catch (err) {
      console.error('Erreur lors de la récupération du profil:', err);
      return res.status(500).json({
        success: false,
        message: "Erreur lors de la récupération du profil.",
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
      });
    }
  }
};

module.exports = authController;
