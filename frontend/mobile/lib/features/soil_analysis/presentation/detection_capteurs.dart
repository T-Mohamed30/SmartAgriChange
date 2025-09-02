import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/sensor.dart';
import 'providers/sensor_provider.dart';
import '../domain/entities/champ.dart';
import '../domain/entities/parcelle.dart';
import 'providers/champ_parcelle_provider.dart';
import 'widgets/sensor_card.dart';
import 'widgets/selector_card.dart';
import 'widgets/action_button.dart';
import 'analysis_screen.dart';

// Providers for selected champ and parcelle
final selectedChampProvider = StateProvider<Champ?>((ref) => null);
final selectedParcelleProvider = StateProvider<Parcelle?>((ref) => null);

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
          const Text('Prêt à analyser', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Appuyez sur le bouton pour commencer la recherche de capteurs.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Recherche en cours...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007F3D))),
          const SizedBox(height: 24),
          const Text('Recherche de capteurs dans votre zone.\nAssurez-vous que vos capteurs sont allumés.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildFoundState() {
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
          const Text('Aucun capteur détecté', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Vérifiez que vos capteurs sont allumés et à proximité.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 32),
          ActionButton(
            text: 'Actualiser',
            onPressed: () => ref.read(sensorActionsProvider.notifier).startSensorDetection(),
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
          const Text('Erreur de détection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Une erreur s\'est produite lors de la recherche de capteurs.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 32),
          ActionButton(
            text: 'Réessayer',
            onPressed: () => ref.read(sensorActionsProvider.notifier).startSensorDetection(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final selectedSensor = ref.watch(selectedSensorProvider);
    final selectedChamp = ref.watch(selectedChampProvider);
    final selectedParcelle = ref.watch(selectedParcelleProvider);
    final canLaunch = selectedSensor != null && (selectedChamp == null || selectedParcelle != null);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ActionButton(
        text: "Lancer l'analyse",
        onPressed: canLaunch
            ? () {
                ref.read(sensorActionsProvider.notifier).startAnalysis(
                      sensorId: selectedSensor!.id,
                      parcelleId: selectedParcelle?.id,
                    );
                Navigator.pushNamed(
                  context,
                  '/soil_analysis/analysis',
                  arguments: AnalysisArgs(
                    sensorId: selectedSensor!.id,
                    sensorName: selectedSensor!.name,
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

  Widget _buildParcelleSelector(BuildContext context, Parcelle? selectedParcelle) {
    return SelectorCard(
      title: 'Parcelle',
      label: selectedParcelle?.name ?? 'Choisir une parcelle',
      onTap: () {
        final selectedChamp = ref.read(selectedChampProvider);
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Capteurs sélectionnés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Capteurs disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
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
                  highlighted: selectedSensor?.id == sensor.id,
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
        error: (e, s) => const Center(child: Text('Erreur de chargement des champs')),
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
                parcellesAsync.when(
                  data: (parcelles) => Text('parcelles: ${parcelles.length}', style: const TextStyle(color: Colors.black54)),
                  loading: () => const Text('parcelles: ...', style: TextStyle(color: Colors.black54)),
                  error: (e, _) => const Text('parcelles: ?', style: TextStyle(color: Colors.black54)),
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
        error: (e, s) => const Center(child: Text('Erreur de chargement des parcelles')),
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
            Text('superficie: ${parcelle.superficie} ha', style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class CreateChampBottomSheet extends ConsumerStatefulWidget {
  const CreateChampBottomSheet({super.key});
  @override
  ConsumerState<CreateChampBottomSheet> createState() => _CreateChampBottomSheetState();
}

class _CreateChampBottomSheetState extends ConsumerState<CreateChampBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveChamp() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final location = _locationController.text;
      await ref.read(createChampProvider({'name': name, 'location': location}).future);
      ref.refresh(champsProvider);
      if (mounted) Navigator.pop(context);
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
              validator: (v) => (v == null || v.isEmpty) ? 'Veuillez entrer un nom' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: _inputDecoration('Localité'),
              validator: (v) => (v == null || v.isEmpty) ? 'Veuillez entrer une localité' : null,
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
  ConsumerState<CreateParcelleBottomSheet> createState() => _CreateParcelleBottomSheetState();
}

class _CreateParcelleBottomSheetState extends ConsumerState<CreateParcelleBottomSheet> {
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
      await ref.read(createParcelleProvider({
        'name': name,
        'superficie': superficie,
        'champId': widget.champId,
      }).future);
      ref.refresh(parcellesProvider(widget.champId));
      if (mounted) Navigator.pop(context);
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
              validator: (v) => (v == null || v.isEmpty) ? 'Veuillez entrer un nom' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _superficieController,
              decoration: _inputDecoration('Superficie (ha)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null) ? 'Veuillez entrer un nombre valide' : null,
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
                  width: 100, height: 5, 
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomInset > 0 ? bottomInset + 16 : 24),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
