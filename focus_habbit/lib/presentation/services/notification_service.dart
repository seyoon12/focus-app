import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      final initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          print('[📩] 알림 클릭됨: ${details.payload}');
          // TODO: 알림 클릭 시 동작 처리
        },
      );

      print('[✅] 알림 초기화 완료');
    } catch (e) {
      print('[❌] 알림 초기화 오류: $e');
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    final scheduledDate = tz.TZDateTime.local(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    const androidDetails = AndroidNotificationDetails(
      'habit_channel_id',
      'Habit Notifications',
      channelDescription: 'Habit reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );


    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate.isBefore(now) ? scheduledDate.add(Duration(days: 1)) : scheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'habit_payload',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ← 이 줄 추가
    );
  }
}
