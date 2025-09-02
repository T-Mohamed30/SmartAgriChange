import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tache.g.dart';

@JsonSerializable()
enum PrioriteTache {
  @JsonValue('basse')
  basse,
  @JsonValue('moyenne')
  moyenne,
  @JsonValue('haute')
  haute,
  @JsonValue('critique')
  critique
}

@JsonSerializable()
enum StatutTache {
  @JsonValue('à_faire')
  aFaire,
  @JsonValue('en_cours')
  enCours,
  @JsonValue('terminée')
  terminee,
  @JsonValue('annulée')
  annulee
}

@JsonSerializable()
class Tache extends Equatable {
  final String id;
  final String etapeCampagneId;
  final String description;
  final PrioriteTache priorite;
  final int? dureeEstimee; // en minutes
  final List<String>? materielRequis;
  final StatutTache statut;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final DateTime dateCreation;
  final DateTime? dateModification;

  const Tache({
    required this.id,
    required this.etapeCampagneId,
    required this.description,
    this.priorite = PrioriteTache.moyenne,
    this.dureeEstimee,
    this.materielRequis,
    this.statut = StatutTache.aFaire,
    this.dateDebut,
    this.dateFin,
    required this.dateCreation,
    this.dateModification,
  });

  // Désérialisation JSON
  factory Tache.fromJson(Map<String, dynamic> json) => _$TacheFromJson(json);
  
  // Sérialisation JSON
  Map<String, dynamic> toJson() => _$TacheToJson(this);

  // Copie avec modification
  Tache copyWith({
    String? id,
    String? etapeCampagneId,
    String? description,
    PrioriteTache? priorite,
    int? dureeEstimee,
    List<String>? materielRequis,
    StatutTache? statut,
    DateTime? dateDebut,
    DateTime? dateFin,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Tache(
      id: id ?? this.id,
      etapeCampagneId: etapeCampagneId ?? this.etapeCampagneId,
      description: description ?? this.description,
      priorite: priorite ?? this.priorite,
      dureeEstimee: dureeEstimee ?? this.dureeEstimee,
      materielRequis: materielRequis ?? this.materielRequis,
      statut: statut ?? this.statut,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  @override
  List<Object?> get props => [
    id,
    etapeCampagneId,
    description,
    priorite,
    dureeEstimee,
    materielRequis,
    statut,
    dateDebut,
    dateFin,
    dateCreation,
    dateModification,
  ];
}
