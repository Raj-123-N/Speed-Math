import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../services/practice_progress_service.dart';

class PracticeProgressScreen extends StatefulWidget {
  const PracticeProgressScreen({super.key});

  @override
  State<PracticeProgressScreen> createState() => _PracticeProgressScreenState();
}

class _PracticeProgressScreenState extends State<PracticeProgressScreen> {
  final _progress = PracticeProgressService.instance;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  Set<DateTime> _days = {};
  List<PracticeBadge> _badges = [];
  int _streak = 0;
  int _bestStreak = 0;
  List<PracticeSessionRecord> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final days = await _progress.practiceDays();
    final badges = await _progress.badges();
    final streak = await _progress.currentStreak();
    final best = await _progress.bestStreak();
    final history = await _progress.history();
    if (!mounted) return;
    setState(() {
      _days = days;
      _badges = badges;
      _streak = streak;
      _bestStreak = best;
      _history = history;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? AppColors.backgroundDark : const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: Text('Practice Progress', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900)),
        backgroundColor: dark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  _streakHero(dark),
                  const SizedBox(height: 14),
                  _calendar(dark),
                  const SizedBox(height: 18),
                  _badgesSection(dark),
                  const SizedBox(height: 18),
                  _recentSection(dark),
                ],
              ),
            ),
    );
  }

  Widget _streakHero(bool dark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: .18), AppColors.primary.withValues(alpha: .05)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: .22)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .14), shape: BoxShape.circle),
            child: const Icon(Icons.local_fire_department_rounded, size: 36, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_streak day streak', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Best: $_bestStreak days  •  ${_history.length} sessions', style: TextStyle(color: dark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(_streak == 0 ? 'Start today to build your streak.' : 'Keep today’s Practice habit alive.', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendar(bool dark) {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = (first.weekday - DateTime.monday) % 7;
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(DateFormat('MMMM yyyy').format(_month), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
              IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)), icon: const Icon(Icons.chevron_left_rounded)),
              IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)), icon: const Icon(Icons.chevron_right_rounded)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(child: Center(child: Text(d, style: TextStyle(fontWeight: FontWeight.w800, color: dark ? Colors.white54 : Colors.black45)))))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 4),
            itemBuilder: (_, index) {
              final dayNumber = index - leading + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) return const SizedBox.shrink();
              final day = DateTime(_month.year, _month.month, dayNumber);
              final practiced = _days.contains(day);
              final today = _sameDay(day, DateTime.now());
              return Container(
                decoration: BoxDecoration(
                  color: practiced ? AppColors.primary.withValues(alpha: .16) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: today ? Border.all(color: AppColors.primary, width: 1.5) : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$dayNumber', style: TextStyle(fontWeight: practiced ? FontWeight.w900 : FontWeight.w600)),
                      if (practiced) const Icon(Icons.check_rounded, size: 11, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _badgesSection(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BADGES', style: AppTypography.sectionHeader.copyWith(color: AppColors.primary, letterSpacing: 1.4)),
        const SizedBox(height: 8),
        ..._badges.map((badge) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: dark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: badge.unlocked ? AppColors.primary.withValues(alpha: .35) : (dark ? AppColors.borderDark : AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Text(badge.icon, style: TextStyle(fontSize: 28, color: badge.unlocked ? null : Colors.grey)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(badge.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Text(badge.description, style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : Colors.black54)),
                        if (!badge.unlocked) ...[
                          const SizedBox(height: 7),
                          LinearProgressIndicator(value: (badge.target <= 1 ? badge.progress.toDouble() : badge.progress.toDouble() / badge.target).clamp(0.0, 1.0).toDouble(), minHeight: 5),
                        ],
                      ],
                    ),
                  ),
                  if (badge.unlocked) const Icon(Icons.verified_rounded, color: AppColors.primary),
                ],
              ),
            )),
      ],
    );
  }

  Widget _recentSection(bool dark) {
    final recent = _history.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECENT PRACTICE', style: AppTypography.sectionHeader.copyWith(color: AppColors.primary, letterSpacing: 1.4)),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: dark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Text('Your completed sessions will appear here.'),
          )
        else
          ...recent.map((r) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .12), child: const Icon(Icons.calculate_rounded, color: AppColors.primary)),
                title: Text(r.topicName, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${DateFormat('MMM d').format(r.date)} • ${r.questions} questions • ${r.elapsedSeconds}s'),
                trailing: Text('${(r.accuracy * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
              )),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
