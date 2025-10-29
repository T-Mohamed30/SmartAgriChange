import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/champ_parcelle_repository_impl.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/champ.dart';
import '../../domain/entities/parcelle.dart';

final champParcelleRepositoryProvider = Provider<ChampParcelleRepositoryImpl>((
  ref,
) {
  final dio = DioClient();
  return ChampParcelleRepositoryImpl(
    dio: dio.dio,
    baseUrl: ApiEndpoints.baseUrl,
  );
});

final champsProvider = FutureProvider<List<Champ>>((ref) async {
  final repo = ref.read(champParcelleRepositoryProvider);
  // Récupérer l'ID utilisateur depuis SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');

  if (userId == null) return [];

  final champs = await repo.fetchChamps();
  debugPrint('Fetched champs: ${champs.length}');

  // Filtrer les champs par utilisateur connecté
  final userChamps = champs.where((champ) => champ.userId == userId).toList();
  debugPrint('Filtered champs for user $userId: ${userChamps.length}');

  return userChamps;
});

final parcellesProvider = FutureProvider.family<List<Parcelle>, String>((
  ref,
  champId,
) async {
  final repo = ref.read(champParcelleRepositoryProvider);
  final parcelles = await repo.fetchParcelles(champId: champId);
  debugPrint('Fetched parcelles for champ $champId: ${parcelles.length}');
  return parcelles;
});

final createChampProvider = FutureProvider.family<Champ, Map<String, dynamic>>((
  ref,
  params,
) async {
  final repo = ref.read(champParcelleRepositoryProvider);
  final champ = await repo.createChamp(
    params['name'] as String,
    params['location'] as String,
    params['latitude'] as double,
    params['longitude'] as double,
    area: params['area'] as double?,
  );
  debugPrint(
    'Created champ: ${champ.name} at ${champ.location} (${champ.superficie} ha)',
  );
  return champ;
});

final createParcelleProvider =
    FutureProvider.family<Parcelle, Map<String, dynamic>>((ref, params) async {
      final repo = ref.read(champParcelleRepositoryProvider);
      final parcelle = await repo.createParcelle(
        params['name'] as String,
        params['superficie'] as double,
        params['champId'] as String,
      );
      debugPrint(
        'Created parcelle: ${parcelle.name} (${parcelle.superficie} ha) for champ ${params['champId']}',
      );
      return parcelle;
    });

final updateChampProvider = FutureProvider.family<Champ, Map<String, dynamic>>((
  ref,
  params,
) async {
  final repo = ref.read(champParcelleRepositoryProvider);
  final champ = await repo.updateChamp(
    params['id'] as String,
    params['name'] as String,
    params['location'] as String,
    params['latitude'] as double,
    params['longitude'] as double,
    area: params['area'] as double?,
  );
  debugPrint(
    'Updated champ ${params['id']}: ${champ.name} at ${champ.location} (${champ.superficie} ha)',
  );
  return champ;
});

final deleteChampProvider = FutureProvider.family<void, String>((
  ref,
  champId,
) async {
  final repo = ref.read(champParcelleRepositoryProvider);
  await repo.deleteChamp(champId);
  debugPrint('Deleted champ: $champId');
});

final updateParcelleProvider =
    FutureProvider.family<Parcelle, Map<String, dynamic>>((ref, params) async {
      final repo = ref.read(champParcelleRepositoryProvider);
      final parcelle = await repo.updateParcelle(
        params['id'] as String,
        params['name'] as String,
        params['superficie'] as double,
        params['champId'] as String,
      );
      debugPrint(
        'Updated parcelle ${params['id']}: ${parcelle.name} (${parcelle.superficie} ha)',
      );
      return parcelle;
    });

final deleteParcelleProvider = FutureProvider.family<void, String>((
  ref,
  parcelleId,
) async {
  final repo = ref.read(champParcelleRepositoryProvider);
  await repo.deleteParcelle(parcelleId);
  debugPrint('Deleted parcelle: $parcelleId');
});
