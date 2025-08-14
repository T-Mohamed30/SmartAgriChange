import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../user_dashboard/domain/entities/analysis_simple.dart';
import '../../../user_dashboard/domain/entities/weather_simple.dart';

// Provider pour les analyses récentes
final recentAnalysesProvider = FutureProvider<List<Analysis>>((ref) async {
  // Simulation d'appel API
  await Future.delayed(const Duration(seconds: 1));
  
  return [
    Analysis(
      id: '1',
      name: 'Champs A',
      location: 'Nord/Ouaga',
      type: 'soil',
      status: AnalysisStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      parcelle: 'parcelle 1',
    ),
    Analysis(
      id: '2',
      name: 'Champs A',
      location: 'Nord/Ouaga',
      type: 'plant',
      status: AnalysisStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      parcelle: 'parcelle 2',
    ),
    Analysis(
      id: '3',
      name: 'Champs B',
      location: 'Sud/Bobo',
      type: 'soil',
      status: AnalysisStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Analysis(
      id: '4',
      name: 'Champs B',
      location: 'Sud/Bobo',
      type: 'plant',
      status: AnalysisStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
});

// Provider pour la météo
final weatherProvider = FutureProvider<Weather>((ref) async {
  // Simulation d'appel API météo
  await Future.delayed(const Duration(milliseconds: 500));
  
  return Weather(
    temperature: 22.0,
    condition: 'sunny',
    description: 'Ensoleillé',
    icon: 'assets/icons/temps_1.png',
    lastUpdated: DateTime.now(),
  );
});

// Provider pour les statistiques
final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  
  return {
    'capteurs': 12,
    'champs': 5,
    'alertes': 2,
  };
});

// Provider pour actualiser les données
final refreshTriggerProvider = StateProvider<int>((ref) => 0);

// Provider combiné qui se actualise quand refreshTrigger change
final dashboardDataProvider = FutureProvider<bool>((ref) async {
  // Écoute le trigger de rafraîchissement
  ref.watch(refreshTriggerProvider);
  
  // Invalide tous les autres providers pour les forcer à se recharger
  ref.invalidate(recentAnalysesProvider);
  ref.invalidate(weatherProvider);
  ref.invalidate(dashboardStatsProvider);
  
  return true;
}); 