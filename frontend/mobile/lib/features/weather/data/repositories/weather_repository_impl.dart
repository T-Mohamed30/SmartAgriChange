import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/weather_entity.dart';

class WeatherRepository {
  final String baseUrl = 'https://api.open-meteo.com/v1';

  WeatherRepository();

  Future<WeatherData> getWeather(String city) async {
    try {
      // Coordonnées de Ouagadougou, Burkina Faso
      const double lat = 12.3714;
      const double lon = -1.5197;
      const String locationName = 'Ouagadougou';
      
      // Récupérer les données météo
      final weatherUrl = Uri.parse(
        '$baseUrl/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,weathercode&timezone=auto&forecast_days=1');
      
      final weatherResponse = await http.get(weatherUrl);
      
      if (weatherResponse.statusCode == 200) {
        final data = jsonDecode(weatherResponse.body);
        final current = data['current_weather'];
        
        // Convertir le code météo en condition lisible
        final condition = _getWeatherCondition(current['weathercode']);
        
        return WeatherData(
          temperature: current['temperature'].toDouble(),
          condition: condition,
          iconCode: current['weathercode'].toString(),
          location: locationName,
        );
      } else {
        throw Exception('Échec du chargement des données météo');
      }
    } catch (e) {
      throw Exception('Erreur météo: $e');
    }
  }
  
  String _getWeatherCondition(int code) {
    // Conversion des codes météo Open-Meteo en conditions lisibles
    if (code == 0) return 'Ciel dégagé';
    if (code <= 3) return 'Partiellement nuageux';
    if (code <= 48) return 'Brume ou brouillard';
    if (code <= 67) return 'Pluie';
    if (code <= 77) return 'Neige';
    if (code <= 99) return 'Orage';
    return 'Inconnu';
  }
}
