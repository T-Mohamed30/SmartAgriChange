import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'plant_full_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/plant_analysis_api.dart';
import '../models/plant_analysis_models.dart';

class PlantDetailPage extends StatefulWidget {
  final int? analysisId;

  const PlantDetailPage({super.key, required this.analysisId});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  AnalysePlante? _analyse;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalyse();
  }

  Future<void> _showAnomalieDetails(String anomalieName) async {
    // Fetch list and try to find by name (backend exposes /api/anomalies and /api/anomalies/:id)
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      final list = await PlantAnalysisApi.getAllAnomalies();
      Navigator.of(context).pop();

      // Try to find exact match (case-insensitive)
      final match = list.cast<Map<String, dynamic>?>().firstWhere(
        (e) =>
            e != null &&
            (e['nom'] as String).toLowerCase() == anomalieName.toLowerCase(),
        orElse: () => null,
      );

      if (match == null) {
        // Show a simple dialog with the name if not found
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(anomalieName),
            content: const Text('Détails non disponibles pour cette anomalie.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
        return;
      }

      final id = match['id'] as int;
      final details = await PlantAnalysisApi.getAnomalieById(id);

      // Show bottom sheet with details
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          final desc = details['description'] ?? '';
          final symptomes = details['symptomes'] != null
              ? (details['symptomes'] is String
                    ? [details['symptomes']]
                    : List<String>.from(details['symptomes']))
              : [];
          final causes = details['causes'] != null
              ? (details['causes'] is String
                    ? [details['causes']]
                    : List<String>.from(details['causes']))
              : [];
          final solutions = details['solutions'] != null
              ? List<Map<String, dynamic>>.from(details['solutions'])
              : [];

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            builder: (_, controller) => SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details['nom'] ?? anomalieName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (desc.isNotEmpty) Text(desc),
                    const SizedBox(height: 12),
                    if (symptomes.isNotEmpty) ...[
                      const Text(
                        'Symptômes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      for (final s in symptomes) ListTile(title: Text(s)),
                    ],
                    if (causes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Causes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      for (final c in causes) ListTile(title: Text(c)),
                    ],
                    if (solutions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Solutions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      for (final sol in solutions)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(sol['type_solution'] ?? ''),
                            subtitle: Text(sol['contenu'] ?? ''),
                          ),
                        ),
                    ],
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _loadAnalyse() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    if (widget.analysisId == null) {
      setState(() {
        _error = 'Aucune analyse spécifiée';
        _loading = false;
      });
      return;
    }

    try {
      final analyse = await PlantAnalysisApi.getAnalysePlanteById(
        widget.analysisId!,
        token,
      );
      setState(() {
        _analyse = analyse;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analyse')),
        body: Center(child: Text(_error!)),
      );
    }

    final imagePath = _analyse?.imageUrl ?? '';
    final espece = _analyse?.planteIdentifiee?.nomCommun ?? 'Inconnu';
    final confiance = _analyse?.confianceIdentification ?? 0.0;
    final anomalies = _analyse?.anomaliesDetectees ?? [];
    final maladies = _analyse?.maladiesDetectees ?? [];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: kIsWeb || imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/mango_leaf.jpg',
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.file(
                          File(imagePath),
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/mango_leaf.jpg',
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                ),
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
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    espece,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Confiance: ${(confiance * 100).toStringAsFixed(0)}%'),
                  const SizedBox(height: 12),
                  if (anomalies.isNotEmpty) ...[
                    const Text(
                      'Anomalies détectées',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (final a in anomalies)
                      ListTile(
                        title: Text(a),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () async {
                          await _showAnomalieDetails(a);
                        },
                      ),
                    const SizedBox(height: 12),
                  ],
                  if (maladies.isNotEmpty) ...[
                    const Text(
                      'Maladies détectées',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (final m in maladies) ListTile(title: Text(m)),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      final plantId = _analyse?.planteIdentifiee?.id;
                      if (plantId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlantFullDetailPage(plantId: plantId, imagePath: imagePath),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFF007F3D),
                      side: const BorderSide(
                        color: Color(0xFF007F3D),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Détail de la plante'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
