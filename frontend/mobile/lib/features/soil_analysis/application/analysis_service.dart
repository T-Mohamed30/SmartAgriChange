import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/culture.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/recommendation.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/sensor.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/soil_data.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/npk_data.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
// import 'notification_service.dart';

// PROVIDERS
final soilDataProvider = StateProvider<SoilData?>((ref) => null);
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
  Future<Map<String, dynamic>?> _getCachedAnalysis(SoilData soilData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        final decoded = json.decode(cachedData) as Map<String, dynamic>;
        final timestamp = DateTime.parse(decoded['timestamp']);
        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          // Check if soil data matches
          final cachedSoilData = decoded['soilData'] as Map<String, dynamic>;
          if (_soilDataMatches(soilData, cachedSoilData)) {
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
    SoilData soilData,
    List<dynamic> recommendations,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'soilData': {
          'ph': soilData.ph,
          'temperature': soilData.temperature,
          'humidity': soilData.humidity,
          'ec': soilData.ec,
          'nitrogen': soilData.nitrogen,
          'phosphorus': soilData.phosphorus,
          'potassium': soilData.potassium,
        },
        'recommendations': recommendations,
      };
      await prefs.setString(_cacheKey, json.encode(cacheData));
    } catch (e) {
      dev.log('Error writing cache: $e');
    }
  }

  bool _soilDataMatches(SoilData current, Map<String, dynamic> cached) {
    return current.ph == cached['ph'] &&
        current.temperature == cached['temperature'] &&
        current.humidity == cached['humidity'] &&
        current.ec == cached['ec'] &&
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

          SoilData soilData;

          // Utiliser les données réelles du capteur (maintenant finales)
          soilData = SoilData(
            ph: npkData.ph ?? 0.0,
            temperature: npkData.temperature ?? 0.0,
            humidity: (npkData.humidity ?? 0).toDouble(),
            ec: (npkData.conductivity ?? 0).toDouble(),
            nitrogen: (npkData.nitrogen ?? 0).toDouble(),
            phosphorus: (npkData.phosphorus ?? 0).toDouble(),
            potassium: (npkData.potassium ?? 0).toDouble(),
          );
          dev.log(
            'Données du capteur utilisées pour SoilData (basées sur données finales): ${npkData.toString()}',
          );

          _ref.read(soilDataProvider.notifier).state = soilData;

          // Check cache first
          final cachedAnalysis = await _getCachedAnalysis(soilData);
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
          await _sendSoilDataToApi(soilData, npkData);

          // Cache the successful analysis
          await _setCachedAnalysis(
            soilData,
            _ref.read(recommendationsProvider),
          );
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

  Future<void> _sendSoilDataToApi(SoilData soilData, NPKData? npkData) async {
    try {
      dev.log('Envoi des données du sol à l\'API...');

      final dioClient = DioClient();
      final headers = await ApiEndpoints.getAuthHeaders();
      final payload = {
        'ph': soilData.ph,
        'temperature': soilData.temperature,
        'humidity': soilData.humidity,
        'ec': soilData.ec,
        'n': soilData.nitrogen,
        'p': soilData.phosphorus,
        'k': soilData.potassium,
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
          // Utiliser les données du capteur depuis la réponse API
          final sensorData = data['data']['sensor_data'];
          if (sensorData != null) {
            final apiSoilData = SoilData(
              ph: (sensorData['ph'] as num?)?.toDouble() ?? soilData.ph,
              temperature:
                  (sensorData['temperature'] as num?)?.toDouble() ??
                  soilData.temperature,
              humidity:
                  (sensorData['humidity'] as num?)?.toDouble() ??
                  soilData.humidity,
              ec: (sensorData['ec'] as num?)?.toDouble() ?? soilData.ec,
              nitrogen:
                  (sensorData['n'] as num?)?.toDouble() ?? soilData.nitrogen,
              phosphorus:
                  (sensorData['p'] as num?)?.toDouble() ?? soilData.phosphorus,
              potassium:
                  (sensorData['k'] as num?)?.toDouble() ?? soilData.potassium,
            );
            _ref.read(soilDataProvider.notifier).state = apiSoilData;
            dev.log(
              'Données du capteur mises à jour depuis l\'API: $sensorData',
            );
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
              await _callCropRecommendationApi(soilData, null);
            }
          } catch (parseError) {
            dev.log('Erreur lors du parsing de la réponse API: $parseError');
            // Fallback vers la logique locale en cas d'erreur de parsing
            await _callCropRecommendationApi(soilData, null);
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
      await _callCropRecommendationApi(soilData, null);
    }
  }

  Future<void> _callCropRecommendationApi(
    SoilData soilData,
    Sensor? sensor,
  ) async {
    // Since static data has been removed, return empty recommendations
    // All recommendations should come from the API
    _ref.read(recommendationsProvider.notifier).state = [];
    dev.log(
      'No static crop data available, recommendations must come from API.',
    );
  }

  String generateSoilDescription(SoilData soilData) {
    final List<String> descriptions = [];

    // Analyse du pH
    if (soilData.ph < 5.5) {
      descriptions.add(
        'Sol acide (pH ${soilData.ph.toStringAsFixed(1)}) - nécessite chaulage pour la plupart des cultures',
      );
    } else if (soilData.ph >= 5.5 && soilData.ph <= 7.5) {
      descriptions.add(
        'pH équilibré (${soilData.ph.toStringAsFixed(1)}) - favorable à la majorité des cultures',
      );
    } else {
      descriptions.add(
        'Sol alcalin (pH ${soilData.ph.toStringAsFixed(1)}) - risque de carences en micronutriments',
      );
    }

    // Analyse de la conductivité électrique (salinité)
    if (soilData.ec < 0.5) {
      descriptions.add(
        'Non salin (EC: ${soilData.ec.toStringAsFixed(1)} dS/m) - conditions optimales',
      );
    } else if (soilData.ec >= 0.5 && soilData.ec <= 1.5) {
      descriptions.add(
        'Légèrement salin (EC: ${soilData.ec.toStringAsFixed(1)} dS/m) - certaines cultures sensibles peuvent être affectées',
      );
    } else if (soilData.ec > 1.5 && soilData.ec <= 3.0) {
      descriptions.add(
        'Modérément salin (EC: ${soilData.ec.toStringAsFixed(1)} dS/m) - limite certaines cultures',
      );
    } else {
      descriptions.add(
        'Fortement salin (EC: ${soilData.ec.toStringAsFixed(1)} dS/m) - nécessite cultures tolérantes au sel',
      );
    }

    // Analyse de l'humidité
    if (soilData.humidity < 30) {
      descriptions.add(
        'Sol sec (${soilData.humidity.toStringAsFixed(1)}%) - irrigation recommandée',
      );
    } else if (soilData.humidity >= 30 && soilData.humidity <= 70) {
      descriptions.add(
        'Humidité optimale (${soilData.humidity.toStringAsFixed(1)}%) - bonnes conditions pour la croissance',
      );
    } else {
      descriptions.add(
        'Sol gorgé d\'eau (${soilData.humidity.toStringAsFixed(1)}%) - risque d\'asphyxie racinaire',
      );
    }

    // Analyse de la température
    if (soilData.temperature < 10) {
      descriptions.add(
        'Sol froid (${soilData.temperature.toStringAsFixed(1)}°C) - croissance ralentie',
      );
    } else if (soilData.temperature >= 10 && soilData.temperature <= 25) {
      descriptions.add(
        'Température favorable (${soilData.temperature.toStringAsFixed(1)}°C) - optimum pour la plupart des cultures',
      );
    } else {
      descriptions.add(
        'Sol chaud (${soilData.temperature.toStringAsFixed(1)}°C) - risque de stress hydrique',
      );
    }

    // Analyse des nutriments
    final List<String> nutrientAnalysis = [];

    // Azote
    if (soilData.nitrogen < 100) {
      nutrientAnalysis.add('azote faible');
    } else if (soilData.nitrogen >= 100 && soilData.nitrogen <= 150) {
      nutrientAnalysis.add('azote moyen');
    } else {
      nutrientAnalysis.add('azote élevé');
    }

    // Phosphore
    if (soilData.phosphorus < 20) {
      nutrientAnalysis.add('phosphore faible');
    } else if (soilData.phosphorus >= 20 && soilData.phosphorus <= 40) {
      nutrientAnalysis.add('phosphore moyen');
    } else {
      nutrientAnalysis.add('phosphore élevé');
    }

    // Potassium
    if (soilData.potassium < 100) {
      nutrientAnalysis.add('potassium faible');
    } else if (soilData.potassium >= 100 && soilData.potassium <= 200) {
      nutrientAnalysis.add('potassium moyen');
    } else {
      nutrientAnalysis.add('potassium élevé');
    }

    if (nutrientAnalysis.isNotEmpty) {
      descriptions.add('Nutriments: ${nutrientAnalysis.join(', ')}');
    }

    // Recommandations générales
    final List<String> recommendations = [];
    if (soilData.ph < 5.5) {
      recommendations.add('Ajouter de la chaux pour corriger l\'acidité');
    }
    if (soilData.nitrogen < 100) {
      recommendations.add('Apport d\'azote recommandé');
    }
    if (soilData.phosphorus < 20) {
      recommendations.add('Apport de phosphore nécessaire');
    }
    if (soilData.potassium < 100) {
      recommendations.add('Apport de potassium conseillé');
    }
    if (soilData.humidity < 30) {
      recommendations.add('Irrigation nécessaire');
    }

    // Return only the description without recommendations
    return descriptions.join('. ');
  }

  List<String> generateSoilRecommendations(SoilData soilData, String cropName) {
    // Since static crop data has been removed, return general recommendations
    final List<String> recommendations = [];

    // General recommendations based on soil parameters
    if (soilData.ph < 5.5) {
      recommendations.add('Ajouter de la chaux pour corriger l\'acidité');
    }
    if (soilData.nitrogen < 100) {
      recommendations.add('Apport d\'azote recommandé');
    }
    if (soilData.phosphorus < 20) {
      recommendations.add('Apport de phosphore nécessaire');
    }
    if (soilData.potassium < 100) {
      recommendations.add('Apport de potassium conseillé');
    }
    if (soilData.humidity < 30) {
      recommendations.add('Irrigation nécessaire');
    }

    return recommendations;
  }
}
