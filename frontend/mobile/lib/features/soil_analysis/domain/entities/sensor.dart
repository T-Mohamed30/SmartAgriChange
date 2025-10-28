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

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'] as String,
      name: json['name'] as String,
      status: SensorStatus.values.firstWhere(
        (e) => e.toString() == 'SensorStatus.${json['status']}',
        orElse: () => SensorStatus.online,
      ),
      batteryLevel: json['batteryLevel'] as int?,
      location: json['location'] as String?,
      lastAnalysisAt: json['lastAnalysisAt'] != null
          ? DateTime.parse(json['lastAnalysisAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toString().split('.').last,
      'batteryLevel': batteryLevel,
      'location': location,
      'lastAnalysisAt': lastAnalysisAt?.toIso8601String(),
    };
  }
}
