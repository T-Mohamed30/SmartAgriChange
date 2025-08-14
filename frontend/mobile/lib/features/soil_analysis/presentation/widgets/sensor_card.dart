import 'package:flutter/material.dart';
import '../../domain/entities/sensor.dart';

String statusLabel(SensorStatus s) {
  switch (s) {
    case SensorStatus.online: return 'Connecté';
    case SensorStatus.offline: return 'Hors ligne';
    case SensorStatus.lowBattery: return 'Batterie faible';
    case SensorStatus.error: return 'Erreur';
  }
}

class SensorCard extends StatelessWidget {
  final Sensor sensor;
  final VoidCallback? onTap;
  final bool highlighted;

  const SensorCard({required this.sensor, this.onTap, this.highlighted = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? Colors.green.shade50 : Colors.white;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/icons/capteur-de-mouvement 1.png', height: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sensor.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(statusLabel(sensor.status)),
                      const SizedBox(width: 12),
                      if (sensor.batteryLevel != null) ...[
                        Icon(Icons.battery_std, size: 16),
                        const SizedBox(width: 4),
                        Text('${sensor.batteryLevel}%'),
                      ],
                    ],
                  ),
                  if (sensor.location != null) ...[
                    const SizedBox(height: 6),
                    Text(sensor.location!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                  if (sensor.lastAnalysisAt != null) ...[
                    const SizedBox(height: 6),
                    Text('Dernière analyse: ${sensor.lastAnalysisAt}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
