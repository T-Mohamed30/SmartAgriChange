import 'package:flutter/material.dart';

class CropDetailScreen extends StatelessWidget {
  const CropDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cropName = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Culture';

    final conditions = _conditionsByCrop[cropName.toLowerCase()] ?? _defaultConditions;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(cropName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.eco_outlined, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Conditions idéales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                _condRow('Azote (N)', conditions.nRange, 'mg/kg'),
                const SizedBox(height: 10),
                _condRow('Phosphore (P)', conditions.pRange, 'mg/kg'),
                const SizedBox(height: 10),
                _condRow('Potassium (K)', conditions.kRange, 'mg/kg'),
                const SizedBox(height: 10),
                _condRow('Température', conditions.tempRange, '°C'),
                const SizedBox(height: 10),
                _condRow('Humidité', conditions.humRange, '%'),
                const SizedBox(height: 10),
                _condRow('pH', conditions.phRange, ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _condRow(String label, String range, String unit) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        Text(
          unit.isEmpty ? range : '$range $unit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class CropConditions {
  final String nRange;
  final String pRange;
  final String kRange;
  final String tempRange;
  final String humRange;
  final String phRange;
  const CropConditions({
    required this.nRange,
    required this.pRange,
    required this.kRange,
    required this.tempRange,
    required this.humRange,
    required this.phRange,
  });
}

const _defaultConditions = CropConditions(
  nRange: '—',
  pRange: '—',
  kRange: '—',
  tempRange: '—',
  humRange: '—',
  phRange: '—',
);

final Map<String, CropConditions> _conditionsByCrop = {
  'tomate': const CropConditions(
    nRange: '80 – 150',
    pRange: '30 – 60',
    kRange: '150 – 250',
    tempRange: '18 – 27',
    humRange: '60 – 80',
    phRange: '6.0 – 6.8',
  ),
  'riz': const CropConditions(
    nRange: '50 – 120',
    pRange: '25 – 50',
    kRange: '100 – 200',
    tempRange: '18 – 30',
    humRange: '50 – 70',
    phRange: '5.8 –7.0',
  ),
  'sésame': const CropConditions(
    nRange: '60 – 120',
    pRange: '20 – 45',
    kRange: '80 – 160',
    tempRange: '20 – 30',
    humRange: '60 – 90',
    phRange: '5.5 – 7.0',
  ),
  'maïs': const CropConditions(
    nRange: '40 – 100',
    pRange: '20 – 40',
    kRange: '80 – 150',
    tempRange: '12 – 25',
    humRange: '40 – 60',
    phRange: '6.0 – 7.5',
  ),
  'soja': const CropConditions(
    nRange: '40 – 80',
    pRange: '20 – 40',
    kRange: '80 – 140',
    tempRange: '20 – 30',
    humRange: '60 – 80',
    phRange: '6.0 – 7.0',
  ),
  'arachide': const CropConditions(
    nRange: '30 – 70',
    pRange: '20 – 40',
    kRange: '80 – 140',
    tempRange: '22 – 30',
    humRange: '50 – 70',
    phRange: '5.5 – 7.0',
  ),
};
