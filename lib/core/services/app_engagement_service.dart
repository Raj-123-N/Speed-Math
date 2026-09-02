import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores lightweight local engagement state used for reminder scheduling.
class AppEngagementService {
  AppEngagementService._();
  static final AppEngagementService instance = AppEngagementService._();

  static const _lastOpenKey = 'engagement_last_open';
  static const _openCountKey = 'engagement_open_count';

  Future<void> recordOpen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastOpenKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt(_openCountKey, (prefs.getInt(_openCountKey) ?? 0) + 1);
  }

  Future<DateTime?> lastOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_lastOpenKey);
    return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<int> openCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_openCountKey) ?? 0;
  }

  /// Produces a stable-but-varied daily reminder slot from the calendar day.
  int reminderHour(DateTime day) {
    final seed = day.year * 10000 + day.month * 100 + day.day;
    final random = Random(seed);
    return 8 + random.nextInt(11); // 08:00–18:59
  }
}
