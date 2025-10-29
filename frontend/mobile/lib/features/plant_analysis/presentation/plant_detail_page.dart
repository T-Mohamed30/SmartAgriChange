import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:smartagrichange_mobile/features/plant_analysis/models/anomaly_analysis_models.dart';

class PlantDetailPage extends StatelessWidget {
  final AnomalyAnalysisResponse? analysisResult;
  final Uint8List? imageBytes;

  const PlantDetailPage({Key? key, this.analysisResult, this.imageBytes})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use analysis result if available, otherwise fallback to static data
    final plant = analysisResult?.plant;
    final anomaly = analysisResult?.anomaly;
    final modelResult = analysisResult?.modelResult;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image with red bounding boxes using captured image or fallback
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: imageBytes != null
                      ? Image.memory(
                          imageBytes!,
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
                // Another button on top right of image (placeholder)
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
                // Example red boxes - could be replaced with actual bounding boxes from API
                // Positioned(
                //   left: 50,
                //   top: 50,
                //   width: 100,
                //   height: 150,
                //   child: Container(
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.red, width: 3),
                //     ),
                //   ),
                // ),
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

                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/plant_analysis/full_detail',
                        arguments: {
                          'analysisResult': analysisResult,
                          'imageBytes': imageBytes,
                          'showHealthyMessage': false,
                        },
                      );
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
                  const SizedBox(height: 16),
                  if (anomaly != null || modelResult != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Anomalie(s) detecte',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            anomaly?.name ??
                                (modelResult?.prediction.contains('___') == true
                                    ? modelResult!.prediction.split('___').last
                                    : modelResult?.prediction) ??
                                'Tache brune (anthracnose)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          if (modelResult != null)
                            Text(
                              'Confiance: ${(modelResult.confidence * 100).toStringAsFixed(2)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: Colors.green.shade800,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(text: 'Infos'),
                            Tab(text: 'Solutions'),
                            Tab(text: 'Préventions'),
                          ],
                        ),
                        SizedBox(
                          height: 200,
                          child: TabBarView(
                            children: [
                              _buildDescriptionTab(anomaly),
                              _buildSolutionsTab(anomaly),
                              _buildPreventionsTab(anomaly),
                            ],
                          ),
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
    );
  }

  Widget _buildDescriptionTab(Anomaly? anomaly) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            anomaly?.description ?? 'Aucune description disponible.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (anomaly?.symptomes != null && anomaly!.symptomes!.isNotEmpty)
            ExpansionTile(
              title: const Text('Symptômes'),
              children: anomaly.symptomes!
                  .map(
                    (symptom) => ListTile(
                      title: Text(
                        symptom,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            ExpansionTile(
              title: const Text('Symptômes'),
              children: const [
                ListTile(
                  title: Text(
                    'Aucun symptôme spécifié.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          if (anomaly?.causes != null && anomaly!.causes!.isNotEmpty)
            ExpansionTile(
              title: const Text('Causes'),
              children: anomaly.causes!
                  .map(
                    (cause) => ListTile(
                      title: Text(cause, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
            )
          else
            ExpansionTile(
              title: const Text('Causes'),
              children: const [
                ListTile(
                  title: Text(
                    'Aucune cause spécifiée.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSolutionsTab(Anomaly? anomaly) {
    if (anomaly?.traitement != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Text(anomaly!.traitement!, style: const TextStyle(fontSize: 14)),
      );
    }
    return Center(
      child: Text(
        'Aucune solution disponible.',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildPreventionsTab(Anomaly? anomaly) {
    if (anomaly?.prevention != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Text(anomaly!.prevention!, style: const TextStyle(fontSize: 14)),
      );
    }
    return Center(
      child: Text(
        'Aucune prévention disponible.',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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
