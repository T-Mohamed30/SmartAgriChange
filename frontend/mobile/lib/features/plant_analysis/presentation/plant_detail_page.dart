import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class PlantDetailPage extends StatelessWidget {
  final String imagePath;
  // Add other necessary fields like plant name, anomaly details, etc.

  const PlantDetailPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For demonstration, static data is used. Replace with dynamic data as needed.
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
                  child: kIsWeb
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
                            // Fallback to asset image if file loading fails
                            return Image.asset(
                              'assets/images/mango_leaf.jpg',
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            );
                          },
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
                // Example red boxes
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
                // Positioned(
                //   left: 180,
                //   top: 30,
                //   width: 50,
                //   height: 80,
                //   child: Container(
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.red, width: 3),
                //     ),
                //   ),
                // ),
                // Positioned(
                //   left: 250,
                //   top: 100,
                //   width: 40,
                //   height: 60,
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
                  const Text(
                    'manguier',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text.rich(
                    TextSpan(
                      text: 'Nom latin : ',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Maguifera Indica',
                          style: TextStyle(
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
                        arguments: {'imagePath': imagePath},
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'Anomalie(s) detecte',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tache brune (anthracnose)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                              _buildDescriptionTab(),
                              _buildSolutionsTab(),
                              _buildPreventionsTab(),
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

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'La "maladie des taches brunes" sur le manguier, aussi appelée anthracnose, est une maladie fongique courante causée par le champignon Colletotrichum gloeosporioides. Elle se manifeste par des lésions sombres et enfoncées sur les feuilles, les fleurs et les fruits, souvent entourées d\'un halo jaune. Les conditions chaudes et humides, notamment pendant la saison des pluies, favorisent sa propagation.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('Symptômes'),
            children: const [
              ListTile(
                title: Text(
                  'Taches sombres et enfoncées sur les feuilles, fleurs et fruits',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              ListTile(
                title: Text(
                  'Présence d\'un halo jaune autour des lésions',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Causes'),
            children: const [
              ListTile(
                title: Text(
                  'Champignon Colletotrichum gloeosporioides',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              ListTile(
                title: Text(
                  'Conditions chaudes et humides favorisant la propagation',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionsTab() {
    return Center(
      child: Text(
        'Solutions content goes here.',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildPreventionsTab() {
    return Center(
      child: Text(
        'Préventions content goes here.',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      ),
    );
  }
}
