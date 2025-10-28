import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartagrichange_mobile/core/network/api_endpoints.dart';
import 'package:smartagrichange_mobile/core/network/dio_client.dart';
import 'package:smartagrichange_mobile/features/plant_analysis/models/anomaly_analysis_models.dart';

class PlantAnalysisService {
  final DioClient _dioClient;

  PlantAnalysisService(this._dioClient);

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
    }
    return {'Accept': 'application/json'};
  }

  /// Upload a single image for plant analysis
  Future<AnomalyAnalysisResponse> analyzePlantImage(
    File imageFile, {
    int? parcelId,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'plant_image.jpg',
        ),
        if (parcelId != null) 'parcel_id': parcelId.toString(),
      });

      final response = await _dioClient.dio.post(
        ApiEndpoints.buildUrl('/anomaly-analyses/img'),
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AnomalyAnalysisResponse.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to analyze plant image: ${response.statusMessage}',
        );
      }
    } catch (e) {
      throw Exception('Error analyzing plant image: $e');
    }
  }

  /// Upload multiple images for plant analysis
  Future<AnomalyAnalysisResponse> analyzePlantImages(
    List<File> imageFiles, {
    int? parcelId,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final formData = FormData();

      for (int i = 0; i < imageFiles.length; i++) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              imageFiles[i].path,
              filename: 'plant_image_$i.jpg',
            ),
          ),
        );
      }

      if (parcelId != null) {
        formData.fields.add(MapEntry('parcel_id', parcelId.toString()));
      }

      final response = await _dioClient.dio.post(
        ApiEndpoints.buildUrl('/anomaly-analyses/imgs'),
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AnomalyAnalysisResponse.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to analyze plant images: ${response.statusMessage}',
        );
      }
    } catch (e) {
      throw Exception('Error analyzing plant images: $e');
    }
  }

  /// Get all plant analyses for current user
  Future<List<AnomalyAnalysisResponse>> getUserPlantAnalyses() async {
    try {
      final headers = await _getAuthHeaders();

      // We need to get current user ID first
      final userResponse = await _dioClient.dio.get(
        ApiEndpoints.buildUrl(ApiEndpoints.me),
        options: Options(headers: headers),
      );

      if (userResponse.statusCode == 200) {
        final userId = userResponse.data['data']['id'].toString();

        final response = await _dioClient.dio.get(
          ApiEndpoints.buildUrl(ApiEndpoints.getUserPlantAnalyses(userId)),
          options: Options(headers: headers),
        );

        if (response.statusCode == 200) {
          final data = response.data['data'] as List;
          return data
              .map((item) => AnomalyAnalysisResponse.fromJson(item))
              .toList();
        }
      }

      throw Exception('Failed to get user plant analyses');
    } catch (e) {
      throw Exception('Error getting user plant analyses: $e');
    }
  }

  /// Get plant analysis by ID
  Future<AnomalyAnalysisResponse> getPlantAnalysisById(
    String analysisId,
  ) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _dioClient.dio.get(
        ApiEndpoints.buildUrl(ApiEndpoints.getPlantAnalysisById(analysisId)),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return AnomalyAnalysisResponse.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to get plant analysis: ${response.statusMessage}',
        );
      }
    } catch (e) {
      throw Exception('Error getting plant analysis: $e');
    }
  }

  /// Get all plants
  Future<List<Plant>> getPlants() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _dioClient.dio.get(
        ApiEndpoints.buildUrl(ApiEndpoints.plants),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((item) => Plant.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get plants: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting plants: $e');
    }
  }

  /// Get plant by ID
  Future<Plant> getPlantById(String plantId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _dioClient.dio.get(
        ApiEndpoints.buildUrl(ApiEndpoints.getPlantById(plantId)),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return Plant.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get plant: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting plant: $e');
    }
  }

  /// Get plant with rubrics
  Future<Plant> getPlantWithRubrics(String plantId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _dioClient.dio.get(
        ApiEndpoints.buildUrl(ApiEndpoints.getPlantWithRubrics(plantId)),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return Plant.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to get plant with rubrics: ${response.statusMessage}',
        );
      }
    } catch (e) {
      throw Exception('Error getting plant with rubrics: $e');
    }
  }

  /// Get all plants with rubrics
  Future<List<Plant>> getPlantsWithRubrics() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _dioClient.dio.get(
        ApiEndpoints.buildUrl(ApiEndpoints.plantsWithRubrics),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((item) => Plant.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to get plants with rubrics: ${response.statusMessage}',
        );
      }
    } catch (e) {
      throw Exception('Error getting plants with rubrics: $e');
    }
  }

  /// Get plant anomalies
  Future<List<Anomaly>> getPlantAnomalies(String plantId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _dioClient.dio.get(
        ApiEndpoints.buildUrl(ApiEndpoints.getPlantAnomalies(plantId)),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((item) => Anomaly.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to get plant anomalies: ${response.statusMessage}',
        );
      }
    } catch (e) {
      throw Exception('Error getting plant anomalies: $e');
    }
  }
}
