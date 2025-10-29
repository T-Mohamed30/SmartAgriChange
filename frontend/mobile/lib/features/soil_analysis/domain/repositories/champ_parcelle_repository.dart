import '../entities/champ.dart';
import '../entities/parcelle.dart';

abstract class ChampParcelleRepository {
  Future<List<Champ>> fetchChamps();
  Future<List<Parcelle>> fetchParcelles({required String champId});
  Future<Champ> createChamp(
    String name,
    String location,
    double latitude,
    double longitude, {
    double? area,
  });
  Future<Parcelle> createParcelle(
    String name,
    double superficie,
    String champId,
  );
  Future<Champ> updateChamp(
    String id,
    String name,
    String location,
    double latitude,
    double longitude, {
    double? area,
  });
  Future<void> deleteChamp(String id);
  Future<Parcelle> updateParcelle(
    String id,
    String name,
    double superficie,
    String champId,
  );
  Future<void> deleteParcelle(String id);
}
