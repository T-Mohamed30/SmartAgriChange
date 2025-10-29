import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/sensor.dart';
import 'providers/sensor_provider.dart';
import '../domain/entities/champ.dart';
import '../domain/entities/parcelle.dart';
import 'providers/champ_parcelle_provider.dart';
import 'providers/selection_providers.dart' as selection_providers;
import 'widgets/sensor_card.dart';
import 'widgets/selector_card.dart';
import 'widgets/action_button.dart';
import 'widgets/map_picker.dart';
import 'analysis_screen.dart';

class DetectionCapteursPage extends ConsumerStatefulWidget {
  const DetectionCapteursPage({super.key});

  @override
  ConsumerState<DetectionCapteursPage> createState() =>
      _DetectionCapteursPageState();
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Analyse du sol'),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (detectionState != SensorDetectionState.found)
              _buildHeaderImage(context),
            _buildContent(detectionState),
          ],
        ),
      ),
      bottomNavigationBar: detectionState == SensorDetectionState.found
          ? _buildBottomButton()
          : null,
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Image.asset(
          'assets/images/detection_capteurs.png',
          width: MediaQuery.of(context).size.width * 0.8,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildContent(SensorDetectionState state) {
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
    return Padding(
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
            onPressed: () =>
                ref.read(sensorActionsProvider.notifier).startSensorDetection(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingState() {
    return Padding(
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
          const SizedBox(height: 32),
          ActionButton(
            text: 'Annuler la recherche',
            onPressed: () {
              ref.read(detectionStateProvider.notifier).state =
                  SensorDetectionState.notFound;
            },
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildFoundState() {
    final sensorsAsync = ref.watch(detectedSensorsStreamProvider);
    final selectedChamp = ref.watch(selection_providers.selectedChampProvider);
    final selectedParcelle = ref.watch(
      selection_providers.selectedParcelleProvider,
    );

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
            _buildSelectedSensorsSection(),
            const SizedBox(height: 24),
            _buildDetectedSensorsList(sensors),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(),
    );
  }

  Widget _buildNotFoundState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.sensors_off, size: 64, color: Colors.orange.shade400),
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
            onPressed: () =>
                ref.read(sensorActionsProvider.notifier).startSensorDetection(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
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
            onPressed: () =>
                ref.read(sensorActionsProvider.notifier).startSensorDetection(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final selectedSensor = ref.watch(selectedSensorProvider);
    final selectedChamp = ref.watch(selection_providers.selectedChampProvider);
    final selectedParcelle = ref.watch(
      selection_providers.selectedParcelleProvider,
    );
    final canLaunch =
        selectedSensor != null &&
        (selectedChamp == null || selectedParcelle != null);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ActionButton(
        text: "Lancer l'analyse",
        onPressed: canLaunch
            ? () {
                ref
                    .read(sensorActionsProvider.notifier)
                    .startAnalysis(
                      sensorId: selectedSensor.id,
                      parcelleId: selectedParcelle?.id,
                    );
                Navigator.pushNamed(
                  context,
                  '/soil_analysis/analysis',
                  arguments: AnalysisArgs(
                    sensorName: selectedSensor.name,
                    champName: selectedChamp?.name,
                    parcelleName: selectedParcelle?.name,
                  ),
                );
              }
            : null, // ⚠️ onPressed = null si canLaunch = false
      ),
    );
  }

  Widget _buildChampSelector(BuildContext context, Champ? selectedChamp) {
    return SelectorCard(
      title: 'Champ',
      label: selectedChamp?.name ?? 'Choisir un champ',
      isSelected: selectedChamp != null,
      onRemove: selectedChamp != null
          ? () =>
                ref
                        .read(
                          selection_providers.selectedChampProvider.notifier,
                        )
                        .state =
                    null
          : null,
      onTap: () => _showChampSelectionSheet(context),
    );
  }

  void _showChampSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ChampSelectionSheet(),
    );
  }

  Widget _buildParcelleSelector(
    BuildContext context,
    Parcelle? selectedParcelle,
  ) {
    return SelectorCard(
      title: 'Parcelle',
      label: selectedParcelle?.name ?? 'Choisir une parcelle',
      isSelected: selectedParcelle != null,
      onRemove: selectedParcelle != null
          ? () =>
                ref
                        .read(
                          selection_providers.selectedParcelleProvider.notifier,
                        )
                        .state =
                    null
          : null,
      onTap: () {
        final selectedChamp = ref.read(
          selection_providers.selectedChampProvider,
        );
        if (selectedChamp != null) {
          _showParcelleSelectionSheet(context, selectedChamp);
        }
      },
    );
  }

  void _showParcelleSelectionSheet(BuildContext context, Champ champ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ParcelleSelectionSheet(champ: champ),
    );
  }

  Widget _buildSelectedSensorsSection() {
    final selectedSensor = ref.watch(selectedSensorProvider);
    return Container(
      width: double.infinity,
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
          const Text(
            'Capteurs sélectionnés',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          selectedSensor == null
              ? const Text('Aucun capteur sélectionné')
              : SensorCard(sensor: selectedSensor, highlighted: true),
        ],
      ),
    );
  }

  Widget _buildDetectedSensorsList(List<Sensor> sensors) {
    final selectedSensor = ref.watch(selectedSensorProvider);
    return Container(
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
                onPressed: () => ref
                    .read(sensorActionsProvider.notifier)
                    .startSensorDetection(),
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
                  highlighted: selectedSensor?.id == sensor.id,
                  onTap: () => ref
                      .read(sensorActionsProvider.notifier)
                      .selectSensor(sensor),
                );
              },
            ),
          ),
        ],
      ),
    );
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
        data: (champs) => champs.isEmpty
            ? const Center(
                child: Text(
                  'Il n\'y a pas encore de champs enregistrés',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
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
            builder: (_) => const CreateChampBottomSheet(),
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
                  'localité: ${champ.latitude?.toStringAsFixed(4) ?? 'N/A'}, ${champ.longitude?.toStringAsFixed(4) ?? 'N/A'}',
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
        data: (parcelles) => parcelles.isEmpty
            ? const Center(
                child: Text(
                  'Il n\'y a pas encore de parcelles enregistrées',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
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
            builder: (_) => CreateParcelleBottomSheet(champId: champ.id),
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

class CreateChampBottomSheet extends ConsumerStatefulWidget {
  const CreateChampBottomSheet({super.key});
  @override
  ConsumerState<CreateChampBottomSheet> createState() =>
      _CreateChampBottomSheetState();
}

class _CreateChampBottomSheetState
    extends ConsumerState<CreateChampBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _superficieController = TextEditingController();
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void dispose() {
    _nameController.dispose();
    _superficieController.dispose();
    super.dispose();
  }

  void _onLocationSelected(double latitude, double longitude) {
    setState(() {
      _selectedLatitude = latitude;
      _selectedLongitude = longitude;
    });
  }

  void _saveChamp() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLatitude == null || _selectedLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un emplacement sur la carte'),
          ),
        );
        return;
      }

      final name = _nameController.text;
      final superficie = double.tryParse(_superficieController.text) ?? 0.0;
      try {
        await ref.read(
          createChampProvider({
            'name': name,
            'location': '',
            'latitude': _selectedLatitude,
            'longitude': _selectedLongitude,
            'area': superficie,
          }).future,
        );
        ref.refresh(champsProvider);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        debugPrint('DetectionCapteursPage: Error creating champ $name: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la création du champ: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Créer un champ',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Nom du champ'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Veuillez entrer un nom' : null,
            ),
            const SizedBox(height: 16),
            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MapPicker(onLocationSelected: _onLocationSelected),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _superficieController,
              decoration: _inputDecoration('Superficie (ha)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  (v == null || v.isEmpty || double.tryParse(v) == null)
                  ? 'Veuillez entrer un nombre valide'
                  : null,
            ),
          ],
        ),
      ),
      onSave: _saveChamp,
    );
  }
}

class CreateParcelleBottomSheet extends ConsumerStatefulWidget {
  final String champId;
  const CreateParcelleBottomSheet({required this.champId, super.key});

  @override
  ConsumerState<CreateParcelleBottomSheet> createState() =>
      _CreateParcelleBottomSheetState();
}

class _CreateParcelleBottomSheetState
    extends ConsumerState<CreateParcelleBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _superficieController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _superficieController.dispose();
    super.dispose();
  }

  void _saveParcelle() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final superficie = double.tryParse(_superficieController.text) ?? 0.0;
      try {
        await ref.read(
          createParcelleProvider({
            'name': name,
            'superficie': superficie,
            'champId': widget.champId,
          }).future,
        );
        ref.refresh(parcellesProvider(widget.champId));
        if (mounted) Navigator.pop(context);
      } catch (e) {
        debugPrint('DetectionCapteursPage: Error creating parcelle $name: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création de la parcelle: $e'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Créer une parcelle',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Nom de la parcelle'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Veuillez entrer un nom' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _superficieController,
              decoration: _inputDecoration('Superficie (ha)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.isEmpty || double.tryParse(v) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                final superficie = double.tryParse(v);
                if (superficie == null || superficie <= 0) {
                  return 'Veuillez entrer une superficie valide';
                }
                // Validation de la superficie totale des parcelles par rapport au champ
                final champs = ref.watch(champsProvider);
                final champ = champs.maybeWhen(
                  data: (champsList) => champsList.firstWhere(
                    (c) => c.id == widget.champId,
                    orElse: () => Champ(
                      id: '',
                      name: '',
                      latitude: 0.0,
                      longitude: 0.0,
                      superficie: 0.0,
                    ),
                  ),
                  orElse: () => null,
                );
                if (champ != null) {
                  final totalSuperficieParcelles = ref
                      .watch(parcellesProvider(widget.champId))
                      .maybeWhen(
                        data: (parcelles) => parcelles.fold<double>(
                          0,
                          (sum, p) => sum + p.superficie,
                        ),
                        orElse: () => 0,
                      );
                  final nouvelleSuperficieTotale =
                      totalSuperficieParcelles + superficie;
                  if (nouvelleSuperficieTotale > champ.superficie) {
                    // Show popup dialog
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Superficie dépassée'),
                            content: Text(
                              'La superficie totale des parcelles (${nouvelleSuperficieTotale.toStringAsFixed(2)} ha) ne peut pas dépasser celle du champ (${champ.superficie.toStringAsFixed(2)} ha).',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    });
                    return 'La superficie totale des parcelles (${nouvelleSuperficieTotale.toStringAsFixed(2)} ha) ne peut pas dépasser celle du champ (${champ.superficie.toStringAsFixed(2)} ha)';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
      onSave: _saveParcelle,
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

class _FormSheet extends StatelessWidget {
  final String title;
  final Form form;
  final VoidCallback onSave;

  const _FormSheet({
    required this.title,
    required this.form,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomInset > 0 ? bottomInset + 16 : 24,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
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
              Expanded(child: SingleChildScrollView(child: form)),
              const SizedBox(height: 20),
              ActionButton(text: 'Enregistrer', onPressed: onSave),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
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
