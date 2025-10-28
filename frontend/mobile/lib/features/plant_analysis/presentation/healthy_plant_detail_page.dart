import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:smartagrichange_mobile/features/plant_analysis/models/anomaly_analysis_models.dart';

class HealthyPlantDetailPage extends StatefulWidget {
  final AnomalyAnalysisResponse? analysisResult;
  final Uint8List? imageBytes;

  const HealthyPlantDetailPage({
    super.key,
    this.analysisResult,
    this.imageBytes,
  });

  @override
  State<HealthyPlantDetailPage> createState() => _HealthyPlantDetailPageState();
}

class _HealthyPlantDetailPageState extends State<HealthyPlantDetailPage>
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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

        // Dégradé en bas de l'image pour contraste du texte si besoin
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texte principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant?.nomCommun ?? 'Plante inconnue',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Nom latin : ${plant?.nomScientifique ?? 'Non spécifié'}',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMorphology() {
    final List<String> items = [
      'Racines',
      'Tronc',
      'Feuilles',
      'Fleurs',
      'Fruits',
    ];
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 40 / 14,
              children: items
                  .map(
                    (e) => OutlinedButton(
                      onPressed: () {
                        // placeholder: ouvrir la fiche morphologique
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        minimumSize: const Size(40, 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            e,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: Colors.black,
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      gallery[index],
                      width: 120,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/mango_leaf.jpg',
                          width: 120,
                          height: 88,
                          fit: BoxFit.cover,
                        );
                      },
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
                },
                child: const Text('Voir plus >'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          // Handle tap for each care item
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Section "$title" - Bientôt disponible')),
          );
        },
      ),
    );
  }

  Widget _buildProblemSection(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gallery.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    gallery[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Voir plus - $title (Bientôt disponible)'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Voir plus >',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEconomicSection(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        expandedAlignment: Alignment.centerLeft,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.analysisResult?.plant;

    return Scaffold(
      body: Column(
        children: [
          // Image with back button and info button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: widget.imageBytes != null
                    ? Image.memory(
                        widget.imageBytes!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/mango_leaf.jpg',
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
              ),
              // Back button on top left of image
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              // Info button on top right of image
              Positioned(
                top: 40,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.black),
                    onPressed: () {
                      // TODO: Implement action for this button
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant?.nomCommun ?? 'Plante inconnue',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: 'Nom latin : ',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    children: [
                      TextSpan(
                        text: plant?.nomScientifique ?? 'Non spécifié',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF007F3D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Votre plante est en bonne santé',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.green.shade800,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.green.shade800,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            labelPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            tabs: const [
              Tab(text: 'Fiche plante'),
              Tab(text: 'Soins & Culture'),
              Tab(text: 'Conditions idéales'),
              Tab(text: 'Problèmes et solutions'),
              Tab(text: 'Economie et contexte local'),
            ],
          ),

          // contenu tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: fiche plante (scrollable)
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildCardInfo(),
                      _buildMorphology(),
                      _buildPhotoGallery(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Tab 2: Soins & Culture
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCareItem(
                              'Eau',
                              'Arrosage et besoins hydriques',
                            ),
                            _buildCareItem(
                              'Fertilisation',
                              'Engrais et nutrition',
                            ),
                            _buildCareItem(
                              'Taille / entretien',
                              'Techniques de taille et maintenance',
                            ),
                            _buildCareItem(
                              'Propagation',
                              'Multiplication et bouturage',
                            ),
                            _buildCareItem(
                              'Calendrier cultural',
                              'Périodes optimales pour chaque soin',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Tab 3: Conditions idéales
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCareItem(
                              'Température',
                              'Conditions thermiques optimales',
                            ),
                            _buildCareItem(
                              'Sol',
                              'Type de sol et pH recommandé',
                            ),
                            _buildCareItem(
                              'Lumière',
                              'Exposition et ensoleillement',
                            ),
                            _buildCareItem(
                              'Zones de cultures principales',
                              'Régions adaptées à la culture',
                            ),
                            _buildCareItem(
                              'Saisonnalité locale',
                              'Calendrier cultural spécifique',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Tab 4: Problèmes et solutions
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProblemSection('Maladies courantes'),
                        _buildProblemSection('Ravageurs'),
                        _buildProblemSection('Carences fréquentes'),
                      ],
                    ),
                  ),
                ),

                // Tab 5: Economie et contexte local
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEconomicSection('Prix marché', [
                          '200-500 FCFA/kg selon variété et qualité',
                        ]),
                        _buildEconomicSection('Utilisation', [
                          'Consommation fraîche',
                          'Transformation (jus, séché, confiture)',
                          'Bois du manguier utilisé en menuiserie',
                        ]),
                        _buildEconomicSection('Importance sociale', [
                          'Source de revenus pour petits producteurs',
                          'Activité importante pour les femmes (vente au marché, transformation artisanale)',
                          'Export possible vers Côte d\'Ivoire, Ghana, Europe (variétés améliorées)',
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
