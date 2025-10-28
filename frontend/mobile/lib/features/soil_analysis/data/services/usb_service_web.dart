import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js' as js;

class UsbService {
  // WebUSB support
  dynamic _webDevice;
  bool _isWebConnected = false;
  StreamController<List<int>>? _dataController;

  Stream<List<int>>? get dataStream => _dataController?.stream;
  bool get isConnected => _isWebConnected;

  Future<void> initialize() async {
    _dataController = StreamController<List<int>>.broadcast();
  }

  void initUsbEventListener(Function(String) onEvent) {
    // USB events not supported on web
    return;
  }

  Future<List<UsbDevice>> scanDevices() async {
    return await _scanWebDevices();
  }

  Future<List<UsbDevice>> _scanWebDevices() async {
    try {
      // Check if WebUSB is supported
      final navigator = js.context['navigator'];
      if (navigator == null || !navigator.hasProperty('usb')) {
        print("WebUSB not supported");
        return [];
      }

      // Request USB device from user (this will show browser permission dialog)
      final usb = navigator['usb'];
      final device = await js.JsObject.fromBrowserObject(usb).callMethod(
        'requestDevice',
        [
          js.JsObject.jsify({
            'filters': [
              // Add specific filters for your NPK sensor if known
              // Example: {'vendorId': 0x1234, 'productId': 0x5678}
              // For now, allow any device
            ],
          }),
        ],
      );

      if (device != null) {
        // Create a mock UsbDevice for compatibility
        final mockDevice = UsbDevice(
          (device['productId'] ?? 0),
          (device['vendorId'] ?? 0),
          device['productName'] ?? 'WebUSB NPK Sensor',
          device['manufacturerName'] ?? '',
          '0',
          0,
          '0',
          0,
        );
        return [mockDevice];
      }
      return [];
    } catch (e) {
      print("Error scanning WebUSB devices: $e");
      return [];
    }
  }

  Future<bool> connect(UsbDevice device, {int baudRate = 9600}) async {
    try {
      await disconnect();

      // WebUSB connection logic would go here
      // This is a placeholder for WebUSB implementation
      _isWebConnected = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> write(Uint8List data) async {
    // WebUSB write implementation would go here
    // This is a placeholder
  }

  Future<void> disconnect() async {
    _isWebConnected = false;
    await _dataController?.close();
    _dataController = null;
  }

  void dispose() {
    disconnect();
  }
}

// Mock UsbDevice class for web compatibility
class UsbDevice {
  final int? pid;
  final int? vid;
  final String productName;
  final String manufacturerName;
  final String deviceName;
  final int? interfaceCount;
  final String serial;
  final int? deviceId;

  UsbDevice(
    this.pid,
    this.vid,
    this.productName,
    this.manufacturerName,
    this.deviceName,
    this.interfaceCount,
    this.serial,
    int? deviceClass,
  ) : deviceId = pid ?? 0;

  Future<dynamic> create() async {
    // Mock implementation for web
    return null;
  }
}
