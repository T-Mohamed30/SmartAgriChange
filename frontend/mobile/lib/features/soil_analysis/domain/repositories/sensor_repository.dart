import '../entities/sensor.dart';
import '../entities/npk_data.dart';

abstract class SensorRepository {
  /// démarre la recherche/bluetooth scan
  Stream<List<Sensor>> scanSensors();

  /// récupère la dernière liste (si stockage local)
  Future<List<Sensor>> getCachedSensors();

  /// effectue la connexion (si besoin)
  Future<void> connectToSensor(String sensorId);

  /// optional: démarrer mesure / trigger analyse
  Future<void> startAnalysis(String sensorId, {String? parcelleId});
  Stream<NPKData>? get npkDataStream;
}
