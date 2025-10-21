import 'package:flutter/material.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  int _selectedIndex = 0;
  String? _selectedStage; // null means show current stage tasks

  final List<String> _tabs = ['Aperçu', 'Etapes', 'Tâches'];

  void _onStageSelected(String stage) {
    setState(() {
      _selectedStage = stage;
      _selectedIndex = 2; // switch to Tâches tab
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) {
        _selectedStage = null; // reset selected stage when leaving Tâches tab
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    final cropName = args['cropName'] as String? ?? 'Culture';
    final parcelleName = args['parcelleName'] as String? ?? 'nom parcelle';
    final cycleDays = args['cycleDays'] as int? ?? 28;
    final hectare = args['hectare'] as double? ?? 0.25;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              parcelleName,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '$cropName - $hectare hectare - Cycle jour $cycleDays',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (index) {
            final selected = _selectedIndex == index;
            return GestureDetector(
              onTap: () {
                _onTabChanged(index);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? Colors.green : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.green : Colors.black54,
                  ),
                ),
              ),
            );
          }),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF7F7F7),
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _ApercuTab(),
                  _EtapesTab(onStageSelected: _onStageSelected),
                  _TachesTab(selectedStage: _selectedStage),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Add new task action
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _ApercuTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final progressPercent = 65;
    final remainingTasks = 12;
    final totalSteps = 5;
    final remainingDays = 62;
    final currentDay = 28;
    final totalCycleDays = 90;
    final currentPhase = 'Phase Végétative';

    final List<Map<String, Object>> urgentTasks = [
      {
        'title': 'Traitement contre Tuta absoluta',
        'subtitle': 'Aujourd\'hui • 45 min • Pulvérisation',
        'status': 'En retard',
        'color': Colors.red,
      },
      {
        'title': 'Fertilisation potassique',
        'subtitle': 'Demain • 30 min • 25 kg/ha',
        'status': 'A faire',
        'color': Colors.orange,
      },
    ];

    final Map<String, Object> nextStep = {
      'title': 'Floraison',
      'subtitle': 'Jour 30-50 • Dans 2 jours',
      'status': 'A venir',
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                label: 'Progression',
                value: '$progressPercent%',
              ),
              _StatCard(
                label: 'Tâches restantes',
                value: '$remainingTasks',
              ),
              _StatCard(
                label: 'Étapes',
                value: '$totalSteps',
              ),
              _StatCard(
                label: 'Jours restants',
                value: '$remainingDays',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressCircle(
            currentDay: currentDay,
            totalDays: totalCycleDays,
            phase: currentPhase,
            percent: progressPercent,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tâches urgentes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...urgentTasks.map((task) => _UrgentTaskCard(
                title: task['title'] as String,
                subtitle: task['subtitle'] as String,
                status: task['status'] as String,
                color: task['color'] as Color,
              )),
          const SizedBox(height: 16),
          const Text(
            'Prochaine étape',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _NextStepCard(
            title: nextStep['title'] as String,
            subtitle: nextStep['subtitle'] as String,
            status: nextStep['status'] as String,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  final String phase;
  final int percent;

  const _ProgressCircle({
    required this.currentDay,
    required this.totalDays,
    required this.phase,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 8,
                    color: Colors.green,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  Center(
                    child: Text(
                      '$percent%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$currentDay/$totalDays jours',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    phase,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
}

class _UrgentTaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const _UrgentTaskCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;

  const _NextStepCard({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EtapesTab extends StatelessWidget {
  final Function(String) onStageSelected;

  const _EtapesTab({required this.onStageSelected});

  @override
  Widget build(BuildContext context) {
    // Dummy data for stages
    final List<Map<String, Object>> stages = [
      {
        'title': 'Germination',
        'days': 'Jour 1-10',
        'status': 'Terminée',
        'statusColor': Colors.green.shade100,
        'statusTextColor': Colors.green,
      },
      {
        'title': 'Repiquage',
        'days': 'Jour 10-14',
        'status': 'Terminée',
        'statusColor': Colors.green.shade100,
        'statusTextColor': Colors.green,
      },
      {
        'title': 'Croissance végétative',
        'days': 'Jour 14-30',
        'status': 'En cours',
        'statusColor': Colors.grey.shade300,
        'statusTextColor': Colors.black54,
      },
      {
        'title': 'Floraison',
        'days': 'Jour 30-50',
        'status': 'Dans 2 jours',
        'statusColor': Colors.grey.shade300,
        'statusTextColor': Colors.black54,
      },
      {
        'title': 'Croissance végétative',
        'days': 'Jour 70-90',
        'status': 'Dans 42 jours',
        'statusColor': Colors.grey.shade300,
        'statusTextColor': Colors.black54,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: stages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final stage = stages[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
            ],
          ),
          child: ListTile(
            title: Text(
              stage['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${stage['days']} • ${stage['status']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: stage['statusColor'] as Color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                stage['status'] as String,
                style: TextStyle(
                  color: stage['statusTextColor'] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TachesTab extends StatefulWidget {
  final String? selectedStage;

  const _TachesTab({this.selectedStage});

  @override
  State<_TachesTab> createState() => _TachesTabState();
}

class _TachesTabState extends State<_TachesTab> {
  // Task completion state - ready for database integration
  final Map<String, bool> _taskCompletion = {};

  @override
  Widget build(BuildContext context) {
    // Determine which tasks to show based on selected stage
    final String displayStage = widget.selectedStage ?? 'Croissance végétative'; // Default to current stage

    // Dummy data for tasks per stage - ready for database integration
    final Map<String, List<Map<String, Object>>> tasksByStage = {
      'Germination': [
        {
          'id': 'germ1',
          'title': 'Préparation du sol',
          'subtitle': 'Jour 1 • 2h • Labour profond',
          'status': 'Terminée',
          'color': Colors.green,
        },
        {
          'id': 'germ2',
          'title': 'Semis des graines',
          'subtitle': 'Jour 3 • 1h • Profondeur 2cm',
          'status': 'Terminée',
          'color': Colors.green,
        },
      ],
      'Repiquage': [
        {
          'id': 'rep1',
          'title': 'Préparation des jeunes plants',
          'subtitle': 'Jour 10 • 1h • Sélection des plants',
          'status': 'Terminée',
          'color': Colors.green,
        },
        {
          'id': 'rep2',
          'title': 'Repiquage en terre',
          'subtitle': 'Jour 12 • 3h • Espacement 30cm',
          'status': 'Terminée',
          'color': Colors.green,
        },
      ],
      'Croissance végétative': [
        {
          'id': 'veg1',
          'title': 'Traitement contre Tuta absoluta',
          'subtitle': 'Aujourd\'hui • 45 min • Pulvérisation',
          'status': 'En retard',
          'color': Colors.red,
        },
        {
          'id': 'veg2',
          'title': 'Fertilisation potassique',
          'subtitle': 'Demain • 30 min • 25 kg/ha',
          'status': 'A faire',
          'color': Colors.orange,
        },
        {
          'id': 'veg3',
          'title': 'Taille sanitaire',
          'subtitle': '2 Sep • 1h • Élagage des feuilles',
          'status': 'A faire',
          'color': Colors.orange,
        },
      ],
      'Floraison': [
        {
          'id': 'flor1',
          'title': 'Surveillance des fleurs',
          'subtitle': 'Jour 32 • 30 min • Observation pollinisation',
          'status': 'A faire',
          'color': Colors.orange,
        },
        {
          'id': 'flor2',
          'title': 'Fertilisation azotée',
          'subtitle': 'Jour 35 • 45 min • 15 kg/ha',
          'status': 'Planifiée',
          'color': Colors.blue,
        },
      ],
      'Croissance végétative': [
        {
          'id': 'veg2_1',
          'title': 'Irrigation contrôlée',
          'subtitle': 'Jour 75 • 1h • 20mm d\'eau',
          'status': 'A faire',
          'color': Colors.orange,
        },
        {
          'id': 'veg2_2',
          'title': 'Récolte partielle',
          'subtitle': 'Jour 85 • 2h • Sélection des fruits mûrs',
          'status': 'Planifiée',
          'color': Colors.blue,
        },
      ],
    };

    final List<Map<String, Object>> tasks = tasksByStage[displayStage] ?? [];

    return Column(
      children: [
        if (widget.selectedStage != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'Tâches pour: $displayStage',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Reset to show current stage tasks
                    // This would be handled by parent widget
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskId = task['id'] as String;
              final isCompleted = _taskCompletion[taskId] ?? false;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _taskCompletion[taskId] = !isCompleted;
                        // TODO: Integrate with database to save completion status
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? Colors.green : Colors.white,
                        border: Border.all(
                          color: isCompleted ? Colors.green : Colors.black12,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
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
                        border: Border(left: BorderSide(color: task['color'] as Color, width: 6)),
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
                                    task['title'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      color: isCompleted ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    task['subtitle'] as String,
                                    style: TextStyle(
                                      color: isCompleted ? Colors.grey.shade400 : Colors.black54,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                task['status'] as String,
                                style: TextStyle(
                                  color: task['color'] as Color,
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
            },
          ),
        ),
      ],
    );
  }
}
