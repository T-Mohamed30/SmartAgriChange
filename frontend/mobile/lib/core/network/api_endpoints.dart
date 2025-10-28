import 'package:shared_preferences/shared_preferences.dart';

class ApiEndpoints {
  // Base URL
  // For Android emulator (Android Studio/AVD) use 10.0.2.2 to reach host machine localhost
  // For iOS simulator use http://localhost:3000
  // For web use http://localhost:3000
  // Change this before building to a real host or production URL.
  static const String baseUrl = 'https://smartagrichangeapi.kgslab.com/api';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/users/farmers/register';
  static String verifyOtp(String userId) => '/users/$userId/verify-otp';
  static String resendOtp(String userId) => '/users/$userId/resend-otp';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // User endpoints
  static String userProfile(String farmerId) => '/users/farmers/$farmerId/profile';
  static String updateProfile(String farmerId) => '/users/farmers/$farmerId/profile';
  static String changePassword(String userId) => '/users/$userId/change-password';

  // Field endpoints
  static const String fields = '/fields';
  static String getFieldById(String id) => '/fields/$id';
  static String getFieldParcels(String fieldId) => '/fields/$fieldId/parcels';

  // Parcelle endpoints
  static const String parcels = '/parcels';
  static String getParcelleById(String id) => '/parcels/$id';

  // Soil analysis endpoints
  static const String soilAnalyses = '/soil-analyses';
  static String getSoilAnalysisById(String id) => '/soil-analyses/$id';
  static String getUserSoilAnalyses(String userId) => '/users/$userId/soil-analyses';

  // Analysis endpoints
  static const String analyses = '/analyses';
  static String getAnalysisById(String id) => '/analyses/$id';
  static String getAnalysisByParcelle(String parcelleId) => '/analyses/parcelle/$parcelleId';

  // Sensor endpoints
  static const String sensors = '/api/sensors';
  static const String detectSensors = '/api/sensors/detect';
  static const String sensorAnalysis = '/api/sensors/analyze';

  // Soil analysis endpoints
  static const String soilAnalysis = '/api/soil-analysis';

  // Méthode pour obtenir les en-têtes avec le token d'authentification
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      return {...headers, 'Authorization': 'Bearer $token'};
    }
    return headers;
  }

  static const String connectToSensor = '/sensors/connect';
  static const String startAnalysis = '/sensors/analyze';
  static String getSensorData(String sensorId) => '/sensors/$sensorId/data';

  // Analysis endpoints
  static String getAnalysisHistory() => '/analysis/history';
  static String createAnalysis() => '/analysis';

  // Weather endpoints
  static const String getWeather = '/weather';
  static String getWeatherForecast(String location) =>
      '/weather/forecast?location=$location';

  // Plant analysis endpoints
  static const String plants = '/plants';
  static String getPlantById(String plantId) => '/plants/$plantId';
  static String getPlantWithRubrics(String plantId) => '/plants/$plantId/with-rubrics';
  static const String plantsWithRubrics = '/plants/with-rubrics';
  static String getPlantAnomalies(String plantId) => '/plants/$plantId/anomalies';
  static String getUserPlantAnalyses(String userId) => '/users/$userId/anomaly-analyses';
  static String getPlantAnalysisById(String analysisId) => '/anomaly-analyses/$analysisId';

  // Helper methods
  static String buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$baseUrl${endpoint.startsWith('/') ? endpoint : '/$endpoint'}';
  }
}
