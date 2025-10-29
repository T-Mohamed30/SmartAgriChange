import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/analysis_simple.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../plant_analysis/models/anomaly_analysis_models.dart';

class AnalysisRepository {
  final Dio dio;

  AnalysisRepository(this.dio);

  // Helper method to convert AnomalyAnalysisResponse to Analysis
  Analysis _convertAnomalyToAnalysis(AnomalyAnalysisResponse anomaly) {
    return Analysis(
      id:
          anomaly.id?.toString() ??
          'anomaly_${anomaly.createdAt.millisecondsSinceEpoch}',
      name: anomaly.plant.nomCommun,
      location: 'Parcelle ${anomaly.parcelId ?? 'N/A'}',
      type: 'plant',
      status: anomaly.anomaly != null
          ? AnalysisStatus.completed
          : AnalysisStatus.pending,
      createdAt: anomaly.createdAt,
      result: anomaly.anomaly?.name ?? 'Aucune anomalie détectée',
      parcelle: anomaly.parcelId?.toString(),
      imageUrl: anomaly.images.isNotEmpty ? anomaly.images.first : null,
    );
  }

  Future<List<Analysis>> fetchUserAnalyses(String userId) async {
    debugPrint(
      '🔍 AnalysisRepository: Starting fetchUserAnalyses for userId: $userId',
    );

    final List<Analysis> allAnalyses = [];

    try {
      // Fetch plant analyses from the analyses endpoint (since it returns plant data)
      debugPrint(
        '🌿 AnalysisRepository: Fetching plant analyses from analyses endpoint',
      );
      final analysesUrl = ApiEndpoints.buildUrl('/users/$userId/analyses');
      debugPrint(
        '🌐 AnalysisRepository: Making GET request to analyses: $analysesUrl',
      );

      final analysesResponse = await dio.get(analysesUrl);
      final analysesData = analysesResponse.data;

      debugPrint(
        '📦 AnalysisRepository: Analyses response data: $analysesData',
      );
      debugPrint(
        '📊 AnalysisRepository: Analyses response status: ${analysesResponse.statusCode}',
      );

      if (analysesData is Map<String, dynamic> &&
          analysesData['data'] != null) {
        final data = analysesData['data'];
        debugPrint(
          '📋 AnalysisRepository: Found analyses data array with ${data.length} items',
        );

        if (data is List) {
          try {
            // Convert the API response to analyses (plant or soil based on type)
            final analyses = data
                .map((item) {
                  final type = item['type'] as String?;
                  final analyzable =
                      item['analyzable'] as Map<String, dynamic>?;

                  if (type == 'anomaly_detection_analysis') {
                    // Plant analysis
                    final modelResult =
                        analyzable?['model_result'] as Map<String, dynamic>?;
                    final plant = analyzable?['plant'] as Map<String, dynamic>?;
                    final anomaly =
                        analyzable?['anomaly'] as Map<String, dynamic>?;
                    return Analysis(
                      id: item['id'].toString(),
                      name: plant?['nom_commun'] ?? 'Unknown Plant',
                      location: 'Parcelle ${item['parcel_id'] ?? 'N/A'}',
                      type: 'plant',
                      status: AnalysisStatus.completed,
                      createdAt: DateTime.parse(item['created_at']),
                      result: anomaly != null
                          ? anomaly['name'] ?? 'Aucune anomalie détectée'
                          : 'Aucune anomalie détectée',
                      parcelle: item['parcel_id']?.toString(),
                      imageUrl:
                          analyzable?['images'] != null &&
                              (analyzable!['images'] as List).isNotEmpty
                          ? analyzable['images'][0]
                          : null,
                    );
                  } else if (type == 'soil_analysis') {
                    // Soil analysis
                    return Analysis(
                      id: item['id'].toString(),
                      name: 'Analyse Sol',
                      location: 'Parcelle ${item['parcel_id'] ?? 'N/A'}',
                      type: 'soil',
                      status: AnalysisStatus.completed,
                      createdAt: DateTime.parse(item['created_at']),
                      result:
                          analyzable?['result'] ?? 'Résultat non disponible',
                      parcelle: item['parcel_id']?.toString(),
                    );
                  } else {
                    // Skip unknown analysis types
                    debugPrint(
                      '⚠️ AnalysisRepository: Unknown analysis type: $type. Skipping item.',
                    );
                    return null;
                  }
                })
                .where((analysis) => analysis != null)
                .cast<Analysis>()
                .toList();

            debugPrint(
              '✅ AnalysisRepository: Successfully parsed ${analyses.length} analyses',
            );
            allAnalyses.addAll(analyses);
          } catch (e) {
            debugPrint(
              '⚠️ AnalysisRepository: Error parsing analyses: $e. Skipping analyses.',
            );
          }
        }
      }

      // Fallback for direct list response
      if (analysesData is List) {
        debugPrint(
          '📋 AnalysisRepository: Direct analyses list response with ${analysesData.length} items',
        );
        try {
          final analyses = analysesData
              .map((item) {
                final type = item['type'] as String?;
                final analyzable = item['analyzable'] as Map<String, dynamic>?;

                if (type == 'anomaly_detection_analysis') {
                  // Plant analysis
                  final modelResult =
                      analyzable?['model_result'] as Map<String, dynamic>?;
                  final plant = analyzable?['plant'] as Map<String, dynamic>?;
                  final anomaly =
                      analyzable?['anomaly'] as Map<String, dynamic>?;
                  return Analysis(
                    id: item['id'].toString(),
                    name: plant?['nom_commun'] ?? 'Unknown Plant',
                    location: 'Parcelle ${item['parcel_id'] ?? 'N/A'}',
                    type: 'plant',
                    status: AnalysisStatus.completed,
                    createdAt: DateTime.parse(item['created_at']),
                    result: anomaly != null
                        ? anomaly['name'] ?? 'Aucune anomalie détectée'
                        : 'Aucune anomalie détectée',
                    parcelle: item['parcel_id']?.toString(),
                    imageUrl:
                        analyzable?['images'] != null &&
                            (analyzable!['images'] as List).isNotEmpty
                        ? analyzable['images'][0]
                        : null,
                  );
                } else if (type == 'soil_analysis') {
                  // Soil analysis
                  return Analysis(
                    id: item['id'].toString(),
                    name: 'Analyse Sol',
                    location: 'Parcelle ${item['parcel_id'] ?? 'N/A'}',
                    type: 'soil',
                    status: AnalysisStatus.completed,
                    createdAt: DateTime.parse(item['created_at']),
                    result: analyzable?['result'] ?? 'Résultat non disponible',
                    parcelle: item['parcel_id']?.toString(),
                  );
                } else {
                  // Skip unknown analysis types
                  debugPrint(
                    '⚠️ AnalysisRepository: Unknown analysis type: $type. Skipping item.',
                  );
                  return null;
                }
              })
              .where((analysis) => analysis != null)
              .cast<Analysis>()
              .toList();

          debugPrint(
            '✅ AnalysisRepository: Successfully parsed ${analyses.length} analyses from direct list',
          );
          allAnalyses.addAll(analyses);
        } catch (e) {
          debugPrint(
            '⚠️ AnalysisRepository: Error parsing analyses from direct list: $e. Skipping analyses.',
          );
        }
      }

      // TODO: Fetch soil analyses from a different endpoint when available
      debugPrint(
        '🌱 AnalysisRepository: Soil analyses endpoint not yet implemented - skipping',
      );

      // Trier par date décroissante (plus récent en premier)
      allAnalyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint(
        '🔄 AnalysisRepository: Sorted ${allAnalyses.length} total analyses by date (most recent first)',
      );

      return allAnalyses;
    } catch (e) {
      debugPrint('❌ AnalysisRepository: Error fetching user analyses: $e');
      debugPrint('🔍 AnalysisRepository: Error type: ${e.runtimeType}');
      return [];
    }
  }
}
