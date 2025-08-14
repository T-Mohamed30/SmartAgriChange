class Analysis {
  final String id;
  final String name;
  final String location;
  final String type; // 'soil' ou 'plant'
  final AnalysisStatus status;
  final DateTime createdAt;
  final String? result;
  final String? parcelle;

  const Analysis({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
    required this.createdAt,
    this.result,
    this.parcelle,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'type': type,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'result': result,
    'parcelle': parcelle,
  };

  factory Analysis.fromJson(Map<String, dynamic> json) => Analysis(
    id: json['id'],
    name: json['name'],
    location: json['location'],
    type: json['type'],
    status: AnalysisStatus.values.byName(json['status']),
    createdAt: DateTime.parse(json['createdAt']),
    result: json['result'],
    parcelle: json['parcelle'],
  );
}

enum AnalysisStatus {
  pending,
  completed,
  failed,
} 