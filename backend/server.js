const app = require('./app');
const http = require('http');

// Configuration du port et de l'hôte
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// Création du serveur HTTP
const server = http.createServer(app);

// Gestion des erreurs non capturées
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  // Ne pas arrêter le processus en développement
  if (process.env.NODE_ENV === 'production') {
    process.exit(1);
  }
});

// Gestion des rejets de promesse non gérés
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Démarrer le serveur
server.listen(PORT, HOST, () => {
  console.log(`\n=== Serveur démarré ===`);
  console.log(`Environnement: ${process.env.NODE_ENV || 'development'}`);
  console.log(`URL: http://${HOST === '0.0.0.0' ? 'localhost' : HOST}:${PORT}`);
  console.log(`Heure: ${new Date().toISOString()}\n`);
});

// Gestion des arrêts propres
process.on('SIGTERM', () => {
  console.log('\nArrêt gracieux du serveur...');
  server.close(() => {
    console.log('Serveur arrêté.');
    process.exit(0);
  });
});

// Gestion des erreurs du serveur
server.on('error', (error) => {
  if (error.syscall !== 'listen') {
    throw error;
  }

  const bind = typeof PORT === 'string' ? 'Pipe ' + PORT : 'Port ' + PORT;

  // Gestion des erreurs spécifiques
  switch (error.code) {
    case 'EACCES':
      console.error(bind + ' nécessite des privilèges élevés');
      process.exit(1);
      break;
    case 'EADDRINUSE':
      console.error(bind + ' est déjà utilisé');
      process.exit(1);
      break;
    default:
      throw error;
  }
});
