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
      const { telephone, otp, nom, prenom, mot_de_passe } = req.body;

      // Vérifier que les champs requis sont présents
      if (!telephone || !otp || !nom || !prenom || !mot_de_passe) {
        console.log('❌ Données manquantes:', { telephone, otp, nom, prenom, mot_de_passe });
        return res.status(400).json({
          success: false,
          message: "Tous les champs sont requis."
        });
      }

      console.log('📱 Données reçues:', { telephone, otp, nom, prenom });

      // Vérification de l'OTP
      const isOtpValid = otpService.verifyOTP(telephone, otp);
      if (!isOtpValid) {
        console.log('❌ ERREUR: OTP invalide ou expiré');
        return res.status(400).json({
          success: false,
          message: "OTP invalide ou expiré."
        });
      }

      // Vérifier que le numéro n'est pas déjà utilisé
      const existingUser = await User.findOne({ where: { telephone } });
      if (existingUser) {
        console.log('❌ Numéro déjà utilisé:', telephone);
        otpService.removeOTP(telephone);
        return res.status(400).json({
          success: false,
          message: "Ce numéro de téléphone est déjà utilisé par un autre compte."
        });
      }

      // Hasher le mot de passe
      const hashedPassword = await bcrypt.hash(mot_de_passe, 10);
      console.log("� Création de l'utilisateur...");

      // Créer l'utilisateur
      const user = await User.create({
        nom,
        prenom,
        telephone,
        mot_de_passe: hashedPassword,
        role: 'agriculteur'
      });

      otpService.removeOTP(telephone);

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
        message: "Erreur lors de la vérification OTP." + err.message,
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
  },

  updateProfile: async (req, res) => {
    try {
      const { nom, prenom } = req.body;
      const userId = req.user.id;

      // Préparer les champs à mettre à jour
      const updateData = {};

      if (nom !== undefined) updateData.nom = nom;
      if (prenom !== undefined) updateData.prenom = prenom;

      // Vérifier qu'il y a au moins un champ à mettre à jour
      if (Object.keys(updateData).length === 0) {
        return res.status(400).json({
          success: false,
          message: "Aucun champ à mettre à jour."
        });
      }

      // Mettre à jour l'utilisateur
      const [updated] = await User.update(updateData, { where: { id: userId } });

      if (!updated) {
        return res.status(404).json({
          success: false,
          message: "Utilisateur non trouvé."
        });
      }

      // Récupérer l'utilisateur mis à jour (sans le mot de passe)
      const updatedUser = await User.findByPk(userId, {
        attributes: { exclude: ['mot_de_passe'] }
      });

      return res.status(200).json({
        success: true,
        message: "Profil mis à jour avec succès.",
        user: updatedUser
      });
    } catch (err) {
      console.error('Erreur lors de la mise à jour du profil:', err);
      return res.status(500).json({
        success: false,
        message: "Erreur lors de la mise à jour du profil.",
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
      });
    }
  },

  changePassword: async (req, res) => {
    try {
      const { mot_de_passe_actuel, nouveau_mot_de_passe } = req.body;
      const userId = req.user.id;

      // Vérifier que les champs sont présents
      if (!mot_de_passe_actuel || !nouveau_mot_de_passe) {
        return res.status(400).json({
          success: false,
          message: "Mot de passe actuel et nouveau mot de passe requis."
        });
      }

      // Récupérer l'utilisateur
      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: "Utilisateur non trouvé."
        });
      }

      // Vérifier le mot de passe actuel
      const isMatch = await bcrypt.compare(mot_de_passe_actuel, user.mot_de_passe);
      if (!isMatch) {
        return res.status(401).json({
          success: false,
          message: "Mot de passe actuel incorrect."
        });
      }

      // Hasher le nouveau mot de passe
      const hashedPassword = await bcrypt.hash(nouveau_mot_de_passe, 10);

      // Mettre à jour le mot de passe
      await User.update(
        { mot_de_passe: hashedPassword },
        { where: { id: userId } }
      );

      return res.status(200).json({
        success: true,
        message: "Mot de passe changé avec succès."
      });
    } catch (err) {
      console.error('Erreur lors du changement de mot de passe:', err);
      return res.status(500).json({
        success: false,
        message: "Erreur lors du changement de mot de passe.",
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
      });
    }
  }
  ,
  // LOGIN UTILISATEUR
  login: async (req, res) => {
    try {
      let { telephone, mot_de_passe } = req.body;
      // Defensive: trim inputs
      if (typeof telephone === 'string') telephone = telephone.trim();
      if (typeof mot_de_passe === 'string') mot_de_passe = mot_de_passe.trim();
      if (!telephone || !mot_de_passe) {
        return res.status(400).json({
          success: false,
          message: "Téléphone et mot de passe requis."
        });
      }
      // Always log minimal, masked info to help debug login issues (no raw passwords)
      try {
        console.log(`LOGIN ATTEMPT: incomingTelephone='${telephone}', mot_de_passe_length=${mot_de_passe ? mot_de_passe.length : 0}`);
      } catch (e) {
        console.log('LOGIN ATTEMPT: error logging incoming data', e);
      }
      const user = await User.findOne({ where: { telephone } });
      if (!user) {
        return res.status(401).json({
          success: false,
          message: "Utilisateur non trouvé."
        });
      }
      // Log masked stored hash snippet and DB telephone for diagnosis (no full hash printed)
      try {
        const hashSample = user.mot_de_passe ? String(user.mot_de_passe).slice(0, 6) + '...' : 'null';
        console.log(`LOGIN: userFound id=${user.id}, telephone_db='${user.telephone}', storedHashSample=${hashSample}`);
      } catch (e) {
        console.log('LOGIN: error reading stored hash', e);
      }

      const isMatch = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
      try {
        console.log(`LOGIN: bcrypt.compare result = ${isMatch}`);
      } catch (e) {
        console.log('LOGIN: error logging compare result', e);
      }
      if (!isMatch) {
        return res.status(401).json({
          success: false,
          message: "Mot de passe incorrect."
        });
      }
      // Générer le token JWT
      const token = jwt.sign(
        { id: user.id, role: user.role },
        process.env.JWT_SECRET || "votre_secret_tres_securise",
        { expiresIn: "7d" }
      );
      return res.status(200).json({
        success: true,
        message: "Connexion réussie.",
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
      console.error('Erreur lors de la connexion:', err);
      return res.status(500).json({
        success: false,
        message: "Erreur lors de la connexion.",
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
      });
    }
  }
};

module.exports = authController;
