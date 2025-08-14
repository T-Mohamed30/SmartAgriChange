class Sensor {
  final String id;
  final String name;
  final String type;
  final SensorStatus status;
  final Map<String, SensorReading> readings;
  final DateTime lastSeen;
  final String? batteryLevel;

  const Sensor({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.readings,
    required this.lastSeen,
    this.batteryLevel,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'status': status.name,
    'readings': readings.map((key, value) => MapEntry(key, value.toJson())),
    'lastSeen': lastSeen.toIso8601String(),
    'batteryLevel': batteryLevel,
  };

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    status: SensorStatus.values.byName(json['status']),
    readings: (json['readings'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, SensorReading.fromJson(value))),
    lastSeen: DateTime.parse(json['lastSeen']),
    batteryLevel: json['batteryLevel'],
  );
}

class SensorReading {
  final double value;
  final String unit;
  final DateTime timestamp;
  final String? quality;

  const SensorReading({
    required this.value,
    required this.unit,
    required this.timestamp,
    this.quality,
  });

  Map<String, dynamic> toJson() => {
    'value': value,
    'unit': unit,
    'timestamp': timestamp.toIso8601String(),
    'quality': quality,
  };

  factory SensorReading.fromJson(Map<String, dynamic> json) => SensorReading(
    value: json['value'].toDouble(),
    unit: json['unit'],
    timestamp: DateTime.parse(json['timestamp']),
    quality: json['quality'],
  );
}

enum SensorStatus {
  online,
  offline,
  lowBattery,
  error,
} 