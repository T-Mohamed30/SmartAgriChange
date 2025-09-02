import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/data/datasources/mock_culture_datasource.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/culture.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/recommendation.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/sensor.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/sensor_detection_state.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/soil_data.dart';

// PROVIDERS
// 1. Fournisseur pour l'état de la détection (UI State)
final detectionStateProvider = StateProvider<SensorDetectionState>((ref) => SensorDetectionState.idle);

// 2. Fournisseur pour la liste des capteurs détectés
final detectedSensorsProvider = StateProvider<List<Sensor>>((ref) => []);

// 3. Fournisseur pour le capteur sélectionné
final selectedSensorProvider = StateProvider<Sensor?>((ref) => null);

// 4. Fournisseur pour les données du sol (après analyse du capteur)
final soilDataProvider = StateProvider<SoilData?>((ref) => null);

// 5. Fournisseur pour les recommandations générées
final recommendationsProvider = StateProvider<List<Recommendation>>((ref) => []);

// 6. Service d'analyse (contiendra la logique métier)
final analysisServiceProvider = Provider((ref) => AnalysisService(ref));

// ANALYSIS SERVICE
class AnalysisService {
  final Ref _ref;
  AnalysisService(this._ref);

  // Simule la détection de capteurs
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

  // Simule la récupération des données du capteur et lance l'analyse
  Future<void> fetchDataAndAnalyze() async {
    dev.log('Récupération des données du sol...');
    await Future.delayed(const Duration(seconds: 2));

    // Simuler des données de sol
    final soilData = SoilData(
      ph: 6.5 + Random().nextDouble() * 0.5,
      temperature: 22 + Random().nextDouble() * 5,
      humidity: 70 + Random().nextDouble() * 10,
      ec: 1.5 + Random().nextDouble() * 0.5,
      nitrogen: 130 + Random().nextDouble() * 20,
      phosphorus: 90 + Random().nextDouble() * 20,
      potassium: 160 + Random().nextDouble() * 20,
    );
    _ref.read(soilDataProvider.notifier).state = soilData;
    dev.log('Données du sol reçues: $soilData');

    // Lancer le moteur d'analyse
    _runAnalysisEngine(soilData);
  }

  // Le moteur d'analyse principal
  void _runAnalysisEngine(SoilData soilData) {
    final cultures = MockCultureDataSource.cultures;
    final List<Recommendation> recommendations = [];

    for (var culture in cultures) {
      double score = 0;
      List<String> actions = [];

      // Comparaison pour chaque paramètre
      if (soilData.ph >= culture.minPh && soilData.ph <= culture.maxPh) {
        score++;
      } else {
        actions.add('Ajuster le pH (actuel: ${soilData.ph.toStringAsFixed(1)}, idéal: ${culture.minPh}-${culture.maxPh})');
      }

      if (soilData.temperature >= culture.minTemp && soilData.temperature <= culture.maxTemp) {
        score++;
      } else {
        actions.add('Contrôler la température du sol.');
      }

      if (soilData.humidity >= culture.minHumidity && soilData.humidity <= culture.maxHumidity) {
        score++;
      } else {
        actions.add('Ajuster l\'irrigation pour l\'humidité.');
      }

      if (soilData.nitrogen >= culture.minNitrogen && soilData.nitrogen <= culture.maxNitrogen) {
        score++;
      } else {
        actions.add('Corriger l\'apport en azote.');
      }

      if (soilData.phosphorus >= culture.minPhosphorus && soilData.phosphorus <= culture.maxPhosphorus) {
        score++;
      } else {
        actions.add('Corriger l\'apport en phosphore.');
      }

      if (soilData.potassium >= culture.minPotassium && soilData.potassium <= culture.maxPotassium) {
        score++;
      } else {
        actions.add('Corriger l\'apport en potassium.');
      }

      final compatibility = (score / 6) * 100;

      if (compatibility > 50) { // Seuil pour recommander
        recommendations.add(Recommendation(
          culture: culture,
          compatibilityScore: compatibility,
          explanation: 'Cette culture est ${compatibility.toStringAsFixed(0)}% compatible avec votre sol.',
          correctiveActions: actions,
        ));
      }
    }

    // Trier par score de compatibilité
    recommendations.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));

    _ref.read(recommendationsProvider.notifier).state = recommendations;
    dev.log('Analyse terminée. ${recommendations.length} recommandations générées.');
  }
}
