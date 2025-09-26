import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> schedulePrayerNotifications(Map<String, DateTime> prayerDateTimes, Map<String, bool> enabled) async {
    // cancel existing
    await flutterLocalNotificationsPlugin.cancelAll();

    final androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Notifications',
      channelDescription: 'Prayer time reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    final platformDetails = NotificationDetails(android: androidDetails);

    int id = 0;
    for (final entry in prayerDateTimes.entries) {
      final name = entry.key;
      final dt = entry.value;
      if (!enabled[name] ?? false) continue;
      if (dt.isBefore(DateTime.now())) continue; // skip past
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id++,
        '$name Prayer',
        "It's time for $name prayer",
        tz.TZDateTime.from(dt, tz.local),
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}
