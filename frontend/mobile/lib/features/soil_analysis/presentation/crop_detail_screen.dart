import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/champ.dart';
import '../domain/entities/parcelle.dart';
import '../application/analysis_service.dart' show soilDataProvider, analysisServiceProvider;
import 'providers/champ_parcelle_provider.dart';
import 'providers/selection_providers.dart' as selection_providers;
import 'widgets/selector_card.dart';
import 'widgets/action_button.dart';
import 'detection_capteurs.dart' as detection_capteurs;

class CropDetailScreen extends ConsumerWidget {
  const CropDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropName =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Culture';
    final percentage = 87; // Example percentage, this should come from data
    final recommendation =
        "Nous recommandons la $cropName car votre sol est bien adapté. Vous pourriez obtenir jusqu'à 18 t/ha.";

    final conditions =
        _conditionsByCrop[cropName.toLowerCase()] ?? _defaultConditions;

    // Get soil data from provider
    final soilData = ref.watch(soilDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cropName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '($percentage%)',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ActionButton(
                        text: 'Générer un calendrier agricole',
                        onPressed: () {
                          _showCalendarBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ExpansionTile(
                        title: const Text(
                          'Résultats',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        children: [
                          const Divider(height: 1, thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              children: [
                                _resultRow(
                                  'assets/icons/renewable-energy 1.png',
                                  'Conductivité',
                                  soilData != null ? '${soilData.ec.toStringAsFixed(1)} us/cm' : '0 us/cm',
                                ),
                                const SizedBox(height: 16),
                                _resultRow(
                                  'assets/icons/celsius 1.png',
                                  'Température',
                                  soilData != null ? '${soilData.temperature.toStringAsFixed(1)} °C' : '0 °C',
                                ),
                                const SizedBox(height: 16),
                                _resultRow(
                                  'assets/icons/humidity 1.png',
                                  'Humidité',
                                  soilData != null ? '${soilData.humidity.toStringAsFixed(1)} %' : '0 %',
                                ),
                                const SizedBox(height: 16),
                                _resultRow('assets/icons/ph.png', 'PH', soilData != null ? soilData.ph.toStringAsFixed(1) : '0'),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/npk-illustration.png',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Nutriments',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _nutrientColumn('Azote (N)', soilData != null ? '${soilData.nitrogen.toStringAsFixed(0)} mg/kg' : '0 mg/kg'),
                                    _nutrientColumn('Phosphore (P)', soilData != null ? '${soilData.phosphorus.toStringAsFixed(0)} mg/kg' : '0 mg/kg'),
                                    _nutrientColumn('Potassium (K)', soilData != null ? '${soilData.potassium.toStringAsFixed(0)} mg/kg' : '0 mg/kg'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ExpansionTile(
                        title: const Text(
                          'Conditions idéales',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        children: [
                          const Divider(height: 1, thickness: 1),
                          _condRow('Azote', conditions.nRange, 'mg/kg'),
                          _condRow('Phosphore', conditions.pRange, 'mg/kg'),
                          _condRow('Potassium', conditions.kRange, 'mg/kg'),
                          _condRow('Température', conditions.tempRange, '°C'),
                          _condRow('Humidité', conditions.humRange, '%'),
                          _condRow('PH', conditions.phRange, ''),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ExpansionTile(
                        title: const Text(
                          'Actions recommandées',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        children: [
                          const Divider(height: 1, thickness: 1),
                          Builder(
                            builder: (context) {
                              final soilData = ref.watch(soilDataProvider);
                              if (soilData == null) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Aucune recommandation disponible.'),
                                );
                              }
                              final recommendations = ref.read(analysisServiceProvider).generateSoilRecommendations(soilData);
                              if (recommendations.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Aucune recommandation nécessaire.'),
                                );
                              }
                              return Column(
                                children: recommendations.map((rec) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: _priorityCard(
                                      'Priorité',
                                      rec,
                                      Colors.orange.shade100,
                                      Colors.orange,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCalendarBottomSheet(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.calendar_today_outlined),
      ),
    );
  }

  Widget _resultRow(String asset, String label, String value) {
    return Row(
      children: [
        Image.asset(asset, width: 24, height: 24, fit: BoxFit.contain),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _nutrientColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _condRow(String label, String range, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            unit.isEmpty ? range : '$range $unit',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _priorityCard(
    String title,
    String message,
    Color bgColor,
    Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: borderColor, width: 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: borderColor),
          ),
          const SizedBox(height: 4),
          Text(message),
        ],
      ),
    );
  }

  void _showCalendarBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const _CalendarBottomSheet();
      },
    );
  }
}

class _CalendarBottomSheet extends ConsumerWidget {
  const _CalendarBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChamp = ref.watch(selection_providers.selectedChampProvider);
    final selectedParcelle = ref.watch(
      selection_providers.selectedParcelleProvider,
    );
    final selectedDate = ref.watch(selection_providers.selectedDateProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Générer un calendrier agricole',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      // TODO: Implement help action
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SelectorCard(
                title: 'Champs',
                label: selectedChamp != null
                    ? selectedChamp.name
                    : 'Choisir un champ',
                isSelected: selectedChamp != null,
                onTap: () => _showChampSelectionSheet(context, ref),
                onRemove: selectedChamp != null
                    ? () {
                        ref
                                .read(
                                  selection_providers
                                      .selectedChampProvider
                                      .notifier,
                                )
                                .state =
                            null;
                        ref
                                .read(
                                  selection_providers
                                      .selectedParcelleProvider
                                      .notifier,
                                )
                                .state =
                            null;
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              SelectorCard(
                title: 'Parcelles',
                label: selectedParcelle != null
                    ? selectedParcelle.name
                    : 'Choisir une parcelle',
                isSelected: selectedParcelle != null,
                onTap: () => _showParcelleSelectionSheet(context, ref),
                onRemove: selectedParcelle != null
                    ? () {
                        ref
                                .read(
                                  selection_providers
                                      .selectedParcelleProvider
                                      .notifier,
                                )
                                .state =
                            null;
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final selectedDate = ref.watch(
                    selection_providers.selectedDateProvider,
                  );
                  return DateSelectorCard(
                    title: 'Date de début',
                    selectedDate: selectedDate,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        ref
                                .read(
                                  selection_providers
                                      .selectedDateProvider
                                      .notifier,
                                )
                                .state =
                            pickedDate;
                      }
                    },
                    onRemove: selectedDate != null
                        ? () {
                            ref
                                    .read(
                                      selection_providers
                                          .selectedDateProvider
                                          .notifier,
                                    )
                                    .state =
                                null;
                          }
                        : null,
                  );
                },
              ),
              const SizedBox(height: 8),
              ActionButton(
                text: 'Générer',
                onPressed: () {
                  // Close the sheet and navigate to the calendar screen
                  Navigator.pop(context);
                  final cropName =
                      (ModalRoute.of(context)?.settings.arguments as String?) ??
                      'Culture';
                  Navigator.pushNamed(
                    context,
                    '/soil_analysis/calendar',
                    arguments: {'cropName': cropName},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChampSelectionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ChampSelectionSheet(),
    );
  }

  void _showParcelleSelectionSheet(BuildContext context, WidgetRef ref) {
    final selectedChamp = ref.read(selection_providers.selectedChampProvider);
    if (selectedChamp != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ParcelleSelectionSheet(champ: selectedChamp),
      );
    }
  }
}

class _ChampSelectionSheet extends ConsumerWidget {
  const _ChampSelectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final champsAsync = ref.watch(champsProvider);
    return _ModalSheet(
      title: 'Liste des champs',
      body: champsAsync.when(
        data: (champs) => ListView.separated(
          itemCount: champs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final champ = champs[index];
            return _ChampCard(champ: champ);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            const Center(child: Text('Erreur de chargement des champs')),
      ),
      actionButton: ActionButton(
        text: 'Créer un champ',
        onPressed: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const detection_capteurs.CreateChampBottomSheet(),
          );
        },
      ),
    );
  }
}

class _ChampCard extends ConsumerWidget {
  const _ChampCard({required this.champ});
  final Champ champ;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcellesAsync = ref.watch(parcellesProvider(champ.id));
    return InkWell(
      onTap: () {
        ref.read(selection_providers.selectedChampProvider.notifier).state =
            champ;
        ref.read(selection_providers.selectedParcelleProvider.notifier).state =
            null;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              champ.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'localité: ${champ.location}',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 16),
                parcellesAsync.when(
                  data: (parcelles) => Text(
                    'parcelles: ${parcelles.length}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  loading: () => const Text(
                    'parcelles: ...',
                    style: TextStyle(color: Colors.black54),
                  ),
                  error: (e, _) => const Text(
                    'parcelles: ?',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ParcelleSelectionSheet extends ConsumerWidget {
  final Champ champ;
  const _ParcelleSelectionSheet({required this.champ});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcellesAsync = ref.watch(parcellesProvider(champ.id));
    return _ModalSheet(
      title: 'Liste des parcelles de ${champ.name}',
      body: parcellesAsync.when(
        data: (parcelles) => ListView.separated(
          itemCount: parcelles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final parcelle = parcelles[index];
            return _ParcelleCard(parcelle: parcelle);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            const Center(child: Text('Erreur de chargement des parcelles')),
      ),
      actionButton: ActionButton(
        text: 'Créer une parcelle',
        onPressed: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) =>
                detection_capteurs.CreateParcelleBottomSheet(champId: champ.id),
          );
        },
      ),
    );
  }
}

class _ParcelleCard extends ConsumerWidget {
  const _ParcelleCard({required this.parcelle});
  final Parcelle parcelle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(selection_providers.selectedParcelleProvider.notifier).state =
            parcelle;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parcelle.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'superficie: ${parcelle.superficie} ha',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Reusable Sheet Widgets ---

class _ModalSheet extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget actionButton;

  const _ModalSheet({
    required this.title,
    required this.body,
    required this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: body),
              const SizedBox(height: 12),
              actionButton,
            ],
          ),
        ),
      ),
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
