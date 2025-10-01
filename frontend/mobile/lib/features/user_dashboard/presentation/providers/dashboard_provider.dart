import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../user_dashboard/domain/entities/analysis_simple.dart';
import '../../../soil_analysis/presentation/providers/champ_parcelle_provider.dart';

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

// Provider pour les statistiques du tableau de bord
final dashboardStatsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  // Récupérer les données des champs
  final champsAsync = ref.watch(champsProvider);

  return champsAsync.when(
    data: (champs) {
      return AsyncValue.data({
        'capteurs': 5,  // Nombre de capteurs actifs
        'champs': champs.length,  // Nombre réel de champs enregistrés
        'alertes': 2,   // Nombre d'alertes non lues
      });
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});


// Provider pour actualiser les données
final refreshTriggerProvider = StateProvider<int>((ref) => 0);

// Provider combiné qui se actualise quand refreshTrigger change
final dashboardDataProvider = FutureProvider<bool>((ref) async {
  // Écoute le trigger de rafraîchissement
  ref.watch(refreshTriggerProvider);

  // Invalide tous les autres providers pour les forcer à se recharger
  ref.invalidate(recentAnalysesProvider);
  ref.invalidate(dashboardStatsProvider);

  return true;
});
