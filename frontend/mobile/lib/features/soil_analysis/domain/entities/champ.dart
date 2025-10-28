class Champ {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double superficie;

  Champ({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.superficie,
  });

  String get location =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  Champ copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? superficie,
  }) {
    return Champ(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      superficie: superficie ?? this.superficie,
    );
  }
}
