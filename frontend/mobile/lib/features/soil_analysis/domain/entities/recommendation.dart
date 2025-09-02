import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/culture.dart';

class Recommendation {
  final Culture culture;
  final double compatibilityScore;
  final String explanation;
  final List<String> correctiveActions;

  Recommendation({
    required this.culture,
    required this.compatibilityScore,
    required this.explanation,
    required this.correctiveActions,
  });
}
