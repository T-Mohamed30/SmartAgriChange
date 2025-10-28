import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/soil_data.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'soil_analysis_channel',
          'Soil Analysis Alerts',
          channelDescription: 'Notifications for soil analysis alerts',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}

class AlertManager {
  final Ref _ref;
  Timer? _alertTimer;
  final Map<String, bool> _activeAlerts = {};

  AlertManager(this._ref);

  void startMonitoring() {
    _alertTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkCriticalConditions();
    });
  }

  void stopMonitoring() {
    _alertTimer?.cancel();
    _alertTimer = null;
  }

  void _checkCriticalConditions() {
    // This would be called with current soil data
    // For now, we'll implement the logic that can be integrated
  }

  Future<void> checkSoilConditions(SoilData soilData) async {
    final alerts = <String>[];

    // Check pH levels
    if (soilData.ph < 5.0) {
      alerts.add(
        'pH critique: Sol très acide (${soilData.ph.toStringAsFixed(1)})',
      );
    } else if (soilData.ph > 8.5) {
      alerts.add(
        'pH critique: Sol très alcalin (${soilData.ph.toStringAsFixed(1)})',
      );
    }

    // Check temperature
    if (soilData.temperature < 5.0) {
      alerts.add(
        'Température critique: Sol gelé (${soilData.temperature.toStringAsFixed(1)}°C)',
      );
    } else if (soilData.temperature > 40.0) {
      alerts.add(
        'Température critique: Sol surchauffé (${soilData.temperature.toStringAsFixed(1)}°C)',
      );
    }

    // Check humidity
    if (soilData.humidity < 10.0) {
      alerts.add(
        'Humidité critique: Sol très sec (${soilData.humidity.toStringAsFixed(1)}%)',
      );
    } else if (soilData.humidity > 90.0) {
      alerts.add(
        'Humidité critique: Sol saturé (${soilData.humidity.toStringAsFixed(1)}%)',
      );
    }

    // Check nutrient levels
    if (soilData.nitrogen < 20) {
      alerts.add(
        'Azote critique: Carence sévère (${soilData.nitrogen.toStringAsFixed(0)} mg/kg)',
      );
    }
    if (soilData.phosphorus < 10) {
      alerts.add(
        'Phosphore critique: Carence sévère (${soilData.phosphorus.toStringAsFixed(0)} mg/kg)',
      );
    }
    if (soilData.potassium < 50) {
      alerts.add(
        'Potassium critique: Carence sévère (${soilData.potassium.toStringAsFixed(0)} mg/kg)',
      );
    }

    // Check salinity
    if (soilData.ec > 4.0) {
      alerts.add(
        'Salinité critique: Sol très salin (${soilData.ec.toStringAsFixed(1)} dS/m)',
      );
    }

    // Send notifications for new alerts
    for (final alert in alerts) {
      if (!_activeAlerts.containsKey(alert)) {
        _activeAlerts[alert] = true;
        await NotificationService.showNotification(
          title: 'Alerte Analyse du Sol',
          body: alert,
          id: alert.hashCode,
        );
        dev.log('Alerte envoyée: $alert');
      }
    }

    // Clear resolved alerts
    _activeAlerts.removeWhere((alert, _) => !alerts.contains(alert));
  }

  void clearAllAlerts() {
    _activeAlerts.clear();
    NotificationService.cancelAllNotifications();
  }
}

// Provider for AlertManager
final alertManagerProvider = Provider<AlertManager>((ref) {
  final manager = AlertManager(ref);
  ref.onDispose(() {
    manager.stopMonitoring();
  });
  return manager;
});
