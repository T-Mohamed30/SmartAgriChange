import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/sensor.dart';
// import '../domain/entities/champ.dart'; // Supposons que tu aies créé ces entités
// import '../domain/entities/parcelle.dart';
import 'providers/sensor_provider.dart';
import '../domain/entities/champ.dart';
import '../domain/entities/parcelle.dart';
import 'widgets/sensor_card.dart';
import 'widgets/selector_card.dart';
import 'widgets/action_button.dart';
import 'analysis_screen.dart';



// Mock providers pour la démonstration
final selectedChampProvider = StateProvider<Champ?>((ref) => null);
final selectedParcelleProvider = StateProvider<Parcelle?>((ref) => null);

// Données fictives pour la démonstration
final List<Champ> mockChamps = [
  Champ(id: 'c1', name: 'Champ A', location: 'Localité 1'),
  Champ(id: 'c2', name: 'Champ B', location: 'Localité 2'),
];

final List<Parcelle> mockParcelles = [
  Parcelle(id: 'p1', name: 'Parcelle 1', superficie: 5.2, champId: 'c1'),
  Parcelle(id: 'p2', name: 'Parcelle 2', superficie: 3.1, champId: 'c1'),
  Parcelle(id: 'p3', name: 'Parcelle 3', superficie: 7.8, champId: 'c2'),
];

class DetectionCapteursPage extends ConsumerStatefulWidget {
  const DetectionCapteursPage({super.key});

  @override
  ConsumerState<DetectionCapteursPage> createState() => _DetectionCapteursPageState();
}

class _DetectionCapteursPageState extends ConsumerState<DetectionCapteursPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sensorActionsProvider.notifier).startSensorDetection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final detectionState = ref.watch(detectionStateProvider);
    final selectedChamp = ref.watch(selectedChampProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Analyse du sol'),
        foregroundColor: Colors.black,
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (detectionState != SensorDetectionState.found) ...[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Image.asset(
                    'assets/images/detection_capteurs.png',
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            _buildContent(detectionState, selectedChamp),
          ],
        ),
      ),
      bottomNavigationBar: detectionState == SensorDetectionState.found
          ? _buildBottomButton()
          : null,
    );
  }

  Widget _buildContent(SensorDetectionState state, Champ? selectedChamp) {
    switch (state) {
      case SensorDetectionState.idle:
        return _buildIdleState();
      case SensorDetectionState.searching:
        return _buildSearchingState();
      case SensorDetectionState.found:
        return _buildFoundState();
      case SensorDetectionState.notFound:
        return _buildNotFoundState();
      case SensorDetectionState.error:
        return _buildErrorState();
    }
  }

  Widget _buildIdleState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Prêt à analyser',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Appuyez sur le bouton pour commencer la recherche de capteurs.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ActionButton(
            text: 'Démarrer la détection',
            onPressed: () => ref.read(sensorActionsProvider.notifier).startSensorDetection(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Recherche en cours...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007F3D)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recherche de capteurs dans votre zone.\nAssurez-vous que vos capteurs sont allumés.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildFoundState() {
    return Consumer(
      builder: (context, ref, child) {
        final sensorsAsync = ref.watch(detectedSensorsStreamProvider);
        final selectedChamp = ref.watch(selectedChampProvider);
        final selectedParcelle = ref.watch(selectedParcelleProvider);

        return sensorsAsync.when(
          data: (sensors) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChampSelector(context, selectedChamp),
                if (selectedChamp != null) ...[
                  const SizedBox(height: 16),
                  _buildParcelleSelector(context, selectedParcelle),
                ],
                const SizedBox(height: 24),
                _buildSelectedSensorsSection(ref),
                const SizedBox(height: 24),
                _buildDetectedSensorsList(ref, sensors),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(),
        );
      },
    );
  }

  Widget _buildNotFoundState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.sensors_off,
            size: 64,
            color: Colors.orange.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun capteur détecté',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vérifiez que vos capteurs sont allumés et à proximité.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ActionButton(
            text: 'Actualiser',
            onPressed: () => ref.read(sensorActionsProvider.notifier).startSensorDetection(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Erreur de détection',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Une erreur s\'est produite lors de la recherche de capteurs.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ActionButton(
            text: 'Réessayer',
            onPressed: () => ref.read(sensorActionsProvider.notifier).startSensorDetection(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  
  Widget _buildBottomButton() {
    final selected = ref.watch(selectedSensorProvider);
    final champ = ref.watch(selectedChampProvider);
    final parcelle = ref.watch(selectedParcelleProvider);
    final canLaunch = selected != null && (champ == null || parcelle != null);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: canLaunch
              ? () {
                  ref.read(sensorActionsProvider.notifier).startAnalysis(
                        sensorId: selected!.id,
                        parcelleId: parcelle?.id,
                      );
                  Navigator.pushNamed(
                    context,
                    '/soil_analysis/analysis',
                    arguments: AnalysisArgs(
                      sensorId: selected.id,
                      sensorName: selected.name,
                      champName: champ?.name,
                      parcelleName: parcelle?.name,
                    ),
                  );
                }
              : null,
          child: const Text("Lancer l'analyse"),
        ),
      ),
    );
  }

  Widget _buildChampSelector(BuildContext context, Champ? selectedChamp) {
    return SelectorCard(
      title: 'Champ',
      label: selectedChamp?.name ?? 'Choisir un champ',
      onTap: () => _showChampSelectionSheet(context),
    );
  }

  void _showChampSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _ChampSelectionSheet();
      },
    );
  }

  void _showParcelleSelectionSheet(BuildContext context, Champ champ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _ParcelleSelectionSheet(champ: champ);
      },
    );
  }

  Widget _buildParcelleSelector(BuildContext context, Parcelle? selectedParcelle) {
    return Row(
      children: [
        Expanded(
          child: SelectorCard(
            title: 'Parcelle',
            label: selectedParcelle?.name ?? 'Choisir une parcelle',
            onTap: () {
              final selectedChamp = ref.read(selectedChampProvider);
              if (selectedChamp != null) {
                _showParcelleSelectionSheet(context, selectedChamp);
              }
            },
          ),
        ),
        if (selectedParcelle != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(selectedParcelleProvider.notifier).state = null;
            },
          ),
      ],
    );
  }

  Widget _buildSelectedSensorsSection(WidgetRef ref) {
    final selected = ref.watch(selectedSensorProvider);
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capteurs sélectionnés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (selected == null)
              const Text('Aucun capteur sélectionné')
            else
              SensorCard(sensor: selected, highlighted: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedSensorsList(WidgetRef ref, List<Sensor> sensors) {
    final selected = ref.watch(selectedSensorProvider);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Capteurs disponibles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualiser',
                onPressed: () => ref.read(sensorActionsProvider.notifier).startSensorDetection(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: ListView.separated(
              itemCount: sensors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                return SensorCard(
                  sensor: sensor,
                  highlighted: selected?.id == sensor.id,
                  onTap: () => ref.read(sensorActionsProvider.notifier).selectSensor(sensor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  }

// Widgets pour la sélection de champ et de parcelle
// Tu peux les placer dans des fichiers séparés pour une meilleure organisation

class _ChampSelectionSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final champs = mockChamps;

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
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Liste des champs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: champs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final champ = champs[index];
                    final parcelles = mockParcelles.where((p) => p.champId == champ.id).toList();
                                        final nbParcelles = parcelles.length;

                    return InkWell(
                      onTap: () {
                        ref.read(selectedChampProvider.notifier).state = champ;
                        ref.read(selectedParcelleProvider.notifier).state = null;
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(champ.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('localité: ${champ.location}', style: const TextStyle(color: Colors.black54)),
                                const SizedBox(width: 16),
                                Text('parcelle: $nbParcelles', style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                text: 'Créer un champ',
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const CreateChampBottomSheet(),
                  );
                },
              ),
            ],
          ),
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
    final parcellesPourChamp = mockParcelles.where((p) => p.champId == champ.id).toList();

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
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Liste des parcelles de ${champ.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: parcellesPourChamp.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final parcelle = parcellesPourChamp[index];
                    return InkWell(
                      onTap: () {
                        ref.read(selectedParcelleProvider.notifier).state = parcelle;
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(parcelle.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('superficie: ${parcelle.superficie} ha', style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                text: 'Créer une parcelle',
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => CreateParcelleBottomSheet(champId: champ.id),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Formulaire pour la création d'un nouveau champ (bottom sheet)
class CreateChampBottomSheet extends StatefulWidget {
  const CreateChampBottomSheet({Key? key}) : super(key: key);
  @override
  State<CreateChampBottomSheet> createState() => _CreateChampBottomSheetState();
}

class _CreateChampBottomSheetState extends State<CreateChampBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveChamp() {
    if (_formKey.currentState!.validate()) {
      final newChamp = Champ(
        id: DateTime.now().toString(),
        name: _nameController.text,
        location: _locationController.text,
      );
      mockChamps.add(newChamp);
      Navigator.pop(context);
    }
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF007F3D)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = bottomInset > 0 ? bottomInset + 16.0 : 24.0;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomPadding),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
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
              const Text('Créer un champ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _dec('Nom du champ'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un nom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: _dec('Localité'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une localité';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ActionButton(text: 'Enregistrer', onPressed: _saveChamp),
            ],
          ),
        ),
      ),
    );
  }
}

// Formulaire pour la création d'une nouvelle parcelle (bottom sheet)
class CreateParcelleBottomSheet extends StatefulWidget {
  final String champId;
  const CreateParcelleBottomSheet({required this.champId, Key? key}) : super(key: key);

  @override
  State<CreateParcelleBottomSheet> createState() => _CreateParcelleBottomSheetState();
}

class _CreateParcelleBottomSheetState extends State<CreateParcelleBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _superficieController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _superficieController.dispose();
    super.dispose();
  }

  void _saveParcelle() {
    if (_formKey.currentState!.validate()) {
      final newParcelle = Parcelle(
        id: DateTime.now().toString(),
        name: _nameController.text,
        superficie: double.tryParse(_superficieController.text) ?? 0.0,
        champId: widget.champId,
      );
      mockParcelles.add(newParcelle);
      Navigator.pop(context);
    }
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF007F3D)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = bottomInset > 0 ? bottomInset + 16.0 : 24.0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomPadding),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
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
              const Text('Créer une parcelle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _dec('Nom de la parcelle'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un nom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _superficieController,
                          decoration: _dec('Superficie (en ha)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty || double.tryParse(value) == null) {
                              return 'Veuillez entrer une superficie valide';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ActionButton(text: 'Enregistrer', onPressed: _saveParcelle),
            ],
          ),
        ),
      ),
    );
  }
}