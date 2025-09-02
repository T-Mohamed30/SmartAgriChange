import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'culture.dart';
import 'analyse_sol.dart';

part 'recommandation_culture.g.dart';

@JsonSerializable()
class RecommandationCulture extends Equatable {
  final String id;
  final String analyseSolId;
  final String cultureId;
  final double scoreCompatibilite; // de 0 à 100
  final Map<String, dynamic> details; // Détails de la compatibilité
  final String recommandation;
  final DateTime dateCreation;
  
  // Relations chargées à la demande
  final Culture? culture;
  final AnalyseSol? analyseSol;

  const RecommandationCulture({
    required this.id,
    required this.analyseSolId,
    required this.cultureId,
    required this.scoreCompatibilite,
    required this.details,
    required this.recommandation,
    required this.dateCreation,
    this.culture,
    this.analyseSol,
  });

  // Désérialisation JSON
  factory RecommandationCulture.fromJson(Map<String, dynamic> json) => 
      _$RecommandationCultureFromJson(json);
  
  // Sérialisation JSON
  Map<String, dynamic> toJson() => _$RecommandationCultureToJson(this);

  // Copie avec modification
  RecommandationCulture copyWith({
    String? id,
    String? analyseSolId,
    String? cultureId,
    double? scoreCompatibilite,
    Map<String, dynamic>? details,
    String? recommandation,
    DateTime? dateCreation,
    Culture? culture,
    AnalyseSol? analyseSol,
  }) {
    return RecommandationCulture(
      id: id ?? this.id,
      analyseSolId: analyseSolId ?? this.analyseSolId,
      cultureId: cultureId ?? this.cultureId,
      scoreCompatibilite: scoreCompatibilite ?? this.scoreCompatibilite,
      details: details ?? this.details,
      recommandation: recommandation ?? this.recommandation,
      dateCreation: dateCreation ?? this.dateCreation,
      culture: culture ?? this.culture,
      analyseSol: analyseSol ?? this.analyseSol,
    );
  }

  // Évaluer la qualité de la recommandation
  String get qualite {
    if (scoreCompatibilite >= 80) return 'Excellente';
    if (scoreCompatibilite >= 60) return 'Bonne';
    if (scoreCompatibilite >= 40) return 'Moyenne';
    return 'Faible';
  }

  // Obtenir la couleur associée à la qualité
  String get couleurQualite {
    if (scoreCompatibilite >= 80) return '0xFF4CAF50'; // Vert
    if (scoreCompatibilite >= 60) return '0xFF8BC34A'; // Vert clair
    if (scoreCompatibilite >= 40) return '0xFFFFC107'; // Jaune
    return '0xFFF44336'; // Rouge
  }

  // Obtenir les points forts de la recommandation
  List<String> get pointsForts {
    final points = <String>[];
    
    details.forEach((key, value) {
      if (value is Map && value['score'] != null && value['score'] >= 0.7) {
        points.add(key);
      }
    });
    
    return points;
  }

  // Obtenir les points à améliorer
  List<String> get pointsFaibles {
    final points = <String>[];
    
    details.forEach((key, value) {
      if (value is Map && value['score'] != null && value['score'] < 0.5) {
        points.add(key);
      }
    });
    
    return points;
  }

  @override
  List<Object?> get props => [
    id,
    analyseSolId,
    cultureId,
    scoreCompatibilite,
    recommandation,
    dateCreation,
  ];
}
