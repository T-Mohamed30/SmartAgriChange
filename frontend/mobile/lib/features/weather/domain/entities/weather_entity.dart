class WeatherData {
  final double temperature;
  final String condition;
  final String iconCode;
  final String location;
  final DateTime lastUpdated;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.location,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // Plus besoin de fromJson car on construit l'objet manuellement dans le repository
}
