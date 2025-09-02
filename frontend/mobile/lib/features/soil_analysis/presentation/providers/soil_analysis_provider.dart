import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/analyse_sol.dart';

// Provider to fetch the details of a specific analysis by its ID
final analyseDetailProvider = FutureProvider.family<AnalyseSol, String>((ref, id) async {
  // Simulate an API call to get analysis details
  await Future.delayed(const Duration(milliseconds: 500));

  // This is mock data. In a real application, you would fetch this from your backend.
  final mockData = {
    'id': id,
    'culture': 'Maïs',
    'parcelle': 'Parcelle 3',
    'date': DateTime.now().toIso8601String(),
    'recommendations': [
      'Ajouter 50 kg/ha d\'engrais NPK (15-15-15) avant le semis.',
      'Maintenir une humidité du sol entre 60% et 70% pendant la phase de croissance.',
      'Effectuer un désherbage manuel 3 semaines après le semis.',
      'Surveiller l\'apparition de la chenille légionnaire.'
    ],
    'nutriments': {
      'N': {'value': 120.5, 'unit': 'ppm', 'level': 'Optimal'},
      'P': {'value': 45.2, 'unit': 'ppm', 'level': 'Moyen'},
      'K': {'value': 88.0, 'unit': 'ppm', 'level': 'Bas'},
      'pH': {'value': 6.8, 'unit': '', 'level': 'Optimal'},
    }
  };

  return AnalyseSol.fromJson(mockData);
});
