import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/culture.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/recommendation.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/sensor.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/npk_data.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
// import 'notification_service.dart';

// PROVIDERS
final npkDataProvider = StateProvider<NPKData?>((ref) => null);
final recommendationsProvider = StateProvider<List<dynamic>>((ref) => []);

final analysisServiceProvider = Provider((ref) => AnalysisService(ref));

class AnalysisService {
  final Ref _ref;
  static const String _cacheKey = 'soil_analysis_cache';
  static const String _sensorsCacheKey = 'detected_sensors_cache';
  static const Duration _cacheDuration = Duration(hours: 1);
  Timer? _debounceTimer;
  bool _isApiCallInProgress = false;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  AnalysisService(this._ref);

  // Cache helper methods
  Future<Map<String, dynamic>?> _getCachedAnalysis(NPKData npkData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        final decoded = json.decode(cachedData) as Map<String, dynamic>;
        final timestamp = DateTime.parse(decoded['timestamp']);
        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          // Check if npk data matches
          final cachedNpkData = decoded['npkData'] as Map<String, dynamic>;
          if (_npkDataMatches(npkData, cachedNpkData)) {
            return decoded;
          }
        }
      }
    } catch (e) {
      dev.log('Error reading cache: $e');
    }
    return null;
  }

  Future<void> _setCachedAnalysis(
    NPKData npkData,
    List<dynamic> recommendations,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'npkData': {
          'ph': npkData.ph,
          'temperature': npkData.temperature,
          'humidity': npkData.humidity,
          'conductivity': npkData.conductivity,
          'nitrogen': npkData.nitrogen,
          'phosphorus': npkData.phosphorus,
          'potassium': npkData.potassium,
        },
        'recommendations': recommendations,
      };
      await prefs.setString(_cacheKey, json.encode(cacheData));
    } catch (e) {
      dev.log('Error writing cache: $e');
    }
  }

  bool _npkDataMatches(NPKData current, Map<String, dynamic> cached) {
    return current.ph == cached['ph'] &&
        current.temperature == cached['temperature'] &&
        current.humidity == cached['humidity'] &&
        current.conductivity == cached['conductivity'] &&
        current.nitrogen == cached['nitrogen'] &&
        current.phosphorus == cached['phosphorus'] &&
        current.potassium == cached['potassium'];
  }

  // Sensor caching methods
  Future<List<Sensor>?> _getCachedSensors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_sensorsCacheKey);
      if (cachedData != null) {
        final decoded = json.decode(cachedData) as Map<String, dynamic>;
        final timestamp = DateTime.parse(decoded['timestamp']);
        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          final sensorsData = decoded['sensors'] as List<dynamic>;
          return sensorsData
              .map((sensorData) => Sensor.fromJson(sensorData))
              .toList();
        }
      }
    } catch (e) {
      dev.log('Error reading sensors cache: $e');
    }
    return null;
  }

  Future<void> _setCachedSensors(List<Sensor> sensors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'sensors': sensors.map((sensor) => sensor.toJson()).toList(),
      };
      await prefs.setString(_sensorsCacheKey, json.encode(cacheData));
    } catch (e) {
      dev.log('Error writing sensors cache: $e');
    }
  }

  Future<void> fetchDataAndAnalyze({NPKData? npkData}) async {
    try {
      if (npkData == null) return;

      // IMPORTANT: Les données npkData sont maintenant finales et ne doivent plus être modifiées
      dev.log(
        'Données du capteur reçues (finales, non modifiables): ${npkData.toString()}',
      );

      // Cancel any pending debounce timer
      _debounceTimer?.cancel();

      // Set up debounced analysis
      _debounceTimer = Timer(_debounceDuration, () async {
        if (_isApiCallInProgress) {
          dev.log('API call already in progress, skipping...');
          return;
        }

        _isApiCallInProgress = true;

        try {
          dev.log('Récupération des données du sol...');

          // Utiliser les données réelles du capteur directement (maintenant finales)
          dev.log(
            'Données du capteur utilisées directement (basées sur données finales): ${npkData.toString()}',
          );

          _ref.read(npkDataProvider.notifier).state = npkData;

          // Check cache first
          final cachedAnalysis = await _getCachedAnalysis(npkData);
          if (cachedAnalysis != null) {
            dev.log('Utilisation des recommandations mises en cache');
            final cachedRecommendations =
                cachedAnalysis['recommendations'] as List<dynamic>;
            _ref.read(recommendationsProvider.notifier).state =
                cachedRecommendations;
            return;
          }

          // Envoyer les données à l'API et obtenir les recommandations
          // Les données npkData restent inchangées jusqu'à l'appel API
          await _sendNpkDataToApi(npkData);

          // Cache the successful analysis
          await _setCachedAnalysis(npkData, _ref.read(recommendationsProvider));
        } finally {
          _isApiCallInProgress = false;
        }
      });
    } catch (e, stackTrace) {
      dev.log(
        'Erreur dans fetchDataAndAnalyze: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Set empty recommendations on error
      _ref.read(recommendationsProvider.notifier).state = [];
      rethrow;
    }
  }

  Future<void> _sendNpkDataToApi(NPKData npkData) async {
    try {
      dev.log('Envoi des données NPK à l\'API...');

      final dioClient = DioClient();
      final headers = await ApiEndpoints.getAuthHeaders();
      final payload = {
        'ph': npkData.ph,
        'temperature': npkData.temperature,
        'humidity': npkData.humidity,
        'ec': npkData.conductivity,
        'n': npkData.nitrogen,
        'p': npkData.phosphorus,
        'k': npkData.potassium,
      };

      dev.log('Payload envoyé à l\'API: $payload');

      final response = await dioClient.dio.post(
        ApiEndpoints.buildUrl(ApiEndpoints.soilAnalyses),
        data: payload,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        dev.log('Réponse API reçue: $data');

        // Vérifier le status de la réponse
        final status = data['status'];
        if (status == 'success') {
          // Utiliser les données du capteur depuis la réponse API si disponibles
          final sensorData = data['data']['sensor_data'];
          if (sensorData != null) {
            final apiNpkData = NPKData(
              ph: (sensorData['ph'] as num?)?.toDouble() ?? npkData.ph,
              temperature:
                  (sensorData['temperature'] as num?)?.toDouble() ??
                  npkData.temperature,
              humidity: (sensorData['humidity'] as int?) ?? npkData.humidity,
              conductivity: (sensorData['ec'] as int?) ?? npkData.conductivity,
              nitrogen: (sensorData['n'] as int?) ?? npkData.nitrogen,
              phosphorus: (sensorData['p'] as int?) ?? npkData.phosphorus,
              potassium: (sensorData['k'] as int?) ?? npkData.potassium,
            );
            _ref.read(npkDataProvider.notifier).state = apiNpkData;
            dev.log('Données NPK mises à jour depuis l\'API: $sensorData');
          }

          // Parser les recommandations
          try {
            final dynamic recommendations =
                data['data']["crops_recommanded"] ?? [];

            // Validate recommendations data structure
            if (recommendations is List) {
              // Transform API response to match expected format
              final transformedRecommendations = recommendations.map((rec) {
                return {
                  'crop': rec['crop'],
                  'compatibilityScore':
                      rec['probability'] * 100, // Convert to percentage
                };
              }).toList();

              _ref.read(recommendationsProvider.notifier).state =
                  transformedRecommendations;
              dev.log(
                'Recommandations reçues de l\'API: ${transformedRecommendations.length} cultures.',
              );
            } else {
              dev.log(
                'Format de recommandations invalide, utilisation de la logique locale',
              );
              await _callCropRecommendationApi(null, null);
            }
          } catch (parseError) {
            dev.log('Erreur lors du parsing de la réponse API: $parseError');
            // Fallback vers la logique locale en cas d'erreur de parsing
            await _callCropRecommendationApi(null, null);
          }
        } else if (status == 'failed') {
          // Status failed - throw exception pour gérer le retour
          final errorMessage = data['message'] ?? 'Erreur API inconnue';
          dev.log('API returned failed status: $errorMessage');
          throw Exception('API_FAILED: $errorMessage');
        } else {
          dev.log('Status API non reconnu: $status');
          throw Exception('Status API non reconnu: $status');
        }
      } else {
        dev.log('Erreur HTTP: ${response.statusCode} - ${response.data}');
        throw Exception(
          'Erreur API: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      dev.log('Erreur lors de l\'appel API: $e');
      // Fallback vers la logique locale en cas d'erreur API
      await _callCropRecommendationApi(null, null);
    }
  }

  Future<void> _callCropRecommendationApi(
    NPKData? npkData,
    Sensor? sensor,
  ) async {
    // Since static data has been removed, return empty recommendations
    // All recommendations should come from the API
    _ref.read(recommendationsProvider.notifier).state = [];
    dev.log(
      'No static crop data available, recommendations must come from API.',
    );
  }

  String generateSoilDescription(NPKData npkData) {
    final List<String> descriptions = [];

    // Analyse du pH
    if (npkData.ph != null && npkData.ph! < 5.5) {
      descriptions.add(
        'Sol acide (pH ${npkData.ph!.toStringAsFixed(1)}) - nécessite chaulage pour la plupart des cultures',
      );
    } else if (npkData.ph != null && npkData.ph! >= 5.5 && npkData.ph! <= 7.5) {
      descriptions.add(
        'pH équilibré (${npkData.ph!.toStringAsFixed(1)}) - favorable à la majorité des cultures',
      );
    } else if (npkData.ph != null) {
      descriptions.add(
        'Sol alcalin (pH ${npkData.ph!.toStringAsFixed(1)}) - risque de carences en micronutriments',
      );
    }

    // Analyse de la conductivité électrique (salinité)
    if (npkData.conductivity != null && npkData.conductivity! < 500) {
      descriptions.add(
        'Non salin (EC: ${(npkData.conductivity! / 100).toStringAsFixed(1)} dS/m) - conditions optimales',
      );
    } else if (npkData.conductivity != null &&
        npkData.conductivity! >= 500 &&
        npkData.conductivity! <= 1500) {
      descriptions.add(
        'Légèrement salin (EC: ${(npkData.conductivity! / 100).toStringAsFixed(1)} dS/m) - certaines cultures sensibles peuvent être affectées',
      );
    } else if (npkData.conductivity != null &&
        npkData.conductivity! > 1500 &&
        npkData.conductivity! <= 3000) {
      descriptions.add(
        'Modérément salin (EC: ${(npkData.conductivity! / 100).toStringAsFixed(1)} dS/m) - limite certaines cultures',
      );
    } else if (npkData.conductivity != null) {
      descriptions.add(
        'Fortement salin (EC: ${(npkData.conductivity! / 100).toStringAsFixed(1)} dS/m) - nécessite cultures tolérantes au sel',
      );
    }

    // Analyse de l'humidité
    if (npkData.humidity != null && npkData.humidity! < 30) {
      descriptions.add(
        'Sol sec (${npkData.humidity!}%) - irrigation recommandée',
      );
    } else if (npkData.humidity != null &&
        npkData.humidity! >= 30 &&
        npkData.humidity! <= 70) {
      descriptions.add(
        'Humidité optimale (${npkData.humidity!}%) - bonnes conditions pour la croissance',
      );
    } else if (npkData.humidity != null) {
      descriptions.add(
        'Sol gorgé d\'eau (${npkData.humidity!}%) - risque d\'asphyxie racinaire',
      );
    }

    // Analyse de la température
    if (npkData.temperature != null && npkData.temperature! < 10) {
      descriptions.add(
        'Sol froid (${npkData.temperature!.toStringAsFixed(1)}°C) - croissance ralentie',
      );
    } else if (npkData.temperature != null &&
        npkData.temperature! >= 10 &&
        npkData.temperature! <= 25) {
      descriptions.add(
        'Température favorable (${npkData.temperature!.toStringAsFixed(1)}°C) - optimum pour la plupart des cultures',
      );
    } else if (npkData.temperature != null) {
      descriptions.add(
        'Sol chaud (${npkData.temperature!.toStringAsFixed(1)}°C) - risque de stress hydrique',
      );
    }

    // Analyse des nutriments
    final List<String> nutrientAnalysis = [];

    // Azote
    if (npkData.nitrogen != null && npkData.nitrogen! < 100) {
      nutrientAnalysis.add('azote faible');
    } else if (npkData.nitrogen != null &&
        npkData.nitrogen! >= 100 &&
        npkData.nitrogen! <= 150) {
      nutrientAnalysis.add('azote moyen');
    } else if (npkData.nitrogen != null) {
      nutrientAnalysis.add('azote élevé');
    }

    // Phosphore
    if (npkData.phosphorus != null && npkData.phosphorus! < 20) {
      nutrientAnalysis.add('phosphore faible');
    } else if (npkData.phosphorus != null &&
        npkData.phosphorus! >= 20 &&
        npkData.phosphorus! <= 40) {
      nutrientAnalysis.add('phosphore moyen');
    } else if (npkData.phosphorus != null) {
      nutrientAnalysis.add('phosphore élevé');
    }

    // Potassium
    if (npkData.potassium != null && npkData.potassium! < 100) {
      nutrientAnalysis.add('potassium faible');
    } else if (npkData.potassium != null &&
        npkData.potassium! >= 100 &&
        npkData.potassium! <= 200) {
      nutrientAnalysis.add('potassium moyen');
    } else if (npkData.potassium != null) {
      nutrientAnalysis.add('potassium élevé');
    }

    if (nutrientAnalysis.isNotEmpty) {
      descriptions.add('Nutriments: ${nutrientAnalysis.join(', ')}');
    }

    // Recommandations générales
    final List<String> recommendations = [];
    if (npkData.ph != null && npkData.ph! < 5.5) {
      recommendations.add('Ajouter de la chaux pour corriger l\'acidité');
    }
    if (npkData.nitrogen != null && npkData.nitrogen! < 100) {
      recommendations.add('Apport d\'azote recommandé');
    }
    if (npkData.phosphorus != null && npkData.phosphorus! < 20) {
      recommendations.add('Apport de phosphore nécessaire');
    }
    if (npkData.potassium != null && npkData.potassium! < 100) {
      recommendations.add('Apport de potassium conseillé');
    }
    if (npkData.humidity != null && npkData.humidity! < 30) {
      recommendations.add('Irrigation nécessaire');
    }

    // Return only the description without recommendations
    return descriptions.join('. ');
  }

  List<String> generateSoilRecommendations(NPKData npkData, String cropName) {
    // Since static crop data has been removed, return general recommendations
    final List<String> recommendations = [];

    // General recommendations based on soil parameters
    if (npkData.ph != null && npkData.ph! < 5.5) {
      recommendations.add('Ajouter de la chaux pour corriger l\'acidité');
    }
    if (npkData.nitrogen != null && npkData.nitrogen! < 100) {
      recommendations.add('Apport d\'azote recommandé');
    }
    if (npkData.phosphorus != null && npkData.phosphorus! < 20) {
      recommendations.add('Apport de phosphore nécessaire');
    }
    if (npkData.potassium != null && npkData.potassium! < 100) {
      recommendations.add('Apport de potassium conseillé');
    }
    if (npkData.humidity != null && npkData.humidity! < 30) {
      recommendations.add('Irrigation nécessaire');
    }

    return recommendations;
  }
}
