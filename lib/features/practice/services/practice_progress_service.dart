import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PracticeSessionRecord {
  const PracticeSessionRecord({required this.date, required this.topicId, required this.topicName, required this.plan, required this.questions, required this.correct, required this.elapsedSeconds, required this.accuracy});
  final DateTime date;
  final String topicId;
  final String topicName;
  final String plan;
  final int questions;
  final int correct;
  final int elapsedSeconds;
  final double accuracy;
  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'topicId': topicId, 'topicName': topicName, 'plan': plan, 'questions': questions, 'correct': correct, 'elapsedSeconds': elapsedSeconds, 'accuracy': accuracy};
  factory PracticeSessionRecord.fromJson(Map<String, dynamic> json) => PracticeSessionRecord(date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(), topicId: json['topicId'] as String? ?? 'unknown', topicName: json['topicName'] as String? ?? 'Practice', plan: json['plan'] as String? ?? '', questions: (json['questions'] as num?)?.toInt() ?? 0, correct: (json['correct'] as num?)?.toInt() ?? 0, elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0, accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0);
}

class PracticeBadge {
  const PracticeBadge({required this.id, required this.title, required this.description, required this.icon, required this.unlocked, this.progress = 0, this.target = 1});
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final int progress;
  final int target;
}

class PracticeProgressService {
  PracticeProgressService._();
  static final PracticeProgressService instance = PracticeProgressService._();
  static const _historyKey = 'practice_session_history_v2';

  Future<List<PracticeSessionRecord>> history() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.whereType<Map<String, dynamic>>().map(PracticeSessionRecord.fromJson).toList(growable: true);
    } catch (_) { return []; }
  }

  Future<void> recordSession({required String topicId, required String topicName, required String plan, required int questions, required int correct, required Duration elapsed}) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await history();
    final total = questions <= 0 ? 1 : questions;
    records.insert(0, PracticeSessionRecord(date: DateTime.now(), topicId: topicId, topicName: topicName, plan: plan, questions: questions, correct: correct, elapsedSeconds: elapsed.inSeconds, accuracy: correct / total));
    await prefs.setString(_historyKey, jsonEncode(records.take(500).map((e) => e.toJson()).toList()));
  }

  Future<Set<DateTime>> practiceDays() async => (await history()).map((r) => _day(r.date)).toSet();

  Future<int> currentStreak() async {
    final days = await practiceDays();
    if (days.isEmpty) return 0;
    var cursor = _day(DateTime.now());
    if (!days.contains(cursor)) cursor = cursor.subtract(const Duration(days: 1));
    var streak = 0;
    while (days.contains(cursor)) { streak++; cursor = cursor.subtract(const Duration(days: 1)); }
    return streak;
  }

  Future<int> bestStreak() async {
    final days = (await practiceDays()).toList()..sort();
    var best = 0, run = 0;
    DateTime? previous;
    for (final day in days) { run = previous != null && day.difference(previous!).inDays == 1 ? run + 1 : 1; best = maxInt(best, run); previous = day; }
    return best;
  }

  Future<List<PracticeBadge>> badges() async {
    final records = await history();
    final sessions = records.length;
    final days = records.map((r) => _day(r.date)).toSet();
    final streak = await currentStreak();
    final topicCounts = <String, int>{};
    for (final record in records) topicCounts[record.topicId] = (topicCounts[record.topicId] ?? 0) + 1;
    final bestTopicCount = topicCounts.values.isEmpty ? 0 : topicCounts.values.reduce(maxInt);
    final bestAccuracy = records.isEmpty ? 0.0 : records.map((r) => r.accuracy).reduce((a, b) => a > b ? a : b);
    final tableSessions = records.where((r) => r.topicId.toLowerCase().contains('table') || r.topicName.toLowerCase().contains('table')).length;
    final sequentialTableSessions = records.where((r) => (r.topicName.toLowerCase().contains('table')) && r.plan.toLowerCase().contains('sequential')).length;
    final longAccurateSessions = records.where((r) => r.questions >= 20 && r.accuracy >= .8).length;
    final hasFastSession = records.any((r) => r.questions >= 10 && r.elapsedSeconds > 0 && r.elapsedSeconds / r.questions <= 4);
    return [
      PracticeBadge(id: 'first_practice', title: 'First Rep', description: 'Complete your first Practice session.', icon: '🎯', unlocked: sessions >= 1, progress: sessions.clamp(0, 1), target: 1),
      PracticeBadge(id: 'ten_sessions', title: 'Regular', description: 'Complete 10 Practice sessions.', icon: '🔥', unlocked: sessions >= 10, progress: sessions.clamp(0, 10), target: 10),
      PracticeBadge(id: 'seven_day_streak', title: '7-Day Streak', description: 'Practice on 7 consecutive days.', icon: '📅', unlocked: streak >= 7, progress: streak.clamp(0, 7), target: 7),
      PracticeBadge(id: 'topic_specialist', title: 'Topic Specialist', description: 'Practice one topic 10 times.', icon: '🏅', unlocked: bestTopicCount >= 10, progress: bestTopicCount.clamp(0, 10), target: 10),
      PracticeBadge(id: 'table_focus', title: 'Table Focus', description: 'Complete 5 table-focused Practice sessions.', icon: '✖️', unlocked: tableSessions >= 5, progress: tableSessions.clamp(0, 5), target: 5),
      PracticeBadge(id: 'sequence_builder', title: 'Sequence Builder', description: 'Complete 5 sequential table plans.', icon: '🔢', unlocked: sequentialTableSessions >= 5, progress: sequentialTableSessions.clamp(0, 5), target: 5),
      PracticeBadge(id: 'deep_practice', title: 'Deep Practice', description: 'Complete five 20+ question sessions at 80%+ accuracy.', icon: '🧠', unlocked: longAccurateSessions >= 5, progress: longAccurateSessions.clamp(0, 5), target: 5),
      PracticeBadge(id: 'accuracy_master', title: 'Accuracy Master', description: 'Finish a session with at least 95% accuracy.', icon: '⭐', unlocked: bestAccuracy >= .95, progress: (bestAccuracy * 100).round().clamp(0, 95), target: 95),
      PracticeBadge(id: 'speed_starter', title: 'Speed Starter', description: 'Average 4 seconds or less per question in a 10+ question session.', icon: '⚡', unlocked: hasFastSession, progress: hasFastSession ? 1 : 0, target: 1),
      PracticeBadge(id: 'three_day_habit', title: 'Habit Builder', description: 'Practice on 3 different days.', icon: '🌱', unlocked: days.length >= 3, progress: days.length.clamp(0, 3), target: 3),
    ];
  }

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
  int maxInt(int a, int b) => a > b ? a : b;
}
