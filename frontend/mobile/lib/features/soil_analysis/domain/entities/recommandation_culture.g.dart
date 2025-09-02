// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommandation_culture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommandationCulture _$RecommandationCultureFromJson(
  Map<String, dynamic> json,
) => RecommandationCulture(
  id: json['id'] as String,
  cultureId: json['cultureId'] as String,
  cultureNom: json['cultureNom'] as String,
  analyseSolId: json['analyseSolId'] as String,
  scoreCompatibility: (json['scoreCompatibility'] as num).toDouble(),
  details: json['details'] as Map<String, dynamic>?,
  dateCreation: DateTime.parse(json['dateCreation'] as String),
);

Map<String, dynamic> _$RecommandationCultureToJson(
  RecommandationCulture instance,
) => <String, dynamic>{
  'id': instance.id,
  'cultureId': instance.cultureId,
  'cultureNom': instance.cultureNom,
  'analyseSolId': instance.analyseSolId,
  'scoreCompatibility': instance.scoreCompatibility,
  'details': instance.details,
  'dateCreation': instance.dateCreation.toIso8601String(),
};
