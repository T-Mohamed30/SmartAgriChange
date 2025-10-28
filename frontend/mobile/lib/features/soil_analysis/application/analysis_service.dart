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

// Crop conditions data
class CropConditions {
  final String nRange;
  final String pRange;
  final String kRange;
  final String tempRange;
  final String humRange;
  final String phRange;
  const CropConditions({
    required this.nRange,
    required this.pRange,
    required this.kRange,
    required this.tempRange,
    required this.humRange,
    required this.phRange,
  });
}

const _defaultConditions = CropConditions(
  nRange: '—',
  pRange: '—',
  kRange: '—',
  tempRange: '—',
  humRange: '—',
  phRange: '—',
);

final Map<String, CropConditions> _conditionsByCrop = {
  'riz': const CropConditions(
    nRange: '60 - 99',
    pRange: '30 - 64',
    kRange: '30 - 50',
    tempRange: '20.04 - 26.98',
    humRange: '80.12 - 84.97',
    phRange: '5.01 - 7.91',
  ),
  'maïs': const CropConditions(
    nRange: '60 - 120',
    pRange: '35 - 60',
    kRange: '15 - 28',
    tempRange: '18.04 - 26.55',
    humRange: '54.43 - 75.82',
    phRange: '5.50 - 7.00',
  ),
  'pois chiche': const CropConditions(
    nRange: '0 - 20',
    pRange: '50 - 78',
    kRange: '15 - 27',
    tempRange: '18.82 - 26.70',
    humRange: '16.35 - 21.90',
    phRange: '7.33 - 7.90',
  ),
  'haricot': const CropConditions(
    nRange: '20 - 40',
    pRange: '60 - 79',
    kRange: '15 - 28',
    tempRange: '20.00 - 27.24',
    humRange: '79.54 - 94.94',
    phRange: '5.75 - 7.94',
  ),
  'pois d\'angole': const CropConditions(
    nRange: '20 - 40',
    pRange: '60 - 80',
    kRange: '15 - 28',
    tempRange: '17.91 - 27.74',
    humRange: '48.42 - 58.75',
    phRange: '5.48 - 7.90',
  ),
  'haricot de tignous': const CropConditions(
    nRange: '20 - 40',
    pRange: '40 - 58',
    kRange: '5 - 15',
    tempRange: '27.02 - 35.85',
    humRange: '30.07 - 35.84',
    phRange: '5.75 - 7.99',
  ),
  'haricot mungo': const CropConditions(
    nRange: '20 - 40',
    pRange: '5 - 20',
    kRange: '5 - 18',
    tempRange: '28.01 - 40.09',
    humRange: '80.08 - 84.99',
    phRange: '5.12 - 7.05',
  ),
  'haricot urd': const CropConditions(
    nRange: '30 - 50',
    pRange: '5 - 20',
    kRange: '5 - 18',
    tempRange: '28.01 - 40.09',
    humRange: '75.04 - 84.98',
    phRange: '5.23 - 7.37',
  ),
  'lentille': const CropConditions(
    nRange: '0 - 20',
    pRange: '60 - 79',
    kRange: '15 - 30',
    tempRange: '17.51 - 22.84',
    humRange: '60.14 - 65.80',
    phRange: '5.40 - 6.95',
  ),
  'grenade': const CropConditions(
    nRange: '0 - 20',
    pRange: '5 - 20',
    kRange: '10 - 20',
    tempRange: '18.03 - 22.81',
    humRange: '89.98 - 94.99',
    phRange: '5.56 - 6.59',
  ),
  'banane': const CropConditions(
    nRange: '80 - 120',
    pRange: '100 - 120',
    kRange: '45 - 55',
    tempRange: '26.54 - 37.81',
    humRange: '80.11 - 84.96',
    phRange: '5.40 - 6.95',
  ),
  'mangue': const CropConditions(
    nRange: '20 - 40',
    pRange: '20 - 39',
    kRange: '20 - 30',
    tempRange: '27.80 - 40.00',
    humRange: '50.11 - 54.80',
    phRange: '5.00 - 6.00',
  ),
  'raisin': const CropConditions(
    nRange: '10 - 20',
    pRange: '10 - 20',
    kRange: '15 - 28',
    tempRange: '20.00 - 40.07',
    humRange: '79.90 - 84.98',
    phRange: '6.30 - 7.01',
  ),
  'pastèque': const CropConditions(
    nRange: '100 - 120',
    pRange: '15 - 30',
    kRange: '50 - 59',
    tempRange: '25.01 - 40.97',
    humRange: '80.20 - 84.80',
    phRange: '6.00 - 7.00',
  ),
  'cantaloup': const CropConditions(
    nRange: '100 - 120',
    pRange: '15 - 30',
    kRange: '50 - 59',
    tempRange: '20.02 - 40.98',
    humRange: '90.00 - 94.99',
    phRange: '6.00 - 7.00',
  ),
  'pomme': const CropConditions(
    nRange: '0 - 20',
    pRange: '120 - 145',
    kRange: '190 - 205',
    tempRange: '20.84 - 22.80',
    humRange: '90.00 - 94.95',
    phRange: '5.71 - 6.00',
  ),
  'orange': const CropConditions(
    nRange: '10 - 20',
    pRange: '10 - 15',
    kRange: '10 - 18',
    tempRange: '15.11 - 16.96',
    humRange: '90.01 - 94.99',
    phRange: '6.01 - 7.00',
  ),
  'papaye': const CropConditions(
    nRange: '40 - 60',
    pRange: '40 - 60',
    kRange: '40 - 50',
    tempRange: '20.04 - 40.08',
    humRange: '90.00 - 94.99',
    phRange: '6.00 - 7.00',
  ),
  'noix de coco': const CropConditions(
    nRange: '20 - 35',
    pRange: '5 - 10',
    kRange: '30 - 35',
    tempRange: '27.51 - 28.56',
    humRange: '90.01 - 94.99',
    phRange: '5.00 - 5.50',
  ),
  'coton': const CropConditions(
    nRange: '80 - 120',
    pRange: '50 - 79',
    kRange: '70 - 90',
    tempRange: '23.41 - 35.84',
    humRange: '75.04 - 84.99',
    phRange: '6.50 - 7.99',
  ),
  'jute': const CropConditions(
    nRange: '60 - 100',
    pRange: '40 - 60',
    kRange: '40 - 59',
    tempRange: '24.01 - 35.53',
    humRange: '78.02 - 84.98',
    phRange: '6.40 - 7.99',
  ),
  'café': const CropConditions(
    nRange: '80 - 120',
    pRange: '15 - 35',
    kRange: '15 - 30',
    tempRange: '22.01 - 27.56',
    humRange: '50.50 - 70.83',
    phRange: '6.60 - 7.35',
  ),
};

// PROVIDERS
final detectionStateProvider = StateProvider<SensorDetectionState>(
  (ref) => SensorDetectionState.idle,
);
final detectedSensorsProvider = StateProvider<List<Sensor>>((ref) => []);
final selectedSensorProvider = StateProvider<Sensor?>((ref) => null);
final soilDataProvider = StateProvider<SoilData?>((ref) => null);
final recommendationsProvider = StateProvider<List<Recommendation>>(
  (ref) => [],
);

final analysisServiceProvider = Provider((ref) => AnalysisService(ref));

class AnalysisService {
  final Ref _ref;
  AnalysisService(this._ref);

  Future<void> startSensorDetection() async {
    _ref.read(detectionStateProvider.notifier).state =
        SensorDetectionState.searching;
    dev.log('Recherche de capteurs en cours...');
    await Future.delayed(const Duration(seconds: 2));

    final mockSensors = List.generate(
      3,
      (i) => Sensor(
        id: 'sensor_$i',
        name: 'Capteur Agri-0${i + 1}',
        status: SensorStatus.online,
        batteryLevel: 90 - i * 10,
      ),
    );

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
    dev.log(
      'Données du sol simulées: p=$p, k=$k, humidité=$humidity, température=$temperature, azote=$nitrogen, ec=$ec, ph=$ph',
    );

    // Appeler l'API IA pour obtenir les recommandations
    await _callCropRecommendationApi(p, k, humidity, temperature);
  }

  Future<void> _callCropRecommendationApi(
    double p,
    double k,
    double humidity,
    double temperature,
  ) async {
    // Essayer d'abord avec Dio configuré pour éviter les problèmes CORS
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://https://smartagrichangeapi.kgslab.com/api',
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
          final String cropFrench =
              cropNameMap[cropEnglish.toLowerCase()] ?? cropEnglish;

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
        dev.log(
          'Recommandations IA reçues: ${recommendations.length} cultures.',
        );
      } else {
        dev.log('Erreur API IA: statut ${response.statusCode}');
      }
    } catch (e) {
      dev.log('Erreur lors de l\'appel API IA: $e');
    }
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
    final List<String> recommendations = [];
    final cropConditions = _conditionsByCrop[cropName.toLowerCase()];

    if (cropConditions != null) {
      // Parse ranges and generate recommendations based on crop conditions
      final nRange = cropConditions.nRange.split(' - ');
      final pRange = cropConditions.pRange.split(' - ');
      final kRange = cropConditions.kRange.split(' - ');
      final tempRange = cropConditions.tempRange.split(' - ');
      final humRange = cropConditions.humRange.split(' - ');
      final phRange = cropConditions.phRange.split(' - ');

      // Nitrogen
      if (nRange.length == 2) {
        final minN = double.tryParse(nRange[0]) ?? 0;
        final maxN = double.tryParse(nRange[1]) ?? 200;
        if (soilData.nitrogen < minN) {
          recommendations.add(
            'Augmenter l\'apport en azote (minimum $minN mg/kg)',
          );
        } else if (soilData.nitrogen > maxN) {
          recommendations.add(
            'Réduire l\'apport en azote (maximum $maxN mg/kg)',
          );
        }
      }

      // Phosphorus
      if (pRange.length == 2) {
        final minP = double.tryParse(pRange[0]) ?? 0;
        final maxP = double.tryParse(pRange[1]) ?? 200;
        if (soilData.phosphorus < minP) {
          recommendations.add(
            'Augmenter l\'apport en phosphore (minimum $minP mg/kg)',
          );
        } else if (soilData.phosphorus > maxP) {
          recommendations.add(
            'Réduire l\'apport en phosphore (maximum $maxP mg/kg)',
          );
        }
      }

      // Potassium
      if (kRange.length == 2) {
        final minK = double.tryParse(kRange[0]) ?? 0;
        final maxK = double.tryParse(kRange[1]) ?? 200;
        if (soilData.potassium < minK) {
          recommendations.add(
            'Augmenter l\'apport en potassium (minimum $minK mg/kg)',
          );
        } else if (soilData.potassium > maxK) {
          recommendations.add(
            'Réduire l\'apport en potassium (maximum $maxK mg/kg)',
          );
        }
      }

      // Temperature
      if (tempRange.length == 2) {
        final minTemp = double.tryParse(tempRange[0]) ?? 0;
        final maxTemp = double.tryParse(tempRange[1]) ?? 50;
        if (soilData.temperature < minTemp) {
          recommendations.add(
            'Augmenter la température du sol (minimum $minTemp°C)',
          );
        } else if (soilData.temperature > maxTemp) {
          recommendations.add(
            'Réduire la température du sol (maximum $maxTemp°C)',
          );
        }
      }

      // Humidity
      if (humRange.length == 2) {
        final minHum = double.tryParse(humRange[0]) ?? 0;
        final maxHum = double.tryParse(humRange[1]) ?? 100;
        if (soilData.humidity < minHum) {
          recommendations.add(
            'Augmenter l\'humidité du sol (minimum $minHum%)',
          );
        } else if (soilData.humidity > maxHum) {
          recommendations.add('Réduire l\'humidité du sol (maximum $maxHum%)');
        }
      }

      // pH
      if (phRange.length == 2) {
        final minPh = double.tryParse(phRange[0]) ?? 0;
        final maxPh = double.tryParse(phRange[1]) ?? 14;
        if (soilData.ph < minPh) {
          recommendations.add('Augmenter le pH du sol (minimum $minPh)');
        } else if (soilData.ph > maxPh) {
          recommendations.add('Réduire le pH du sol (maximum $maxPh)');
        }
      }
    }

    return recommendations;
  }
}
