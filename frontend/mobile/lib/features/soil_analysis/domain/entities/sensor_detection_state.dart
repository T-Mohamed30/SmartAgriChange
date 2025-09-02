
enum SensorDetectionState {
  idle,       // État initial, prêt à démarrer la détection
  searching,  // Recherche de capteurs en cours
  found,      // Capteurs trouvés
  notFound,   // Aucun capteur trouvé
  error,      // Erreur lors de la détection
}
