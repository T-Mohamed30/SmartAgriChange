import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/culture.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/recommendation.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/sensor.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/sensor_detection_state.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/soil_data.dart';
import 'package:dio/dio.dart';

// PROVIDERS
final detectionStateProvider = StateProvider<SensorDetectionState>((ref) => SensorDetectionState.idle);
final detectedSensorsProvider = StateProvider<List<Sensor>>((ref) => []);
final selectedSensorProvider = StateProvider<Sensor?>((ref) => null);
final soilDataProvider = StateProvider<SoilData?>((ref) => null);
final recommendationsProvider = StateProvider<List<Recommendation>>((ref) => []);

final analysisServiceProvider = Provider((ref) => AnalysisService(ref));

class AnalysisService {
  final Ref _ref;
  AnalysisService(this._ref);

  Future<void> startSensorDetection() async {
    _ref.read(detectionStateProvider.notifier).state = SensorDetectionState.searching;
    dev.log('Recherche de capteurs en cours...');
    await Future.delayed(const Duration(seconds: 2));

    final mockSensors = List.generate(3, (i) => Sensor(
      id: 'sensor_$i',
      name: 'Capteur Agri-0${i + 1}',
      status: SensorStatus.online,
      batteryLevel: 90 - i * 10,
    ));

    _ref.read(detectedSensorsProvider.notifier).state = mockSensors;
    _ref.read(detectionStateProvider.notifier).state = mockSensors.isNotEmpty
        ? SensorDetectionState.found
        : SensorDetectionState.notFound;
    dev.log('Détection terminée. ${mockSensors.length} capteurs trouvés.');
  }

  void selectSensor(Sensor sensor) {
    _ref.read(selectedSensorProvider.notifier).state = sensor;
    dev.log('Capteur sélectionné: ${sensor.name}');
  }

  Future<void> fetchDataAndAnalyze() async {
    dev.log('Récupération des données du sol...');
    await Future.delayed(const Duration(seconds: 2));

    // Simuler des données aléatoires pour p, k, humidité, température, azote, ec, ph
    final double p = 10 + Random().nextDouble() * 20;
    final double k = 20 + Random().nextDouble() * 40;
    final double humidity = 40 + Random().nextDouble() * 30;
    final double temperature = 15 + Random().nextDouble() * 15;
    final double nitrogen = 130 + Random().nextDouble() * 20;
    final double ec = 1.5 + Random().nextDouble() * 0.5;
    final double ph = 6.5 + Random().nextDouble() * 0.5;

    final soilData = SoilData(
      ph: ph,
      temperature: temperature,
      humidity: humidity,
      ec: ec,
      nitrogen: nitrogen,
      phosphorus: p,
      potassium: k,
    );
    _ref.read(soilDataProvider.notifier).state = soilData;
    dev.log('Données du sol simulées: p=$p, k=$k, humidité=$humidity, température=$temperature, azote=$nitrogen, ec=$ec, ph=$ph');

    // Appeler l'API IA pour obtenir les recommandations
    await _callCropRecommendationApi(p, k, humidity, temperature);
  }

  Future<void> _callCropRecommendationApi(double p, double k, double humidity, double temperature) async {
    // Essayer d'abord avec Dio configuré pour éviter les problèmes CORS
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Désactiver les vérifications CORS pour cette requête
        extra: {'withCredentials': false},
      ),
    );

    try {
      final response = await dio.post(
        '/api/v1/predict/probabilities',
        data: {
          'p': p,
          'k': k,
          'humidity': humidity,
          'temperature': temperature,
          'top_n': 5,
        },
        options: Options(
          // Forcer le bypass des vérifications CORS
          extra: {'withCredentials': false},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> probs = response.data['probabilities'] ?? [];
        final List<Recommendation> recommendations = probs.map((item) {
          // Map English crop names to French names
          final Map<String, String> cropNameMap = {
            'rice': 'Riz',
            'maize': 'Maïs',
            'chickpea': 'Pois chiche',
            'kidneybeans': 'Haricot rouge',
            'pigeonpeas': 'Pois cajan',
            'mothbeans': 'Haricot papillon',
            'mungbean': 'Haricot mungo',
            'blackgram': 'Haricot noir',
            'lentil': 'Lentille',
            'pomegranate': 'Grenade',
            'banana': 'Banane',
            'mango': 'Mangue',
            'grapes': 'Raisin',
            'watermelon': 'Pastèque',
            'muskmelon': 'Melon',
            'apple': 'Pomme',
            'orange': 'Orange',
            'papaya': 'Papaye',
            'coconut': 'Noix de coco',
            'cotton': 'Coton',
            'jute': 'Jute',
            'coffee': 'Café',
          };

          final String cropEnglish = item['crop'] ?? 'Inconnu';
          final String cropFrench = cropNameMap[cropEnglish.toLowerCase()] ?? cropEnglish;

          return Recommendation(
            culture: Culture(
              name: cropFrench,
              minPh: 0,
              maxPh: 14,
              minTemp: 0,
              maxTemp: 50,
              minHumidity: 0,
              maxHumidity: 100,
              minNitrogen: 0,
              maxNitrogen: 200,
              minPhosphorus: 0,
              maxPhosphorus: 200,
              minPotassium: 0,
              maxPotassium: 200,
              description: 'Culture recommandée par IA',
              rendement: 'Variable',
            ),
            compatibilityScore: (item['probability'] ?? 0) * 100,
            explanation: 'Probabilité: ${(item['probability'] ?? 0) * 100}%',
            correctiveActions: [],
          );
        }).toList();

        _ref.read(recommendationsProvider.notifier).state = recommendations;
        dev.log('Recommandations IA reçues: ${recommendations.length} cultures.');
      } else {
        dev.log('Erreur API IA: statut ${response.statusCode}');
      }
    } catch (e) {
      dev.log('Erreur lors de l\'appel API IA: $e');
    }
  }
}
