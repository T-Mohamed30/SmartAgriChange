const express = require('express');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const cors = require('cors');
require('dotenv').config();
const bodyParser = require('body-parser');
const morgan = require('morgan');
const MemoryStore = require('memorystore')(session);

// Configuration CORS pour autoriser les requêtes du frontend
const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:5000',
      'http://127.0.0.1:5000',
      'http://localhost:50000', // Port par défaut de Flutter Web
      'http://localhost:8080',
      'http://127.0.0.1:8080',
      'http://10.0.2.2:3000', // Pour émulateur Android
      'http://10.0.2.2:5000',
      'http://10.0.2.2:8080'
    ];

    // En développement, accepter toutes les origines
    if (process.env.NODE_ENV !== 'production') {
      return callback(null, true);
    }

    // En production, vérifier l'origine
    if (origin && allowedOrigins.indexOf(origin) === -1) {
      const msg = `L'origine ${origin} n'est pas autorisée par CORS`;
      console.error(msg);
      return callback(new Error(msg), false);
    }

    return callback(null, true);
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Requested-With',
    'Accept',
    'Cookie',
    'Set-Cookie',
    'X-CSRF-Token'
  ],
  exposedHeaders: ['Set-Cookie', 'Authorization'],
  credentials: true,
  optionsSuccessStatus: 200,
  maxAge: 86400 // 24 heures
};

// Instance express
const app = express();
app.use(cookieParser());

// Middleware
app.use(morgan('dev'));

// Middleware de logging des requêtes
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.originalUrl}`);
  console.log('Headers:', req.headers);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('Body:', JSON.stringify(req.body, null, 2));
  }
  next();
});

app.use(cors(corsOptions));
app.options('*', cors(corsOptions)); // Gestion des requêtes OPTIONS

// Augmenter la limite de taille des requêtes
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));

// Configuration de la session
const sessionConfig = {
  secret: process.env.SESSION_SECRET || 'dev_secret_key_123',
  resave: true,
  saveUninitialized: true,
  store: new MemoryStore({
    checkPeriod: 86400000, // Nettoyer les entrées expirées toutes les 24h
  }),
  cookie: {
    secure: false, // Désactivé pour le développement
    maxAge: 24 * 60 * 60 * 1000, // 24 heures
    httpOnly: true,
    sameSite: 'none', // Permet le cookie cross-origin en dev
    path: '/'
    // NE PAS mettre domain en dev
  },
  name: 'smartagri.sid',
  rolling: true,
  unset: 'destroy',
  // proxy: true // À activer uniquement derrière un proxy ou en production avec HTTPS
};

// Configuration spécifique pour la production
if (process.env.NODE_ENV === 'production') {
  sessionConfig.cookie.secure = true;
  sessionConfig.cookie.sameSite = 'none';
  sessionConfig.cookie.domain = '.votredomaine.com';
}

// Activez cette ligne pour voir les en-têtes de session
app.set('trust proxy', 1);

// Configuration de la session
if (process.env.NODE_ENV === 'production') {
  app.set('trust proxy', 1); // Faire confiance au premier proxy
  sessionConfig.cookie.secure = true;
  sessionConfig.cookie.sameSite = 'none';
}

// Initialisation de la session
app.use(session(sessionConfig));

// Middleware pour logger les sessions (à des fins de débogage)
app.use((req, res, next) => {
  console.log('=== MIDDLEWARE DE SESSION ===');
  console.log('Session ID:', req.sessionID);
  console.log('Session data:', req.session);
  console.log('Headers:', req.headers);
  console.log('Cookies:', req.cookies);
  console.log('============================');
  next();
});
app.use((req, res, next) => {
  console.log('Session middleware - Session ID:', req.sessionID);
  console.log('Session data:', req.session);
  next();
});

// Import des routes
const userRoutes = require('./routes/userRoutes');
const champsRoutes = require('./routes/champsRoutes');
const parcelleRoutes = require('./routes/parcelleRoutes');
const analyseSolRoutes = require('./routes/analyseSol_Routes');
const cultureRoutes = require('./routes/cultureRoutes');
const recommendationRoutes = require('./routes/recommendationCulture_Routes');
const campagneRoutes = require('./routes/campagneAgricole_Routes');
const capteurRoutes = require('./routes/capteurRoutes');
const authRoutes = require('./routes/authRoutes');

// Connexion à la base de données
const sequelize = require('./config/database');

// Routes API
const API_PREFIX = '/api';

// Routes d'authentification
app.use(`${API_PREFIX}/auth`, authRoutes);

// Routes protégées
app.use(`${API_PREFIX}/users`, userRoutes);
app.use(`${API_PREFIX}/champs`, champsRoutes);
app.use(`${API_PREFIX}/parcelles`, parcelleRoutes);
app.use(`${API_PREFIX}/analyses-sol`, analyseSolRoutes);
app.use(`${API_PREFIX}/cultures`, cultureRoutes);
app.use(`${API_PREFIX}/recommendations`, recommendationRoutes);
app.use(`${API_PREFIX}/campagnes`, campagneRoutes);
app.use(`${API_PREFIX}/capteurs`, capteurRoutes);

// Route de santé de l'API
app.get(`${API_PREFIX}/health`, (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Gestion des erreurs 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée',
    path: req.originalUrl
  });
});

// Gestion des erreurs globales
app.use((err, req, res, next) => {
  console.error('Erreur:', err.stack);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Erreur interne du serveur';

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

module.exports = app;
