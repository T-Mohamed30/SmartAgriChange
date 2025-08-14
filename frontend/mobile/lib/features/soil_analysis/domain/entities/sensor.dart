enum SensorStatus { online, offline, lowBattery, error }

class Sensor {
  final String id;
  final String name;
  final SensorStatus status;
  final int? batteryLevel;
  final String? location;
  final DateTime? lastAnalysisAt;

  Sensor({
    required this.id,
    required this.name,
    required this.status,
    this.batteryLevel,
    this.location,
    this.lastAnalysisAt,
  });

  Sensor copyWith({
    SensorStatus? status,
    int? batteryLevel,
    String? location,
    DateTime? lastAnalysisAt,
  }) {
    return Sensor(
      id: id,
      name: name,
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      location: location ?? this.location,
      lastAnalysisAt: lastAnalysisAt ?? this.lastAnalysisAt,
    );
  }
}
