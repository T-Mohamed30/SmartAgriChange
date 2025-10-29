class Analysis {
  final String id;
  final String name;
  final String location;
  final String type; // 'soil' ou 'plant'
  final AnalysisStatus status;
  final DateTime createdAt;
  final String? result;
  final String? parcelle;
  final String? imageUrl; // URL de l'image pour les analyses de plantes

  const Analysis({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
    required this.createdAt,
    this.result,
    this.parcelle,
    this.imageUrl,
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
    'imageUrl': imageUrl,
  };

  factory Analysis.fromJson(Map<String, dynamic> json) => Analysis(
    id: json['id'].toString(),
    name: json['name'],
    location: json['location'],
    type: json['type'],
    status: AnalysisStatus.values.byName(json['status']),
    createdAt: DateTime.parse(json['createdAt']),
    result: json['result'],
    parcelle: json['parcelle'],
    imageUrl: json['imageUrl'],
  );
}

enum AnalysisStatus { pending, completed, failed }
