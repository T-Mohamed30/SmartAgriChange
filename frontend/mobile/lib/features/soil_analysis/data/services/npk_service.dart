import 'dart:typed_data';
import 'dart:async';
import '../../domain/entities/npk_data.dart';
import 'usb_service.dart';

class NPKService {
  final UsbService _usbService;
  final StreamController<NPKData> _dataController =
      StreamController.broadcast();
  Timer? _pollTimer;
  StreamSubscription? _usbDataSubscription;

  Stream<NPKData> get dataStream => _dataController.stream;

  NPKService(this._usbService);

  void _log(String message) {
    final logMessage = "${DateTime.now().toIso8601String()} - $message";
    print(logMessage);
  }

  /// Calcul du CRC16 Modbus
  int _calculateCRC16(List<int> data) {
    int crc = 0xFFFF;
    for (int byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc = (crc >> 1) ^ 0xA001;
        } else {
          crc >>= 1;
        }
      }
    }
    return crc;
  }

  /// Crée une requête Modbus RTU
  Uint8List _createModbusRequest() {
    List<int> request = [
      0x01, // Adresse esclave
      0x03, // Fonction Read Holding Registers
      0x00, 0x00, // Adresse registre
      0x00, 0x06, // Nombre de registres (6 - removed fertility)
    ];

    int crc = _calculateCRC16(request);
    request.add(crc & 0xFF);
    request.add((crc >> 8) & 0xFF);

    return Uint8List.fromList(request);
  }

  /// Parse la réponse Modbus
  /// IMPORTANT: Les données parsées ne doivent plus être modifiées après cette méthode
  NPKData? _parseModbusResponse(List<int> response) {
    _log(
      "Réponse reçue: ${response.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}",
    );

    if (response.length < 5) {
      _log("Réponse trop courte (${response.length} bytes)");
      return null;
    }

    int address = response[0];
    int function = response[1];
    int byteCount = response[2];

    if (address != 0x01 || function != 0x03) {
      _log("Adresse ou fonction incorrecte");
      return null;
    }

    // Vérification CRC
    if (response.length >= byteCount + 5) {
      List<int> dataWithoutCRC = response.sublist(0, response.length - 2);
      int receivedCRC =
          response[response.length - 2] | (response[response.length - 1] << 8);
      int calculatedCRC = _calculateCRC16(dataWithoutCRC);

      if (receivedCRC != calculatedCRC) {
        _log("CRC invalide!");
        return null;
      }
    }

    int numRegisters = byteCount ~/ 2;
    if (numRegisters < 6) {
      _log("Nombre de registres insuffisant: $numRegisters");
      return null;
    }

    // Extraction des données - Ces valeurs ne seront plus modifiées après parsing
    int humidity = (response[3] << 8) | response[4];
    double temperature = ((response[5] << 8) | response[6]) / 10.0;
    int conductivity = (response[7] << 8) | response[8];
    int phRaw = (response[9] << 8) | response[10];
    double ph = phRaw / 10.0;
    int nitrogen = (response[11] << 8) | response[12];
    int phosphorus = (response[13] << 8) | response[14];
    int potassium = (response[15] << 8) | response[16];

    _log(
      "Données NPK extraites (finales, non modifiables): T=${temperature}°C, H=$humidity%, pH=$ph, N=$nitrogen, P=$phosphorus, K=$potassium",
    );

    // Création de l'objet NPKData avec les données finales
    final npkData = NPKData(
      temperature: temperature,
      humidity: humidity,
      conductivity: conductivity,
      ph: ph,
      nitrogen: nitrogen,
      phosphorus: phosphorus,
      potassium: potassium,
    );

    _log("Objet NPKData créé avec données finales: $npkData");

    return npkData;
  }

  /// Démarre la lecture périodique
  void startPolling({Duration interval = const Duration(seconds: 3)}) {
    // Écoute des données USB
    _usbDataSubscription = _usbService.dataStream?.listen((data) {
      NPKData? npkData = _parseModbusResponse(data);
      if (npkData != null) {
        _dataController.add(npkData);
      }
    });

    // Polling périodique
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (timer) {
      sendRequest();
    });

    // Première requête immédiate
    Future.delayed(const Duration(milliseconds: 500), () {
      sendRequest();
    });
  }

  /// Envoie une requête NPK
  Future<void> sendRequest() async {
    try {
      Uint8List request = _createModbusRequest();
      await _usbService.write(request);
    } catch (e) {
      _log("Erreur envoi: $e");
    }
  }

  /// Arrête le polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _usbDataSubscription?.cancel();
    _usbDataSubscription = null;
  }

  void dispose() {
    stopPolling();
    _dataController.close();
  }
}
