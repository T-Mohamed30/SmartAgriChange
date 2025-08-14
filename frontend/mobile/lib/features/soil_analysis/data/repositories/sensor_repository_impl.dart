import 'dart:async';
import '../../domain/entities/sensor.dart';
import '../../domain/repositories/sensor_repository.dart';

class SensorRepositoryImpl implements SensorRepository {
  // Ici un streamController qui simule des capteurs détectés
  final _controller = StreamController<List<Sensor>>.broadcast();
  Timer? _timer;

  // initial mock list
  List<Sensor> _sensors = List.generate(4, (i) {
    return Sensor(
      id: 's$i',
      name: 'Capteur #A1${i+1}',
      status: SensorStatus.online,
      batteryLevel: 80 - i * 5,
      location: i == 0 ? 'Champ Maïs Nord' : null,
      lastAnalysisAt: i == 0 ? DateTime.now().subtract(const Duration(days: 1)) : null,
    );
  });

  @override
  Stream<List<Sensor>> scanSensors() {
    // simule un scan périodique — en réel on push à chaque résultat Bluetooth
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      // possibilité de modifier l'état aléatoirement pour test UI
      _controller.add(List<Sensor>.from(_sensors));
    });
    // push initial
    Future.delayed(Duration.zero, () => _controller.add(List<Sensor>.from(_sensors)));
    return _controller.stream;
  }

  @override
  Future<List<Sensor>> getCachedSensors() async => _sensors;

  @override
  Future<void> connectToSensor(String sensorId) async {
    // stub: en réel on fait le pairing / connect via bluetooth
    final idx = _sensors.indexWhere((s) => s.id == sensorId);
    if (idx != -1) {
      _sensors[idx] = _sensors[idx].copyWith(status: SensorStatus.online);
      _controller.add(List<Sensor>.from(_sensors));
    }
  }

  @override
  Future<void> startAnalysis(String sensorId, {String? parcelleId}) async {
    // stub: simule lancement d'analyse et update lastAnalysisAt
    final idx = _sensors.indexWhere((s) => s.id == sensorId);
    if (idx != -1) {
      _sensors[idx] = _sensors[idx].copyWith(lastAnalysisAt: DateTime.now());
      _controller.add(List<Sensor>.from(_sensors));
      // ici on pourrait appeler un backend pour stocker la campagne / campagneId
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
