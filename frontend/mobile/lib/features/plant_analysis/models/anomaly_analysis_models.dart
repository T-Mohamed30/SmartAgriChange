/// Response for anomaly detection analysis
class AnomalyAnalysisResponse {
  final int? id;
  final ClassifierPrediction modelResult;
  final DateTime createdAt;
  final int userId;
  final int? parcelId;
  final List<String> images;
  final Plant plant;
  final Anomaly anomaly;

  AnomalyAnalysisResponse({
    this.id,
    required this.modelResult,
    required this.createdAt,
    required this.userId,
    this.parcelId,
    required this.images,
    required this.plant,
    required this.anomaly,
  });

  factory AnomalyAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnomalyAnalysisResponse(
      id: json['id'],
      modelResult: ClassifierPrediction.fromJson(json['model_result']),
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      parcelId: json['parcel_id'],
      images: List<String>.from(json['images']),
      plant: Plant.fromJson(json['plant']),
      anomaly: Anomaly.fromJson(json['anomaly']),
    );
  }
}

/// Classifier prediction from AI model
class ClassifierPrediction {
  final String prediction;
  final double confidence;
  final String? details;

  ClassifierPrediction({
    required this.prediction,
    required this.confidence,
    this.details,
  });

  factory ClassifierPrediction.fromJson(Map<String, dynamic> json) {
    return ClassifierPrediction(
      prediction: json['prediction'],
      confidence: json['confidence'].toDouble(),
      details: json['details'],
    );
  }
}

/// Plant model for API
class Plant {
  final int id;
  final String nomScientifique;
  final String nomCommun;
  final String? description;
  final String? familleBotanique;
  final String? type;
  final String? cycleVie;
  final String? imageUrl;
  final List<String>? galeriePhotos;
  final bool estActive;
  final List<Rubric>? rubrics;
  final List<Anomaly>? anomalies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Plant({
    required this.id,
    required this.nomScientifique,
    required this.nomCommun,
    this.description,
    this.familleBotanique,
    this.type,
    this.cycleVie,
    this.imageUrl,
    this.galeriePhotos,
    required this.estActive,
    this.rubrics,
    this.anomalies,
    this.createdAt,
    this.updatedAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      nomScientifique: json['nom_scientifique'],
      nomCommun: json['nom_commun'],
      description: json['description'],
      familleBotanique: json['famille_botanique'],
      type: json['type'],
      cycleVie: json['cycle_vie'],
      imageUrl: json['image_url'],
      galeriePhotos: json['galerie_photos'] != null
          ? List<String>.from(json['galerie_photos'])
          : null,
      estActive: json['est_active'] ?? true,
      rubrics: json['rubrics'] != null
          ? (json['rubrics'] as List).map((r) => Rubric.fromJson(r)).toList()
          : null,
      anomalies: json['anomalies'] != null
          ? (json['anomalies'] as List).map((a) => Anomaly.fromJson(a)).toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

/// Rubric model for plant information
class Rubric {
  final int id;
  final int plantId;
  final String name;
  final List<RubricInfo>? infos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Rubric({
    required this.id,
    required this.plantId,
    required this.name,
    this.infos,
    this.createdAt,
    this.updatedAt,
  });

  factory Rubric.fromJson(Map<String, dynamic> json) {
    return Rubric(
      id: json['id'],
      plantId: json['plant_id'],
      name: json['name'],
      infos: json['infos'] != null
          ? (json['infos'] as List).map((i) => RubricInfo.fromJson(i)).toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

/// Rubric info model
class RubricInfo {
  final int id;
  final int rubricId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RubricInfo({
    required this.id,
    required this.rubricId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory RubricInfo.fromJson(Map<String, dynamic> json) {
    return RubricInfo(
      id: json['id'],
      rubricId: json['rubric_id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

/// Anomaly model for plant diseases/pests
class Anomaly {
  final int id;
  final int plantId;
  final String nom;
  final String? description;
  final List<String>? symptomes;
  final List<String>? causes;
  final String? traitement;
  final String? prevention;
  final String? gravite;
  final List<String>? images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Anomaly({
    required this.id,
    required this.plantId,
    required this.nom,
    this.description,
    this.symptomes,
    this.causes,
    this.traitement,
    this.prevention,
    this.gravite,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory Anomaly.fromJson(Map<String, dynamic> json) {
    return Anomaly(
      id: json['id'],
      plantId: json['plant_id'],
      nom: json['nom'],
      description: json['description'],
      symptomes: json['symptomes'] != null
          ? List<String>.from(json['symptomes'])
          : null,
      causes: json['causes'] != null ? List<String>.from(json['causes']) : null,
      traitement: json['traitement'],
      prevention: json['prevention'],
      gravite: json['gravite'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
