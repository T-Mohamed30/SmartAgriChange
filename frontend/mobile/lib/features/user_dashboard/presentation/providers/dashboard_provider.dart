import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../user_dashboard/domain/entities/analysis_simple.dart';
import '../../../soil_analysis/presentation/providers/champ_parcelle_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user_dashboard/data/repositories/analysis_repository.dart';
import '../../../../core/network/dio_client.dart';

// Provider pour le repository d'analyses
final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  final dio = DioClient().dio;
  return AnalysisRepository(dio);
});

// Provider pour les analyses récentes
final recentAnalysesProvider = FutureProvider<List<Analysis>>((ref) async {
  debugPrint('🏠 DashboardProvider: Starting recentAnalysesProvider');

  final repository = ref.read(analysisRepositoryProvider);
  // Récupérer l'ID utilisateur depuis SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');

  debugPrint(
    '👤 DashboardProvider: Retrieved userId from SharedPreferences: $userId',
  );

  if (userId == null) {
    debugPrint('⚠️ DashboardProvider: No userId found in SharedPreferences');
    return [];
  }

  final analyses = await repository.fetchUserAnalyses(userId.toString());
  debugPrint(
    '📊 DashboardProvider: Received ${analyses.length} analyses from repository',
  );

  // Retourner les 10 dernières analyses triées par date décroissante
  final recentAnalyses = analyses.take(10).toList();
  debugPrint(
    '🎯 DashboardProvider: Returning ${recentAnalyses.length} recent analyses',
  );

  return recentAnalyses;
});

// Provider pour les statistiques du tableau de bord
final dashboardStatsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  // Récupérer les données des champs
  final champsAsync = ref.watch(champsProvider);

  return champsAsync.when(
    data: (champs) {
      return AsyncValue.data({
        'capteurs': 1, // Nombre de capteurs actifs
        'champs': champs.length, // Nombre réel de champs enregistrés
        'alertes': 0, // Nombre d'alertes non lues
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
