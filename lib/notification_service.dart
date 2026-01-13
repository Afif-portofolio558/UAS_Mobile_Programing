import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tzTime;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Init dengan callback saat notifikasi diklik
  static Future<void> init(Function(String?) onClick) async {
    // ensure timezone database ready
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          onClick(response.payload);
        }
      },
    );
  }

  // Tampilkan notifikasi segera
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'general_channel',
      'General',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: android),
      payload: payload,
    );
  }

  // Optional: scheduled notification helper (kept for compatibility)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzTime.TZDateTime.from(scheduledTime, tzTime.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel',
          'Deadline Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
}
