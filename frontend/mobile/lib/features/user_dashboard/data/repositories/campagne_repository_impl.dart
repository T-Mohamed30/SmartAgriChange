import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagri_mobile/core/network/dio_client.dart';
import 'package:smartagri_mobile/core/network/endpoints.dart';
import 'package:smartagri_mobile/features/user_dashboard/domain/entities/entities.dart';

final campagneRepositoryProvider = Provider<CampagneRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return CampagneRepositoryImpl(dio);
});

abstract class CampagneRepository {
  Future<List<Campagne>> getCampagnes({String? statut});
  Future<Campagne> getCampagne(String id);
  Future<Campagne> creerCampagne({
    required String analyseId,
    required String cultureId,
    required DateTime dateDebut,
    String? notes,
  });
  Future<void> mettreAJourStatutEtape({
    required String etapeId,
    required String statut,
  });
  Future<void> mettreAJourStatutTache({
    required String tacheId,
    required String statut,
  });
  Future<void> supprimerCampagne(String id);
}

class CampagneRepositoryImpl implements CampagneRepository {
  final Dio _dio;

  CampagneRepositoryImpl(this._dio);

  @override
  Future<List<Campagne>> getCampagnes({String? statut}) async {
    try {
      final response = await _dio.get(
        Endpoints.campagnes,
        queryParameters: statut != null ? {'statut': statut} : null,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Campagne.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement des campagnes');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des campagnes: $e');
    }
  }

  @override
  Future<Campagne> getCampagne(String id) async {
    try {
      final response = await _dio.get('${Endpoints.campagnes}/$id');
      
      if (response.statusCode == 200) {
        return Campagne.fromJson(response.data);
      } else {
        throw Exception('Échec du chargement de la campagne');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la campagne: $e');
    }
  }

  @override
  Future<Campagne> creerCampagne({
    required String analyseId,
    required String cultureId,
    required DateTime dateDebut,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.campagnes,
        data: jsonEncode({
          'analyse_id': analyseId,
          'culture_id': cultureId,
          'date_debut': dateDebut.toIso8601String(),
          if (notes != null) 'notes': notes,
        }),
      );
      
      if (response.statusCode == 201) {
        return Campagne.fromJson(response.data['campagne']);
      } else {
        throw Exception('Échec de la création de la campagne');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la campagne: $e');
    }
  }

  @override
  Future<void> mettreAJourStatutEtape({
    required String etapeId,
    required String statut,
  }) async {
    try {
      await _dio.put(
        '${Endpoints.campagnes}/etapes/$etapeId/statut',
        data: jsonEncode({'statut': statut}),
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut de l\'étape: $e');
    }
  }

  @override
  Future<void> mettreAJourStatutTache({
    required String tacheId,
    required String statut,
  }) async {
    try {
      await _dio.put(
        '${Endpoints.campagnes}/taches/$tacheId/statut',
        data: jsonEncode({'statut': statut}),
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut de la tâche: $e');
    }
  }

  @override
  Future<void> supprimerCampagne(String id) async {
    try {
      await _dio.delete('${Endpoints.campagnes}/$id');
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la campagne: $e');
    }
  }
}
