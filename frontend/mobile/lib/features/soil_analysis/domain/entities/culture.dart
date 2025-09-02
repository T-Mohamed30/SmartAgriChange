class Culture {
  final String name;
  final double minPh;
  final double maxPh;
  final double minTemp;
  final double maxTemp;
  final double minHumidity;
  final double maxHumidity;
  final double minNitrogen;
  final double maxNitrogen;
  final double minPhosphorus;
  final double maxPhosphorus;
  final double minPotassium;
  final double maxPotassium;
  final String description;
  final String rendement;

  Culture({
    required this.name,
    required this.minPh,
    required this.maxPh,
    required this.minTemp,
    required this.maxTemp,
    required this.minHumidity,
    required this.maxHumidity,
    required this.minNitrogen,
    required this.maxNitrogen,
    required this.minPhosphorus,
    required this.maxPhosphorus,
    required this.minPotassium,
    required this.maxPotassium,
    required this.description,
    required this.rendement,
  });
}
