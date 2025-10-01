class AnalysePlante {
  final int id;
  final int parcelleId;
  final int utilisateurId;
  final String imageUrl;
  final int? planteIdentifieeId;
  final double? confianceIdentification;
  final List<String>? anomaliesDetectees;
  final List<String>? maladiesDetectees;
  final DateTime dateAnalyse;
  final String statut;
  final Plante? planteIdentifiee;

  AnalysePlante({
    required this.id,
    required this.parcelleId,
    required this.utilisateurId,
    required this.imageUrl,
    this.planteIdentifieeId,
    this.confianceIdentification,
    this.anomaliesDetectees,
    this.maladiesDetectees,
    required this.dateAnalyse,
    required this.statut,
    this.planteIdentifiee,
  });

  factory AnalysePlante.fromJson(Map<String, dynamic> json) {
    return AnalysePlante(
      id: json['id'],
      parcelleId: json['parcelle_id'],
      utilisateurId: json['utilisateur_id'],
      imageUrl: json['image_url'],
      planteIdentifieeId: json['plante_identifiee_id'],
      confianceIdentification: json['confiance_identification']?.toDouble(),
      anomaliesDetectees: json['anomalies_detectees'] != null
          ? List<String>.from(json['anomalies_detectees'])
          : null,
      maladiesDetectees: json['maladies_detectees'] != null
          ? List<String>.from(json['maladies_detectees'])
          : null,
      dateAnalyse: DateTime.parse(json['date_analyse']),
      statut: json['statut'],
      planteIdentifiee: json['planteIdentifiee'] != null
          ? Plante.fromJson(json['planteIdentifiee'])
          : null,
    );
  }
}

class Plante {
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
  final List<Maladie>? maladies;
  final List<AttributPlante>? attributs;

  Plante({
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
    this.maladies,
    this.attributs,
  });

  factory Plante.fromJson(Map<String, dynamic> json) {
    return Plante(
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
      maladies: json['Maladies'] != null
          ? (json['Maladies'] as List).map((m) => Maladie.fromJson(m)).toList()
          : null,
      attributs: json['attributs'] != null
          ? (json['attributs'] as List).map((a) => AttributPlante.fromJson(a)).toList()
          : null,
    );
  }
}

class AttributPlante {
  final int id;
  final String nom;
  final String? valeur;
  final String? type;
  final int planteId;

  AttributPlante({
    required this.id,
    required this.nom,
    this.valeur,
    this.type,
    required this.planteId,
  });

  factory AttributPlante.fromJson(Map<String, dynamic> json) {
    return AttributPlante(
      id: json['id'],
      nom: json['nom'],
      valeur: json['valeur'],
      type: json['type'],
      planteId: json['plante_id'],
    );
  }
}

class Maladie {
  final int id;
  final String nom;
  final String? description;
  final List<String>? symptomes;
  final List<String>? causes;
  final String? traitement;
  final String? prevention;
  final int planteId;
  final String gravite;

  Maladie({
    required this.id,
    required this.nom,
    this.description,
    this.symptomes,
    this.causes,
    this.traitement,
    this.prevention,
    required this.planteId,
    required this.gravite,
  });

  factory Maladie.fromJson(Map<String, dynamic> json) {
    return Maladie(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      symptomes: json['symptomes'] != null
          ? List<String>.from(json['symptomes'])
          : null,
      causes: json['causes'] != null
          ? List<String>.from(json['causes'])
          : null,
      traitement: json['traitement'],
      prevention: json['prevention'],
      planteId: json['plante_id'],
      gravite: json['gravite'],
    );
  }
}
