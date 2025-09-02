import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recommandation_culture.g.dart';

@JsonSerializable()
class RecommandationCulture extends Equatable {
  final String id;
  final String cultureId;
  final String cultureNom;
  final String analyseSolId;
  final double scoreCompatibility;
  final Map<String, dynamic>? details;
  final DateTime dateCreation;

  const RecommandationCulture({
    required this.id,
    required this.cultureId,
    required this.cultureNom,
    required this.analyseSolId,
    required this.scoreCompatibility,
    this.details,
    required this.dateCreation,
  });

  factory RecommandationCulture.fromJson(Map<String, dynamic> json) => 
      _$RecommandationCultureFromJson(json);

  Map<String, dynamic> toJson() => _$RecommandationCultureToJson(this);

  @override
  List<Object?> get props => [
        id,
        cultureId,
        cultureNom,
        analyseSolId,
        scoreCompatibility,
        details,
        dateCreation,
      ];
}
