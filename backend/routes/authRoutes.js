const express = require('express');
const authController = require('../controllers/authController');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

// Routes d'authentification publiques
router.post('/register', authController.register);
router.post('/verify-otp', authController.verifyOtp);
router.post('/login', authController.login);

// Route protégée nécessitant une authentification
router.get('/profile', verifyToken, authController.getProfile);

module.exports = router;
