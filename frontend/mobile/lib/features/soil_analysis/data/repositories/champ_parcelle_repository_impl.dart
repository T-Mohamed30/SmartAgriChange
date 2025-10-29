import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/champ.dart';
import '../../domain/entities/parcelle.dart';
import '../../domain/repositories/champ_parcelle_repository.dart';

class ChampParcelleRepositoryImpl implements ChampParcelleRepository {
  final Dio dio;
  final String baseUrl;

  ChampParcelleRepositoryImpl({required this.dio, required this.baseUrl});

  Future<List<Champ>> fetchChamps() async {
    final response = await dio.get('$baseUrl/fields');
    debugPrint('Fetch champs response: ${response.data}');
    final data = response.data;

    if (data == null) {
      return []; // No fields recorded
    }

    // Handle API response structure: {status: success, message: ..., data: [...]}
    if (data is Map<String, dynamic> && data['data'] != null) {
      final fieldsData = data['data'];
      if (fieldsData is List) {
        return fieldsData
            .where((json) => json['id'] != null) // Filter out invalid entries
            .map((json) {
              return Champ(
                id: json['id']?.toString() ?? '',
                name: json['name']?.toString() ?? '',
                latitude:
                    double.tryParse(json['latitude']?.toString() ?? '0.0') ??
                    0.0,
                longitude:
                    double.tryParse(json['longitude']?.toString() ?? '0.0') ??
                    0.0,
                superficie:
                    double.tryParse(json['area']?.toString() ?? '0.0') ?? 0.0,
                userId: json['user_id'] != null
                    ? int.tryParse(json['user_id'].toString())
                    : null,
              );
            })
            .toList();
      } else if (fieldsData is Map<String, dynamic>) {
        // If it's a single object, wrap it in a list
        if (fieldsData['id'] != null) {
          return [
            Champ(
              id: fieldsData['id']?.toString() ?? '',
              name: fieldsData['name']?.toString() ?? '',
              latitude:
                  double.tryParse(
                    fieldsData['latitude']?.toString() ?? '0.0',
                  ) ??
                  0.0,
              longitude:
                  double.tryParse(
                    fieldsData['longitude']?.toString() ?? '0.0',
                  ) ??
                  0.0,
              superficie:
                  double.tryParse(fieldsData['area']?.toString() ?? '0.0') ??
                  0.0,
              userId: fieldsData['user_id'] != null
                  ? int.tryParse(fieldsData['user_id'].toString())
                  : null,
            ),
          ];
        } else {
          return [];
        }
      }
    }

    // Fallback for direct list response (if API changes)
    if (data is List) {
      return data
          .where((json) => json['id'] != null) // Filter out invalid entries
          .map((json) {
            return Champ(
              id: json['id']?.toString() ?? '',
              name: json['name']?.toString() ?? '',
              latitude:
                  double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
              longitude:
                  double.tryParse(json['longitude']?.toString() ?? '0.0') ??
                  0.0,
              superficie:
                  double.tryParse(json['area']?.toString() ?? '0.0') ?? 0.0,
              userId: json['user_id'] != null
                  ? int.tryParse(json['user_id'].toString())
                  : null,
            );
          })
          .toList();
    } else if (data is Map<String, dynamic>) {
      // If it's a single object, wrap it in a list
      if (data['id'] != null) {
        return [
          Champ(
            id: data['id']?.toString() ?? '',
            name: data['name']?.toString() ?? '',
            latitude:
                double.tryParse(data['latitude']?.toString() ?? '0.0') ?? 0.0,
            longitude:
                double.tryParse(data['longitude']?.toString() ?? '0.0') ?? 0.0,
            superficie:
                double.tryParse(data['area']?.toString() ?? '0.0') ?? 0.0,
            userId: data['user_id'] != null
                ? int.tryParse(data['user_id'].toString())
                : null,
          ),
        ];
      } else {
        return [];
      }
    } else {
      throw Exception('Unexpected response format for fields');
    }
  }

  Future<List<Parcelle>> fetchParcelles({required String champId}) async {
    final response = await dio.get('$baseUrl/fields/$champId/parcels');
    final data = response.data;
    debugPrint('Fetch parcelles response: $data');

    // Handle API response structure: {status: success, message: ..., data: [...]}
    if (data is Map<String, dynamic> && data['data'] != null) {
      final parcelsData = data['data'];
      if (parcelsData is List) {
        return parcelsData
            .map(
              (json) => Parcelle(
                id: json['id']?.toString() ?? '',
                name: json['name']?.toString() ?? '',
                superficie:
                    double.tryParse(json['area']?.toString() ?? '0.0') ?? 0.0,
                champId: json['field_id']?.toString() ?? '',
              ),
            )
            .toList();
      } else if (parcelsData is Map<String, dynamic>) {
        // If it's a single object, wrap it in a list
        return [
          Parcelle(
            id: parcelsData['id']?.toString() ?? '',
            name: parcelsData['name']?.toString() ?? '',
            superficie:
                double.tryParse(parcelsData['area']?.toString() ?? '0.0') ??
                0.0,
            champId: parcelsData['field_id']?.toString() ?? '',
          ),
        ];
      }
    }

    // Fallback for direct list response
    if (data is List) {
      return data
          .map(
            (json) => Parcelle(
              id: json['id']?.toString() ?? '',
              name: json['name']?.toString() ?? '',
              superficie:
                  double.tryParse(json['area']?.toString() ?? '0.0') ?? 0.0,
              champId: json['field_id']?.toString() ?? '',
            ),
          )
          .toList();
    } else if (data is Map<String, dynamic>) {
      // If it's a single object, wrap it in a list
      return [
        Parcelle(
          id: data['id']?.toString() ?? '',
          name: data['name']?.toString() ?? '',
          superficie: double.tryParse(data['area']?.toString() ?? '0.0') ?? 0.0,
          champId: data['field_id']?.toString() ?? '',
        ),
      ];
    } else {
      throw Exception('Unexpected response format for parcels');
    }
  }

  Future<Champ> createChamp(
    String name,
    String location,
    double latitude,
    double longitude, {
    double? area,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (area != null) {
      data['area'] = area;
    }
    final response = await dio.post('$baseUrl/fields', data: data);
    final json = response.data;
    return Champ(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      superficie: double.tryParse(json['area']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Future<Parcelle> createParcelle(
    String name,
    double superficie,
    String champId,
  ) async {
    final response = await dio.post(
      '$baseUrl/parcels',
      data: {'name': name, 'area': superficie, 'field_id': champId},
    );
    final data = response.data;
    debugPrint('Create parcelle response: $data');

    // Handle API response structure: {status: success, message: ..., data: {...}}
    if (data is Map<String, dynamic> && data['data'] != null) {
      final parcelleData = data['data'];
      return Parcelle(
        id: parcelleData['id']?.toString() ?? '',
        name: parcelleData['name']?.toString() ?? '',
        superficie:
            double.tryParse(parcelleData['area']?.toString() ?? '0.0') ?? 0.0,
        champId: parcelleData['field_id']?.toString() ?? '',
      );
    }

    // Fallback for direct response
    return Parcelle(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      superficie: double.tryParse(data['area']?.toString() ?? '0.0') ?? 0.0,
      champId: data['field_id']?.toString() ?? '',
    );
  }

  Future<Champ> updateChamp(
    String id,
    String name,
    String location,
    double latitude,
    double longitude, {
    double? area,
  }) async {
    final Map<String, dynamic> updateData = {
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (area != null) {
      updateData['area'] = area;
    }
    final response = await dio.put('$baseUrl/fields/$id', data: updateData);
    final data = response.data;
    debugPrint('Update champ response: $data');

    // Handle API response structure: {status: success, message: ..., data: {...}}
    if (data is Map<String, dynamic> && data['data'] != null) {
      final champData = data['data'];
      // Check if the response contains an error
      if (champData is Map<String, dynamic> &&
          champData['status'] == 'failed') {
        throw Exception(champData['message'] ?? 'Update failed');
      }
      return Champ(
        id: champData['id']?.toString() ?? '',
        name: champData['name']?.toString() ?? '',
        latitude:
            double.tryParse(champData['latitude']?.toString() ?? '0.0') ?? 0.0,
        longitude:
            double.tryParse(champData['longitude']?.toString() ?? '0.0') ?? 0.0,
        superficie:
            double.tryParse(champData['area']?.toString() ?? '0.0') ?? 0.0,
      );
    }

    // Fallback for direct response
    return Champ(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      latitude: double.tryParse(data['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(data['longitude']?.toString() ?? '0.0') ?? 0.0,
      superficie: double.tryParse(data['area']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Future<void> deleteChamp(String id) async {
    final response = await dio.delete('$baseUrl/fields/$id');
    final data = response.data;
    debugPrint('Delete champ response: $data');

    // Handle API response structure: {status: success, message: ..., data: {...}}
    if (data is Map<String, dynamic> && data['data'] != null) {
      final deleteData = data['data'];
      // Check if the response contains an error
      if (deleteData is Map<String, dynamic> &&
          deleteData['status'] == 'failed') {
        throw Exception(deleteData['message'] ?? 'Delete failed');
      }
    }
  }

  Future<Parcelle> updateParcelle(
    String id,
    String name,
    double superficie,
    String champId,
  ) async {
    final response = await dio.put(
      '$baseUrl/parcels/$id',
      data: {'name': name, 'area': superficie, 'field_id': champId},
    );
    final data = response.data;
    debugPrint('Update parcelle response: $data');

    // Handle API response structure: {status: success, message: ..., data: {...}}
    if (data is Map<String, dynamic> && data['data'] != null) {
      final parcelleData = data['data'];
      return Parcelle(
        id: parcelleData['id']?.toString() ?? '',
        name: parcelleData['name']?.toString() ?? '',
        superficie:
            double.tryParse(parcelleData['area']?.toString() ?? '0.0') ?? 0.0,
        champId: parcelleData['field_id']?.toString() ?? '',
      );
    }

    // Fallback for direct response
    return Parcelle(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      superficie: double.tryParse(data['area']?.toString() ?? '0.0') ?? 0.0,
      champId: data['field_id']?.toString() ?? '',
    );
  }

  Future<void> deleteParcelle(String id) async {
    final response = await dio.delete('$baseUrl/parcels/$id');
    final data = response.data;
    debugPrint('Delete parcelle response: $data');

    // Handle API response structure: {status: success, message: ..., data: {...}}
    if (data is Map<String, dynamic> && data['data'] != null) {
      final deleteData = data['data'];
      // Check if the response contains an error
      if (deleteData is Map<String, dynamic> &&
          deleteData['status'] == 'failed') {
        throw Exception(deleteData['message'] ?? 'Delete failed');
      }
    }
  }
}
