import 'package:flutter/material.dart';

class CropCalendarScreen extends StatelessWidget {
  const CropCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final cropName = args['cropName'] as String? ?? 'Culture';

    return Scaffold(
      appBar: AppBar(
        title: Text(cropName),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tab-like row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TabButton(label: 'Aperçu', selected: false),
                  _TabButton(label: 'Etapes', selected: false),
                  _TabButton(label: 'Tâches', selected: true),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    const SizedBox(height: 8),
                    _TaskCard(
                      color: Colors.red,
                      title: 'Traitement contre Tuta absoluta',
                      subtitle: 'Aujourd\'hui • 45 min • Pulvérisation',
                      status: 'En retard',
                    ),
                    const SizedBox(height: 12),
                    _TaskCard(
                      color: Colors.orange,
                      title: 'Fertilisation potassique',
                      subtitle: 'Planifié • 30 min • 25 kg/ha',
                      status: 'A faire',
                    ),
                    const SizedBox(height: 12),
                    _TaskCard(
                      color: Colors.orange,
                      title: 'Taille sanitaire',
                      subtitle: '2 Sep • 1h',
                      status: 'A faire',
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // open create task (TODO)
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  const _TabButton({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.black : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: selected ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final String status;
  const _TaskCard({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
              ],
              border: Border(left: BorderSide(color: color, width: 6)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
