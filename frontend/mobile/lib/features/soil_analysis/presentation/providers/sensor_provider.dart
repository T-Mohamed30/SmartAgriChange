import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sensor.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../../data/repositories/sensor_repository_impl.dart';

// repository provider (à remplacer par injection)
final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  final impl = SensorRepositoryImpl();
  ref.onDispose(() => impl.dispose());
  return impl;
});

/// provider qui expose le stream de capteurs (AsyncValue)
final detectedSensorsStreamProvider = StreamProvider<List<Sensor>>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.scanSensors();
});

/// provider pour capteur sélectionné
final selectedSensorProvider = StateProvider<Sensor?>((ref) => null);

/// provider pour l'état d'une détection (idle/searching/found)
enum SensorDetectionState { idle, searching, found, notFound, error }

final detectionStateProvider = StateProvider<SensorDetectionState>((ref) => SensorDetectionState.idle);

/// actions (StateNotifier) pour orchestrer la détection / connexion
class SensorActions extends StateNotifier<void> {
  final Ref ref;
  SensorActions(this.ref): super(null);

  void startSensorDetection() {
    ref.read(detectionStateProvider.notifier).state = SensorDetectionState.searching;
    // écouter le stream et mettre à jour l'état quand on a data
    final sub = ref.watch(detectedSensorsStreamProvider.stream).listen((sensors) {
      if (sensors.isEmpty) {
        ref.read(detectionStateProvider.notifier).state = SensorDetectionState.notFound;
      } else {
        ref.read(detectionStateProvider.notifier).state = SensorDetectionState.found;
      }
    }, onError: (err) {
      ref.read(detectionStateProvider.notifier).state = SensorDetectionState.error;
    });

    // on garde la souscription au besoin (ou l'annuler dans dispose)
  }

  Future<void> selectSensor(Sensor sensor) async {
    ref.read(selectedSensorProvider.notifier).state = sensor;
    // déclencher connect via repository
    await ref.read(sensorRepositoryProvider).connectToSensor(sensor.id);
  }

  Future<void> startAnalysis({required String sensorId, String? parcelleId}) async {
    await ref.read(sensorRepositoryProvider).startAnalysis(sensorId, parcelleId: parcelleId);
  }
}

final sensorActionsProvider = StateNotifierProvider<SensorActions, void>((ref) => SensorActions(ref));
