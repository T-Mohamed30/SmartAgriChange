import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/parcelle.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/recommandation_culture.dart';

part 'analyse_sol.g.dart';

@JsonSerializable()
class AnalyseSol extends Equatable {
  final String id;
  final String parcelleId;
  final String? capteurId;
  final String? utilisateurId;
  final double ph;
  final double humidite; // en pourcentage
  final double temperature; // en degrés Celsius
  final double? conductivite; // en dS/m
  final double? azote; // en ppm
  final double? phosphore; // en ppm
  final double? potassium; // en ppm
  final String? observations;
  final DateTime dateAnalyse;
  final DateTime dateCreation;
  
  // Relations chargées à la demande
  final Parcelle? parcelle;
  final List<RecommandationCulture>? recommandations;

  const AnalyseSol({
    required this.id,
    required this.parcelleId,
    this.capteurId,
    this.utilisateurId,
    required this.ph,
    required this.humidite,
    required this.temperature,
    this.conductivite,
    this.azote,
    this.phosphore,
    this.potassium,
    this.observations,
    required this.dateAnalyse,
    required this.dateCreation,
    this.parcelle,
    this.recommandations,
  });

  // Désérialisation JSON
  factory AnalyseSol.fromJson(Map<String, dynamic> json) => _$AnalyseSolFromJson(json);
  
  // Sérialisation JSON
  Map<String, dynamic> toJson() => _$AnalyseSolToJson(this);

  // Copie avec modification
  AnalyseSol copyWith({
    String? id,
    String? parcelleId,
    String? capteurId,
    String? utilisateurId,
    double? ph,
    double? humidite,
    double? temperature,
    double? conductivite,
    double? azote,
    double? phosphore,
    double? potassium,
    String? observations,
    DateTime? dateAnalyse,
    DateTime? dateCreation,
    Parcelle? parcelle,
    List<RecommandationCulture>? recommandations,
  }) {
    return AnalyseSol(
      id: id ?? this.id,
      parcelleId: parcelleId ?? this.parcelleId,
      capteurId: capteurId ?? this.capteurId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      ph: ph ?? this.ph,
      humidite: humidite ?? this.humidite,
      temperature: temperature ?? this.temperature,
      conductivite: conductivite ?? this.conductivite,
      azote: azote ?? this.azote,
      phosphore: phosphore ?? this.phosphore,
      potassium: potassium ?? this.potassium,
      observations: observations ?? this.observations,
      dateAnalyse: dateAnalyse ?? this.dateAnalyse,
      dateCreation: dateCreation ?? this.dateCreation,
      parcelle: parcelle ?? this.parcelle,
      recommandations: recommandations ?? this.recommandations,
    );
  }

  // Évaluation de la qualité du sol basée sur les paramètres
  Map<String, dynamic> evaluerQualiteSol() {
    final scores = <String, Map<String, dynamic>>{};
    
    // Évaluation du pH
    if (ph < 4.5) {
      scores['ph'] = {
        'note': 'Très acide',
        'description': 'Le sol est très acide, ce qui peut limiter la disponibilité des nutriments.',
        'conseil': 'Envisagez d\'ajouter de la chaux pour augmenter le pH du sol.'
      };
    } else if (ph < 6.5) {
      scores['ph'] = {
        'note': 'Légèrement acide à neutre',
        'description': 'Le pH est dans une plage idéale pour la plupart des cultures.',
        'conseil': 'Aucune action nécessaire pour le moment.'
      };
    } else if (ph < 7.5) {
      scores['ph'] = {
        'note': 'Neutre à légèrement alcalin',
        'description': 'Le pH est acceptable pour de nombreuses cultures.',
        'conseil': 'Surveillez les carences en fer et en manganèse qui peuvent survenir dans des sols alcalins.'
      };
    } else {
      scores['ph'] = {
        'note': 'Très alcalin',
        'description': 'Le sol est très alcalin, ce qui peut causer des carences en nutriments.',
        'conseil': 'Envisagez d\'ajouter du soufre ou de la matière organique pour abaisser le pH.'
      };
    }

    // Évaluation de l'humidité
    if (humidite < 25) {
      scores['humidite'] = {
        'note': 'Très sec',
        'description': 'Le sol est très sec, ce qui peut stresser les plantes.',
        'conseil': 'Arrosez abondamment et envisagez d\'utiliser du paillis pour retenir l\'humidité.'
      };
    } else if (humidite < 50) {
      scores['humidite'] = {
        'note': 'Légèrement sec',
        'description': 'Le sol est un peu sec pour certaines cultures sensibles.',
        'conseil': 'Un léger arrosage pourrait être bénéfique, surtout pour les jeunes plantes.'
      };
    } else if (humidite < 75) {
      scores['humidite'] = {
        'note': 'Idéal',
        'description': 'Le niveau d\'humidité est optimal pour la plupart des cultures.',
        'conseil': 'Maintenez ce niveau d\'humidité pour une croissance optimale.'
      };
    } else {
      scores['humidite'] = {
        'note': 'Trop humide',
        'description': 'Le sol est trop humide, ce qui peut provoquer des maladies racinaires.',
        'conseil': 'Évitez d\'arroser et vérifiez le drainage du sol.'
      };
    }

    // Évaluation des nutriments (si disponibles)
    if (azote != null) {
      if (azote! < 20) {
        scores['azote'] = {'note': 'Faible', 'conseil': 'Envisagez un engrais riche en azote.'};
      } else if (azote! < 50) {
        scores['azote'] = {'note': 'Moyen', 'conseil': 'Niveau acceptable, surveillez les signes de carence.'};
      } else {
        scores['azote'] = {'note': 'Élevé', 'conseil': 'Niveau suffisant, évitez les excès d\'engrais azotés.'};
      }
    }

    if (phosphore != null) {
      if (phosphore! < 10) {
        scores['phosphore'] = {'note': 'Faible', 'conseil': 'Envisagez un engrais phosphaté.'};
      } else if (phosphore! < 30) {
        scores['phosphore'] = {'note': 'Moyen', 'conseil': 'Niveau acceptable pour la plupart des cultures.'};
      } else {
        scores['phosphore'] = {'note': 'Élevé', 'conseil': 'Niveau suffisant, pas besoin d\'engrais phosphaté.'};
      }
    }

    if (potassium != null) {
      if (potassium! < 100) {
        scores['potassium'] = {'note': 'Faible', 'conseil': 'Envisagez un engrais potassique.'};
      } else if (potassium! < 250) {
        scores['potassium'] = {'note': 'Moyen', 'conseil': 'Niveau acceptable pour la plupart des cultures.'};
      } else {
        scores['potassium'] = {'note': 'Élevé', 'conseil': 'Niveau suffisant, pas besoin d\'engrais potassique.'};
      }
    }

    // Note globale
    double noteGlobale = 0;
    int nbNotes = 0;
    
    scores.forEach((key, value) {
      if (value['note'] == 'Idéal' || value['note'] == 'Élevé') {
        noteGlobale += 1.0;
      } else if (value['note'] == 'Moyen' || value['note'] == 'Légèrement acide à neutre' || value['note'] == 'Neutre à légèrement alcalin') {
        noteGlobale += 0.7;
      } else if (value['note'] == 'Faible' || value['note'] == 'Légèrement sec') {
        noteGlobale += 0.4;
      } else {
        noteGlobale += 0.1;
      }
      nbNotes++;
    });

    final noteFinale = nbNotes > 0 ? (noteGlobale / nbNotes) * 10 : 0;
    
    String qualiteGlobale;
    if (noteFinale >= 8) {
      qualiteGlobale = 'Excellente';
    } else if (noteFinale >= 6) {
      qualiteGlobale = 'Bonne';
    } else if (noteFinale >= 4) {
      qualiteGlobale = 'Moyenne';
    } else {
      qualiteGlobale = 'Médiocre';
    }

    return {
      'note': noteFinale.toStringAsFixed(1),
      'qualite': qualiteGlobale,
      'details': scores,
      'date_analyse': dateAnalyse.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    parcelleId,
    capteurId,
    utilisateurId,
    ph,
    humidite,
    temperature,
    conductivite,
    azote,
    phosphore,
    potassium,
    observations,
    dateAnalyse,
    dateCreation,
  ];
}
