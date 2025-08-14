class Weather {
  final double temperature;
  final String condition;
  final String description;
  final String icon;
  final DateTime lastUpdated;

  const Weather({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.icon,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'condition': condition,
    'description': description,
    'icon': icon,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    temperature: json['temperature'].toDouble(),
    condition: json['condition'],
    description: json['description'],
    icon: json['icon'],
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );
} 