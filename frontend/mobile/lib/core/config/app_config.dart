import 'package:flutter/foundation.dart';

class AppConfig {
  // Configuration de l'API
  static const String _defaultApiUrl = 'https://smartagrichangeapi.kgslab.com/api';
  static const String _defaultWebSocketUrl = 'ws://localhost:3000';
  
  // Récupérer l'URL de l'API en fonction de la plateforme
  static String get apiUrl {
    if (kIsWeb) {
      // Pour le web, utiliser l'URL relative
      return '/api';
    } else {
      // Pour mobile, utiliser l'URL définie dans les variables d'environnement ou la valeur par défaut
      return const String.fromEnvironment('API_URL', defaultValue: _defaultApiUrl);
    }
  }
  
  // Récupérer l'URL des WebSockets
  static String get webSocketUrl {
    if (kIsWeb) {
      // Pour le web, utiliser l'URL relative avec le bon protocole
      final isHttps = Uri.base.scheme == 'https';
      return '${isHttps ? 'wss' : 'ws'}://${Uri.base.host}${Uri.base.hasPort ? ':${Uri.base.port}' : ''}/ws';
    } else {
      // Pour mobile, utiliser l'URL définie dans les variables d'environnement ou la valeur par défaut
      return const String.fromEnvironment('WS_URL', defaultValue: _defaultWebSocketUrl);
    }
  }
  
  // Configuration du débogage
  static const bool enableDebugLogs = kDebugMode;
  
  // Configuration des fonctionnalités
  static const bool enableAnalytics = !kDebugMode;
  static const bool enableCrashlytics = !kDebugMode;
  
  // Configuration du thème
  static const String fontFamily = 'Roboto';
  
  // Configuration des timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  // Configuration du cache
  static const Duration cacheDuration = Duration(hours: 1);
  static const int maxCacheSize = 100; // Nombre maximum d'éléments en cache
  
  // Configuration des essais de reconnexion
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Configuration des mises à jour automatiques
  static const Duration checkForUpdatesInterval = Duration(hours: 12);
  
  // Configuration des logs
  static const bool logNetworkRequests = kDebugMode;
  static const bool logDatabaseOperations = kDebugMode;
  static const bool logAnalyticsEvents = kDebugMode;
  
  // Configuration du mode hors ligne
  static const bool enableOfflineMode = true;
  static const Duration syncInterval = Duration(minutes: 15);
  
  // Configuration des notifications
  static const bool enablePushNotifications = true;
  static const Duration notificationPollingInterval = Duration(minutes: 5);
  
  // Configuration de la sécurité
  static const bool enableCertificatePinning = !kDebugMode;
  static const bool enableBiometricAuth = true;
  
  // Configuration du mode démo
  static const bool isDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);
  
  // Configuration du mode test
  static const bool isTestMode = bool.fromEnvironment('TEST_MODE', defaultValue: false);
}
