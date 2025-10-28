import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    XFile imageFile, {
    int? parcelId,
  }) async {
    debugPrint('PlantAnalysisService: Starting plant image analysis...');
    try {
      debugPrint('PlantAnalysisService: Getting auth headers...');
      final headers = await _getAuthHeaders();
      debugPrint('PlantAnalysisService: Auth headers obtained');

      debugPrint('PlantAnalysisService: Preparing form data...');
      final formData = FormData();

      // Use XFile for cross-platform compatibility
      debugPrint('PlantAnalysisService: Using cross-platform file handling');
      final bytes = await imageFile.readAsBytes();
      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(bytes, filename: 'plant_image.jpg'),
        ),
      );

      if (parcelId != null) {
        formData.fields.add(MapEntry('parcel_id', parcelId.toString()));
      }
      debugPrint('PlantAnalysisService: Form data prepared');

      debugPrint(
        'PlantAnalysisService: Sending POST request to /anomaly-analyses/img',
      );
      final response = await _dioClient.dio.post(
        ApiEndpoints.buildUrl('/anomaly-analyses/img'),
        data: formData,
        options: Options(headers: headers),
      );
      debugPrint(
        'PlantAnalysisService: Response received - Status: ${response.statusCode}',
      );
      debugPrint(
        'PlantAnalysisService: Response data: ${jsonEncode(response.data)}',
      );
      debugPrint('Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
          'PlantAnalysisService: Analysis successful, parsing response...',
        );
        // Check if the response contains an error status
        final responseData = response.data['data'];
        if (responseData is Map<String, dynamic> && responseData['status'] == 'failed') {
          final errorMessage = responseData['message'] ?? 'Unknown error occurred';
          final errorDetails = responseData['errors'] ?? '';
          debugPrint(
            'PlantAnalysisService: API returned error status - Message: $errorMessage, Details: $errorDetails',
          );
          throw Exception('Analysis failed: $errorMessage${errorDetails.isNotEmpty ? ' - $errorDetails' : ''}');
        }
        return AnomalyAnalysisResponse.fromJson(responseData);
      } else {
        debugPrint(
          'PlantAnalysisService: Failed to analyze plant image - Status: ${response.statusCode}, Message: ${response.statusMessage}',
        );
        throw Exception(
          'Failed to analyze plant image: ${response.statusMessage}',
        );
      }
    } catch (e) {
      debugPrint('PlantAnalysisService: Error analyzing plant image: $e');
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
