import 'dart:async';
import '../../domain/entities/sensor.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../services/usb_service.dart';
import '../services/npk_service.dart';

class SensorRepositoryImpl implements SensorRepository {
  final StreamController<List<Sensor>> _controller =
      StreamController<List<Sensor>>.broadcast();
  final List<Sensor> _detectedSensors = [];
  UsbService? _usbService;
  NPKService? _npkService;
  StreamSubscription? _usbSubscription;

  @override
  Stream<List<Sensor>> scanSensors() {
    _startUsbScan();
    return _controller.stream;
  }

  void _startUsbScan() async {
    try {
      // Clear previous results and emit empty list to indicate scanning started
      _detectedSensors.clear();
      _controller.add([]);

      // Initialize USB service
      _usbService = UsbService();
      await _usbService!.initialize();

      // Add USB event listener for hotplug detection (only on native platforms)
      _usbService!.initUsbEventListener((event) {
        print("USB Event: $event");
        // Re-scan when devices are attached/detached
        _startUsbScan();
      });

      // Scan for USB devices
      final devices = await _usbService!.scanDevices();
      print("Found ${devices.length} USB devices");

      // Convert USB devices to Sensor entities
      for (final device in devices) {
        print("Device: ${device.productName} (ID: ${device.deviceId})");
        final sensor = Sensor(
          id: device.deviceId.toString(),
          name: device.productName ?? 'USB NPK Sensor',
          status: SensorStatus.online,
          batteryLevel: null, // USB devices don't have battery
          location: null,
          lastAnalysisAt: null,
        );
        _detectedSensors.add(sensor);
      }

      // Emit current list of detected sensors
      _controller.add(List<Sensor>.from(_detectedSensors));
    } catch (e) {
      print("Error during USB scan: $e");
      _controller.add([]);
    }
  }

  @override
  Future<List<Sensor>> getCachedSensors() async {
    return List<Sensor>.from(_detectedSensors);
  }

  @override
  Future<void> connectToSensor(String sensorId) async {
    await _connectUsbSensor(sensorId);
  }

  Future<void> _connectUsbSensor(String sensorId) async {
    try {
      if (_usbService == null) {
        throw Exception("USB service not initialized");
      }

      // Find the USB device by sensorId
      final devices = await _usbService!.scanDevices();
      final targetDevice = devices.firstWhere(
        (device) => device.deviceId.toString() == sensorId,
        orElse: () => throw Exception("Device not found"),
      );

      // Connect to the USB device
      await _usbService!.connect(targetDevice);

      // Initialize NPK service for data reading
      _npkService = NPKService(_usbService!);

      // Update sensor status
      final sensorIndex = _detectedSensors.indexWhere((s) => s.id == sensorId);
      if (sensorIndex != -1) {
        _detectedSensors[sensorIndex] = _detectedSensors[sensorIndex].copyWith(
          status: SensorStatus.online,
        );
        _controller.add(List<Sensor>.from(_detectedSensors));
      }

      print("Connected to USB sensor: $sensorId");
    } catch (e) {
      print("Error connecting to USB sensor: $e");
      throw Exception("Failed to connect to sensor");
    }
  }

  @override
  Future<void> startAnalysis(String sensorId, {String? parcelleId}) async {
    await _startUsbAnalysis(sensorId, parcelleId: parcelleId);
  }

  Future<void> _startUsbAnalysis(String sensorId, {String? parcelleId}) async {
    try {
      if (_npkService == null) {
        throw Exception("NPK service not initialized");
      }

      // Start polling for NPK data
      _npkService!.startPolling();

      // Listen to NPK data stream
      _usbSubscription = _npkService!.dataStream.listen((npkData) {
        print("Received NPK data: $npkData");

        // Update sensor's last analysis time
        final sensorIndex = _detectedSensors.indexWhere(
          (s) => s.id == sensorId,
        );
        if (sensorIndex != -1) {
          _detectedSensors[sensorIndex] = _detectedSensors[sensorIndex]
              .copyWith(lastAnalysisAt: DateTime.now());
          _controller.add(List<Sensor>.from(_detectedSensors));
        }

        // Here you could send the data to your backend API
        // await _sendAnalysisDataToBackend(npkData, parcelleId);
      });
    } catch (e) {
      print("Error starting USB analysis: $e");
      throw Exception("Failed to start analysis");
    }
  }

  void dispose() {
    _usbSubscription?.cancel();
    _npkService?.dispose();
    _usbService?.dispose();
    _controller.close();
  }
}
