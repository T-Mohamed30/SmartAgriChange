import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/culture.dart';

class MockCultureDataSource {
  static final List<Culture> cultures = [
    Culture(
      name: 'Tomate',
      minPh: 6.0,
      maxPh: 6.8,
      minTemp: 21,
      maxTemp: 24,
      minHumidity: 65,
      maxHumidity: 85,
      minNitrogen: 100,
      maxNitrogen: 150,
      minPhosphorus: 80,
      maxPhosphorus: 120,
      minPotassium: 150,
      maxPotassium: 200,
      description: 'La tomate est une culture populaire qui nécessite un sol bien drainé et beaucoup de soleil.',
      rendement: 'Élevé',
    ),
    Culture(
      name: 'Maïs',
      minPh: 5.8,
      maxPh: 7.0,
      minTemp: 20,
      maxTemp: 30,
      minHumidity: 60,
      maxHumidity: 70,
      minNitrogen: 120,
      maxNitrogen: 180,
      minPhosphorus: 50,
      maxPhosphorus: 80,
      minPotassium: 100,
      maxPotassium: 150,
      description: 'Le maïs est une culture de base qui pousse bien dans les climats chauds.',
      rendement: 'Très élevé',
    ),
    // Ajoutez d'autres cultures ici
  ];
}
