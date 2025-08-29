import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/champ_parcelle_repository_impl.dart';
import '../../domain/entities/champ.dart';
import '../../domain/entities/parcelle.dart';

final dioProvider = Provider<Dio>((ref) => Dio());
final champParcelleRepositoryProvider = Provider<ChampParcelleRepository>((
  ref,
) {
  final dio = ref.read(dioProvider);
  // Adapter l'URL à ton backend
  return ChampParcelleRepository(
    dio: dio,
    baseUrl: 'http://localhost:3000/api',
  );
});

final champsProvider = FutureProvider<List<Champ>>((ref) async {
  final repo = ref.read(champParcelleRepositoryProvider);
  return await repo.fetchChamps();
});

final parcellesProvider = FutureProvider.family<List<Parcelle>, String>((
  ref,
  champId,
) async {
  final repo = ref.read(champParcelleRepositoryProvider);
  return await repo.fetchParcelles(champId: champId);
});

final createChampProvider = FutureProvider.family<Champ, Map<String, String>>((
  ref,
  params,
) async {
  final repo = ref.read(champParcelleRepositoryProvider);
  return await repo.createChamp(params['name']!, params['location']!);
});

final createParcelleProvider =
    FutureProvider.family<Parcelle, Map<String, dynamic>>((ref, params) async {
      final repo = ref.read(champParcelleRepositoryProvider);
      return await repo.createParcelle(
        params['name'] as String,
        params['superficie'] as double,
        params['champId'] as String,
      );
    });
