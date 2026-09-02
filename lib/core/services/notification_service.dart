import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app_engagement_service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _channelId = 'practice_reminders';
  static const _dailyIdBase = 41000;
  static const _smartIdBase = 42000;
  static const _notificationSetting = 'settings_notifications';
  static const _dailySetting = 'settings_daily_reminder';
  static const _smartSetting = 'settings_smart_reminder';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    tz.initializeTimeZones();
    try {
      final zoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zoneName));
    } catch (_) {}

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<DarwinInitializationSettings>();

    const channel = AndroidNotificationChannel(
      _channelId,
      'Practice reminders',
      description: 'Gentle reminders to keep practising learned maths topics.',
      importance: Importance.defaultImportance,
    );
    await androidPlugin?.createNotificationChannel(channel);
    _initialized = true;
  }

  Future<void> syncSchedules() async {
    if (kIsWeb) return;
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationSetting) ?? true;
    if (!enabled) {
      await cancelAll();
      return;
    }

    final daily = prefs.getBool(_dailySetting) ?? true;
    final smart = prefs.getBool(_smartSetting) ?? true;
    await cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
      final day = DateTime(now.year, now.month, now.day + dayOffset);
      if (daily) {
        final dailyTime = tz.TZDateTime(tz.local, day.year, day.month, day.day, 19);
        if (dailyTime.isAfter(now)) {
          await _schedule(_dailyIdBase + dayOffset, dailyTime, 'Keep your maths streak alive', 'A few minutes of Practice today keeps your learned skills sharp.');
        }
      }
      if (smart) {
        final hour = AppEngagementService.instance.reminderHour(day);
        final minute = (day.day * 17) % 60;
        final smartTime = tz.TZDateTime(tz.local, day.year, day.month, day.day, hour, minute);
        if (smartTime.isAfter(now) && !(hour == 19 && minute == 0)) {
          await _schedule(_smartIdBase + dayOffset, smartTime, 'Quick Practice break', 'You have learned the method. Now practise it again for speed and accuracy.');
        }
      }
    }
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationSetting, enabled);
    await syncSchedules();
  }

  Future<void> setDailyReminder(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailySetting, enabled);
    await syncSchedules();
  }

  Future<void> setSmartReminder(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_smartSetting, enabled);
    await syncSchedules();
  }

  Future<bool> isEnabled() async => (await SharedPreferences.getInstance()).getBool(_notificationSetting) ?? true;
  Future<bool> isDailyReminderEnabled() async => (await SharedPreferences.getInstance()).getBool(_dailySetting) ?? true;
  Future<bool> isSmartReminderEnabled() async => (await SharedPreferences.getInstance()).getBool(_smartSetting) ?? true;
  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _schedule(int id, tz.TZDateTime date, String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(_channelId, 'Practice reminders', channelDescription: 'Gentle reminders to keep practising learned maths topics.', importance: Importance.defaultImportance, priority: Priority.defaultPriority),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(id, title, body, date, details, androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }
}
