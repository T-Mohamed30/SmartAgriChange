const app = require('./app');

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Serveur SmartAgriChange démarré sur le port ${PORT}`);
  console.log(`📱 API disponible sur http://localhost:${PORT}/api`);
  console.log(`📚 Documentation API: http://localhost:${PORT}/api-docs`);
});
