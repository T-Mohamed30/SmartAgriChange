import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
// Assurez-vous que ce fichier existe et contient les définitions de Rubric, RubricInfo, et AnomalyAnalysisResponse
import 'package:smartagrichange_mobile/features/plant_analysis/models/anomaly_analysis_models.dart';

class PlantFullDetailPage extends StatefulWidget {
  final AnomalyAnalysisResponse? analysisResult;
  final Uint8List? imageBytes;
  final bool showHealthyMessage;

  const PlantFullDetailPage({
    super.key,
    this.analysisResult,
    this.imageBytes,
    this.showHealthyMessage = false,
  });

  @override
  State<PlantFullDetailPage> createState() => _PlantFullDetailPageState();
}

class _PlantFullDetailPageState extends State<PlantFullDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Exemple d'images — remplace par tes vraies images ou URLs
  final List<String> gallery = [
    'assets/images/mangue_1.png',
    'assets/images/mangue_2.png',
    'assets/images/mangue_3.png',
    'assets/images/mangue_4.png',
  ];

  @override
  void initState() {
    super.initState();
    // Le nombre de tabs est 1 (Fiche plante) + le nombre de rubriques
    final rubricsLength = widget.analysisResult?.plant.rubrics?.length ?? 0;
    _tabController = TabController(length: 1 + rubricsLength, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Widgets de construction de l'interface ---

  Widget _buildTopImage(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height * 0.38;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Image large
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: widget.imageBytes != null
              ? Image.memory(
                  widget.imageBytes!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/mango_leaf.jpg',
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset('assets/images/mango_leaf.jpg', fit: BoxFit.cover),
        ),

        // Dégradé en bas de l'image
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 72,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26],
              ),
            ),
          ),
        ),

        // Boutons superposés (retour & plein écran)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(
                  Icons.arrow_back,
                  onTap: () => Navigator.maybePop(context),
                ),
                _circleButton(
                  Icons.fullscreen,
                  onTap: () {
                    // action plein écran: ici placeholder
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plein écran (placeholder)'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final plant = widget.analysisResult?.plant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texte principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant?.nomCommun ?? 'Plante inconnue',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nom latin : ${plant?.nomScientifique ?? 'Non spécifié'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Message de santé si showHealthyMessage est true
          if (widget.showHealthyMessage) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Votre plante est en bonne santé',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardInfo() {
    final plant = widget.analysisResult?.plant;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Infos rapides
            InfoRow(
              label: 'Nom scientifique',
              value: plant?.nomScientifique ?? 'Non spécifié',
            ),
            const SizedBox(height: 8),
            InfoRow(
              label: 'Nom local',
              value: plant?.nomCommun ?? 'Plante inconnue',
            ),
            const SizedBox(height: 8),
            InfoRow(
              label: 'Famille botanique',
              value: plant?.familleBotanique ?? 'Non spécifiée',
            ),
            const SizedBox(height: 8),
            InfoRow(label: 'Type', value: plant?.type ?? 'Non spécifié'),
            const SizedBox(height: 8),
            InfoRow(
              label: 'Cycle de vie',
              value: plant?.cycleVie ?? 'Non spécifié',
            ),

            // Description détaillée
            if (plant?.description != null &&
                plant!.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const Divider(height: 16),
              Text(
                plant.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMorphology() {
    final List<String> items = [
      'Racines',
      'Feuilles',
      'Fleurs',
      'Fruits',
      'Tige',
      'Graines',
    ]; // Ajout d'exemples
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Morphologie',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              // Ajustement du ratio pour une meilleure lecture sur 3 colonnes
              childAspectRatio: 3.0,
              children: items
                  .map(
                    (e) => OutlinedButton(
                      onPressed: () => _showMorphologyDetail(e),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize:
                                    13, // Augmentation de la taille de la police
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showMorphologyDetail(String morphologyType) {
    final plant = widget.analysisResult?.plant;
    // Recherche de la rubrique qui contient 'morphologie' dans son nom
    final morphologyRubric = plant?.rubrics?.firstWhere(
      (rubric) => rubric.name.toLowerCase().contains('morphologie'),
      // orElse retourne null si non trouvé
      orElse: () => Rubric(id: '', plantId: 0, name: '', infos: []),
    );

    if (morphologyRubric == null || (morphologyRubric.infos ?? []).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informations sur $morphologyType non disponibles'),
        ),
      );
      return;
    }

    // Tente de trouver l'info correspondant au type de morphologie
    RubricInfo? matchingInfo;
    final infos = morphologyRubric.infos ?? [];

    // Recherche par correspondance exacte ou partielle (titre contient le type ou vice-versa)
    matchingInfo = infos.firstWhere(
        (info) =>
            info.title.toLowerCase().contains(morphologyType.toLowerCase()) ||
            morphologyType.toLowerCase().contains(info.title.toLowerCase()),
        orElse: () => RubricInfo(id: '', rubricId: '', title: '', content: ''),
    );

    if (matchingInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Détails spécifiques pour "$morphologyType" non disponibles',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(matchingInfo!.title), // Utilise le titre de la RubricInfo
        content: SingleChildScrollView(
          child: Text(
            matchingInfo.content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildRubricView(Rubric rubric) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (rubric.infos ?? []).map((info) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  info.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Galerie photo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return InkWell(
                    // Ajout d'InkWell pour rendre l'image cliquable (pour agrandir)
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Affichage de la photo en plein écran'),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        gallery[index],
                        width: 120,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/mango_leaf.jpg', // Placeholder image
                            width: 120,
                            height: 88,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  // Voir plus -> ouvrir page galerie
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ouvrir la page galerie (placeholder)'),
                    ),
                  );
                },
                child: const Text(
                  'Voir plus >',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonctions de construction de sections non utilisées dans le build actuel et non spécifiques au _buildCareItem
  /*
  void _showCareDetail(String careType) { 
    // ... (Logique de recherche)
    // Cette fonction n'est pas appelée. Si elle n'est pas nécessaire, elle peut être supprimée.
  }

  Widget _buildCareItem(String title, String subtitle, {VoidCallback? onTap}) {
    // ... (Widget de soin)
    // Ce widget n'est pas appelé dans _PlantFullDetailPageState.build().
    return const SizedBox.shrink(); 
  }

  Widget _buildProblemSection(String title) {
    // ... (Widget de problème)
    // Ce widget n'est pas appelé dans _PlantFullDetailPageState.build().
    return const SizedBox.shrink();
  }

  Widget _buildEconomicSection(String title, List<String> items) {
    // ... (Widget économique)
    // Ce widget n'est pas appelé dans _PlantFullDetailPageState.build().
    return const SizedBox.shrink();
  }
  */

  @override
  Widget build(BuildContext context) {
    final rubrics = widget.analysisResult?.plant.rubrics ?? [];
    final tabs = <Tab>[const Tab(text: 'Fiche plante')];
    tabs.addAll(rubrics.map((r) => Tab(text: r.name)));

    final tabViews = <Widget>[
      // Tab 1: Fiche plante (scrollable)
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildCardInfo contient les infos de base et la description
            _buildCardInfo(),
            // _buildMorphology contient la grille des parties de la plante
            _buildMorphology(),
            // _buildPhotoGallery contient la galerie
            _buildPhotoGallery(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ];
    // Ajout des rubriques dynamiques après l'onglet "Fiche plante"
    tabViews.addAll(rubrics.map((r) => _buildRubricView(r)));

    // Page principale avec TabBar
    return Scaffold(
      body: Column(
        children: [
          // 1. Image + overlay
          _buildTopImage(context),

          // 2. Header (titre + latin + message de santé)
          _buildHeader(),

          // 3. Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor, // Utiliser le thème
              unselectedLabelColor: Colors.black54,
              indicatorColor: Theme.of(context).primaryColor,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              tabs: tabs,
            ),
          ),

          // 4. Contenu des tabs
          Expanded(
            child: TabBarView(controller: _tabController, children: tabViews),
          ),
        ],
      ),
    );
  }
}

// --- Widget réutilisable pour les lignes d'information ---

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          // Modification : Enlève softWrap: false, overflow: TextOverflow.ellipsis, maxLines: 1
          // pour permettre au texte de s'enrouler si la valeur est longue
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
