// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyse_sol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyseSol _$AnalyseSolFromJson(Map<String, dynamic> json) => AnalyseSol(
  id: json['id'] as String,
  parcelleId: json['parcelleId'] as String,
  capteurId: json['capteurId'] as String?,
  utilisateurId: json['utilisateurId'] as String?,
  ph: (json['ph'] as num).toDouble(),
  humidite: (json['humidite'] as num).toDouble(),
  temperature: (json['temperature'] as num).toDouble(),
  conductivite: (json['conductivite'] as num?)?.toDouble(),
  azote: (json['azote'] as num?)?.toDouble(),
  phosphore: (json['phosphore'] as num?)?.toDouble(),
  potassium: (json['potassium'] as num?)?.toDouble(),
  observations: json['observations'] as String?,
  dateAnalyse: DateTime.parse(json['dateAnalyse'] as String),
  dateCreation: DateTime.parse(json['dateCreation'] as String),
  parcelle: json['parcelle'] == null
      ? null
      : Parcelle.fromJson(json['parcelle'] as Map<String, dynamic>),
  recommandations: (json['recommandations'] as List<dynamic>?)
      ?.map((e) => RecommandationCulture.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AnalyseSolToJson(AnalyseSol instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parcelleId': instance.parcelleId,
      'capteurId': instance.capteurId,
      'utilisateurId': instance.utilisateurId,
      'ph': instance.ph,
      'humidite': instance.humidite,
      'temperature': instance.temperature,
      'conductivite': instance.conductivite,
      'azote': instance.azote,
      'phosphore': instance.phosphore,
      'potassium': instance.potassium,
      'observations': instance.observations,
      'dateAnalyse': instance.dateAnalyse.toIso8601String(),
      'dateCreation': instance.dateCreation.toIso8601String(),
      'parcelle': instance.parcelle,
      'recommandations': instance.recommandations,
    };
