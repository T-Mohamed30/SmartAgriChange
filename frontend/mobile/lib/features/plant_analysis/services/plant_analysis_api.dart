import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/plant_analysis_models.dart';

class PlantAnalysisApi {
  // Use emulator host mapping by default for Android emulator.
  // If you run on a device or iOS simulator change to the appropriate host (ex: http://localhost:3000 or backend IP).
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Adjust port if needed

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
    int parcelleId,
    File imageFile,
    String token,
  ) async {
    final uri = Uri.parse('$baseUrl/analyses-plantes/analyser');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    request.fields['parcelle_id'] = parcelleId.toString();
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

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
}
