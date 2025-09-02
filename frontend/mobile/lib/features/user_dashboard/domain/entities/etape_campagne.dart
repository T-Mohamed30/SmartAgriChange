import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'tache.dart';

part 'etape_campagne.g.dart';

@JsonSerializable()
enum StatutEtape {
  @JsonValue('à_faire')
  aFaire,
  @JsonValue('en_cours')
  enCours,
  @JsonValue('terminée')
  terminee,
  @JsonValue('en_retard')
  enRetard
}

@JsonSerializable()
class EtapeCampagne extends Equatable {
  final String id;
  final String campagneId;
  final String etapeCultureId;
  final String nom;
  final String? description;
  final int dureeJours;
  final DateTime dateDebut;
  final DateTime dateFin;
  final StatutEtape statut;
  final int ordre;
  final DateTime dateCreation;
  final DateTime? dateModification;
  
  // Relations chargées à la demande
  final List<Tache>? taches;

  const EtapeCampagne({
    required this.id,
    required this.campagneId,
    required this.etapeCultureId,
    required this.nom,
    this.description,
    required this.dureeJours,
    required this.dateDebut,
    required this.dateFin,
    this.statut = StatutEtape.aFaire,
    required this.ordre,
    required this.dateCreation,
    this.dateModification,
    this.taches,
  });

  // Désérialisation JSON
  factory EtapeCampagne.fromJson(Map<String, dynamic> json) => _$EtapeCampagneFromJson(json);
  
  // Sérialisation JSON
  Map<String, dynamic> toJson() => _$EtapeCampagneToJson(this);

  // Copie avec modification
  EtapeCampagne copyWith({
    String? id,
    String? campagneId,
    String? etapeCultureId,
    String? nom,
    String? description,
    int? dureeJours,
    DateTime? dateDebut,
    DateTime? dateFin,
    StatutEtape? statut,
    int? ordre,
    DateTime? dateCreation,
    DateTime? dateModification,
    List<Tache>? taches,
  }) {
    return EtapeCampagne(
      id: id ?? this.id,
      campagneId: campagneId ?? this.campagneId,
      etapeCultureId: etapeCultureId ?? this.etapeCultureId,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      dureeJours: dureeJours ?? this.dureeJours,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statut: statut ?? this.statut,
      ordre: ordre ?? this.ordre,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      taches: taches ?? this.taches,
    );
  }

  @override
  List<Object?> get props => [
    id,
    campagneId,
    etapeCultureId,
    nom,
    description,
    dureeJours,
    dateDebut,
    dateFin,
    statut,
    ordre,
    dateCreation,
    dateModification,
  ];
}
