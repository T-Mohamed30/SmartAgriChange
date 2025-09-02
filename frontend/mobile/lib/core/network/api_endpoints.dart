import 'package:shared_preferences/shared_preferences.dart';

class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://localhost:3000';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String logout = '/api/auth/logout';

  // User endpoints
  static const String userProfile = '/api/users/me';
  static const String updateProfile = '/api/users/me';

  // Field endpoints
  static String getUserFields() => '/api/champs/me';
  static String getFieldById(String id) => '/api/champs/$id';
  static String createField() => '/api/champs';
  static String updateField(String id) => '/api/champs/$id';
  static String deleteField(String id) => '/api/champs/$id';

  // Parcelle endpoints
  static String getParcellesByChamp(String champId) => '/api/champs/$champId/parcelles';
  static String getParcelleById(String id) => '/api/parcelles/$id';
  static String createParcelle(String champId) => '/api/champs/$champId/parcelles';
  static String updateParcelle(String id) => '/api/parcelles/$id';
  static String deleteParcelle(String id) => '/api/parcelles/$id';

  // Sensor endpoints
  static const String sensors = '/api/sensors';
  static const String detectSensors = '/api/sensors/detect';
  static const String sensorAnalysis = '/api/sensors/analyze';
  
  // Soil analysis endpoints
  static const String soilAnalysis = '/api/soil-analysis';

  // Méthode pour obtenir les en-têtes avec le token d'authentification
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      return {
        ...headers,
        'Authorization': 'Bearer $token',
      };
    }
    return headers;
  }
  static const String connectToSensor = '/sensors/connect';
  static const String startAnalysis = '/sensors/analyze';
  static String getSensorData(String sensorId) => '/sensors/$sensorId/data';

  // Analysis endpoints
  static String getAnalysisHistory() => '/analysis/history';
  static String getAnalysisById(String id) => '/analysis/$id';
  static String getAnalysisByParcelle(String parcelleId) => '/analysis/parcelle/$parcelleId';
  static String createAnalysis() => '/analysis';

  // Weather endpoints
  static const String getWeather = '/weather';
  static String getWeatherForecast(String location) => '/weather/forecast?location=$location';

  // Helper methods
  static String buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$baseUrl${endpoint.startsWith('/') ? endpoint : '/$endpoint'}';
  }
}
