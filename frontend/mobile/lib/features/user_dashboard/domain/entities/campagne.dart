import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'culture.dart';
import 'parcelle.dart';
import 'etape_campagne.dart';

part 'campagne.g.dart';

@JsonSerializable()
enum StatutCampagne {
  @JsonValue('planifiée')
  planifiee,
  @JsonValue('en_cours')
  enCours,
  @JsonValue('terminée')
  terminee,
  @JsonValue('annulée')
  annulee
}

@JsonSerializable()
class Campagne extends Equatable {
  final String id;
  final String cultureId;
  final String parcelleId;
  final String utilisateurId;
  final String? analyseSolId;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final StatutCampagne statut;
  final int progression;
  final String? notes;
  final DateTime dateCreation;
  final DateTime? dateModification;
  
  // Relations chargées à la demande
  final Culture? culture;
  final Parcelle? parcelle;
  final List<EtapeCampagne>? etapes;

  const Campagne({
    required this.id,
    required this.cultureId,
    required this.parcelleId,
    required this.utilisateurId,
    this.analyseSolId,
    required this.dateDebut,
    this.dateFin,
    this.statut = StatutCampagne.planifiee,
    this.progression = 0,
    this.notes,
    required this.dateCreation,
    this.dateModification,
    this.culture,
    this.parcelle,
    this.etapes,
  });

  // Désérialisation JSON
  factory Campagne.fromJson(Map<String, dynamic> json) => _$CampagneFromJson(json);
  
  // Sérialisation JSON
  Map<String, dynamic> toJson() => _$CampagneToJson(this);

  // Copie avec modification
  Campagne copyWith({
    String? id,
    String? cultureId,
    String? parcelleId,
    String? utilisateurId,
    String? analyseSolId,
    DateTime? dateDebut,
    DateTime? dateFin,
    StatutCampagne? statut,
    int? progression,
    String? notes,
    DateTime? dateCreation,
    DateTime? dateModification,
    Culture? culture,
    Parcelle? parcelle,
    List<EtapeCampagne>? etapes,
  }) {
    return Campagne(
      id: id ?? this.id,
      cultureId: cultureId ?? this.cultureId,
      parcelleId: parcelleId ?? this.parcelleId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      analyseSolId: analyseSolId ?? this.analyseSolId,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statut: statut ?? this.statut,
      progression: progression ?? this.progression,
      notes: notes ?? this.notes,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      culture: culture ?? this.culture,
      parcelle: parcelle ?? this.parcelle,
      etapes: etapes ?? this.etapes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cultureId,
    parcelleId,
    utilisateurId,
    analyseSolId,
    dateDebut,
    dateFin,
    statut,
    progression,
    notes,
    dateCreation,
    dateModification,
  ];
}
