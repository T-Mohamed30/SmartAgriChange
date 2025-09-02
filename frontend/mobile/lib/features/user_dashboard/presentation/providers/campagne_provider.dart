import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagri_mobile/features/user_dashboard/domain/entities/entities.dart';
import 'package:smartagri_mobile/features/user_dashboard/data/repositories/campagne_repository_impl.dart';

// Fournisseur pour la liste des campagnes
final campagnesProvider = FutureProvider.autoDispose.family<List<Campagne>, String?>(
  (ref, statut) async {
    final repository = ref.watch(campagneRepositoryProvider);
    return await repository.getCampagnes(statut: statut);
  },
);

// Fournisseur pour les détails d'une campagne
final campagneDetailProvider = FutureProvider.autoDispose.family<Campagne, String>(
  (ref, campagneId) async {
    final repository = ref.watch(campagneRepositoryProvider);
    return await repository.getCampagne(campagneId);
  },
);

// Fournisseur pour la création d'une campagne
final creerCampagneProvider = FutureProvider.autoDispose.family<Campagne, Map<String, dynamic>>(
  (ref, params) async {
    final repository = ref.watch(campagneRepositoryProvider);
    return await repository.creerCampagne(
      analyseId: params['analyseId'] as String,
      cultureId: params['cultureId'] as String,
      dateDebut: params['dateDebut'] as DateTime,
      notes: params['notes'] as String?,
    );
  },
);

// Fournisseur pour la mise à jour du statut d'une étape
final updateEtapeStatusProvider = FutureProvider.autoDispose.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final repository = ref.watch(campagneRepositoryProvider);
    await repository.mettreAJourStatutEtape(
      etapeId: params['etapeId'] as String,
      statut: params['statut'] as String,
    );
    // Invalider le fournisseur de détails pour rafraîchir les données
    ref.invalidate(campagneDetailProvider(params['campagneId'] as String));
  },
);

// Fournisseur pour la mise à jour du statut d'une tâche
final updateTacheStatusProvider = FutureProvider.autoDispose.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final repository = ref.watch(campagneRepositoryProvider);
    await repository.mettreAJourStatutTache(
      tacheId: params['tacheId'] as String,
      statut: params['statut'] as String,
    );
    // Invalider le fournisseur de détails pour rafraîchir les données
    ref.invalidate(campagneDetailProvider(params['campagneId'] as String));
  },
);

// Fournisseur pour la suppression d'une campagne
final supprimerCampagneProvider = FutureProvider.autoDispose.family<void, String>(
  (ref, campagneId) async {
    final repository = ref.watch(campagneRepositoryProvider);
    await repository.supprimerCampagne(campagneId);
    // Invalider le fournisseur de la liste des campagnes pour rafraîchir les données
    ref.invalidate(campagnesProvider(null));
  },
);
