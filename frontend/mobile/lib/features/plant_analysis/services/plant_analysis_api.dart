import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/plant_analysis_models.dart';

class PlantAnalysisApi {
  // Use localhost for web development.
  // For Android emulator use http://10.0.2.2:3000/api
  // For iOS simulator use http://localhost:3000/api
  static const String baseUrl =
      'https://smartagrichangeapi.kgslab.com/api'; // Adjust port if needed

  // Analyze plant image
  @deprecated
  static Future<AnalysePlante> analyserPlante(
    int parcelleId,
    String imageBase64,
    String token,
  ) async {
    // Legacy endpoint using base64 JSON body
    final response = await http.post(
      Uri.parse('$baseUrl/analyses-plantes/analyser'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'parcelle_id': parcelleId,
        'image_base64': imageBase64,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return AnalysePlante.fromJson(data);
    } else {
      throw Exception(
        'Failed to analyze plant: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // New: upload image file via multipart/form-data (recommended)
  static Future<AnalysePlante> analyserPlanteMultipart(
    int? parcelleId,
    dynamic imageFile,
    String token,
  ) async {
    final uri = Uri.parse('$baseUrl/analyses-plantes/analyser');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    if (parcelleId != null) {
      request.fields['parcelle_id'] = parcelleId.toString();
    }
    if (!kIsWeb) {
      // On mobile, assume imageFile is File
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    } else if (kIsWeb && imageFile is List<int>) {
      // On web, imageFile is bytes
      request.files.add(
        http.MultipartFile.fromBytes('image', imageFile, filename: 'upload.jpg'),
      );
    } else {
      throw Exception('Unsupported image type for multipart upload');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final decoded = json.decode(response.body);
      final payload = decoded is Map && decoded.containsKey('data')
          ? decoded['data']
          : decoded;
      return AnalysePlante.fromJson(payload);
    } else {
      throw Exception(
        'Failed to analyze plant (multipart): ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Auto: prefer multipart when a File or bytes is available, otherwise fallback to base64 JSON
  static Future<AnalysePlante> analyserPlanteAuto(
    int? parcelleId,
    dynamic image, // File, bytes or base64 string
    String token,
  ) async {
    if (kIsWeb) {
      if (image is List<int>) {
        // bytes on web
        return analyserPlanteMultipart(parcelleId, image, token);
      } else if (image is String) {
        // base64 string
        return analyserPlante(parcelleId ?? 0, image, token);
      } else {
        throw Exception('Unsupported image type on web');
      }
    } else {
      if (image is String) {
        return analyserPlante(parcelleId ?? 0, image, token);
      } else {
        // assume File on mobile
        return analyserPlanteMultipart(parcelleId, image, token);
      }
    }
  }

  // Get analysis details by ID
  // Fetch an AnalysePlante by its ID
  static Future<AnalysePlante> getAnalysePlanteById(
    int analysisId,
    String token,
  ) async {
    final uri = Uri.parse('$baseUrl/analyses-plantes/$analysisId');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final payload = decoded is Map && decoded.containsKey('data')
          ? decoded['data']
          : decoded;
      return AnalysePlante.fromJson(payload);
    } else {
      throw Exception(
        'Failed to load analysis details: ${response.statusCode}',
      );
    }
  }

  // Get plant details by ID (if needed separately)
  static Future<Plante> getPlanteDetails(int plantId, String token) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/plantes/$plantId',
      ), // This endpoint might need to be created
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Plante.fromJson(data);
    } else {
      throw Exception('Failed to load plant details: ${response.statusCode}');
    }
  }

  // Fetch list of anomalies (public)
  static Future<List<dynamic>> getAllAnomalies() async {
    final uri = Uri.parse('$baseUrl/anomalies');
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded is List ? decoded : [];
    }
    throw Exception('Failed to fetch anomalies: ${response.statusCode}');
  }

  // Fetch specific anomalie by id (includes solutions)
  static Future<dynamic> getAnomalieById(
    int anomalieId, [
    String? token,
  ]) async {
    final uri = Uri.parse('$baseUrl/anomalies/$anomalieId');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded;
    }
    throw Exception(
      'Failed to load anomalie: ${response.statusCode} - ${response.body}',
    );
  }
}
