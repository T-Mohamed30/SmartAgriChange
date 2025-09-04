import 'package:dio/dio.dart';
import '../../domain/entities/champ.dart';
import '../../domain/entities/parcelle.dart';

class ChampParcelleRepository {
  final Dio dio;
  final String baseUrl;

  ChampParcelleRepository({required this.dio, required this.baseUrl});

  Future<List<Champ>> fetchChamps() async {
    final response = await dio.get('$baseUrl/champs');
    final data = response.data as List;
    return data
        .map(
          (json) => Champ(
            id: json['id'].toString(),
            name: json['name'],
            location: json['location'],
          ),
        )
        .toList();
  }

  Future<List<Parcelle>> fetchParcelles({required String champId}) async {
    final response = await dio.get('$baseUrl/parcelles?champId=$champId');
    final data = response.data as List;
    return data
        .map(
          (json) => Parcelle(
            id: json['id'].toString(),
            name: json['name'],
            superficie: double.tryParse(json['superficie'].toString()) ?? 0.0,
            champId: json['champId'].toString(),
          ),
        )
        .toList();
  }

  Future<Champ> createChamp(String name, String location) async {
    final response = await dio.post(
      '$baseUrl/champs',
      data: {'name': name, 'location': location},
    );
    final json = response.data;
    return Champ(
      id: json['id'].toString(),
      name: json['name'],
      location: json['location'],
    );
  }

  Future<Parcelle> createParcelle(
    String name,
    double superficie,
    String champId,
  ) async {
    final response = await dio.post(
      '$baseUrl/parcelles',
      data: {'name': name, 'superficie': superficie, 'champId': champId},
    );
    final json = response.data;
    return Parcelle(
      id: json['id'].toString(),
      name: json['name'],
      superficie: double.tryParse(json['superficie'].toString()) ?? 0.0,
      champId: json['champId'].toString(),
    );
  }

  Future<Champ> updateChamp(String id, String name, String location) async {
    final response = await dio.put(
      '$baseUrl/champs/$id',
      data: {'name': name, 'location': location},
    );
    final json = response.data;
    return Champ(
      id: json['id'].toString(),
      name: json['name'],
      location: json['location'],
    );
  }

  Future<void> deleteChamp(String id) async {
    await dio.delete('$baseUrl/champs/$id');
  }

  Future<Parcelle> updateParcelle(String id, String name, double superficie, String champId) async {
    final response = await dio.put(
      '$baseUrl/parcelles/$id',
      data: {'name': name, 'superficie': superficie, 'champId': champId},
    );
    final json = response.data;
    return Parcelle(
      id: json['id'].toString(),
      name: json['name'],
      superficie: double.tryParse(json['superficie'].toString()) ?? 0.0,
      champId: json['champId'].toString(),
    );
  }

  Future<void> deleteParcelle(String id) async {
    await dio.delete('$baseUrl/parcelles/$id');
  }
}
