import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/models/quiz_category.dart';
import '../../core/widgets/speed_app_bar.dart';
import 'screens/practice_progress_screen.dart';
import 'services/practice_progress_service.dart';
import 'widgets/math_category_card.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  int _streak = 0;
  int _selectedTab = 0;
  late AnimationController _tabController;
  late Animation<double> _fadeAnim;

  static const _tabs = ['Quick Recall', 'Basics', 'Miscellaneous'];
  static const _tabColors = [Color(0xFFF97316), Color(0xFF22C55E), Color(0xFF8B5CF6)];
  static const _tabIcons = [
    Icons.bolt_rounded,
    Icons.foundation_rounded,
    Icons.category_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _tabController, curve: Curves.easeOut));
    _tabController.forward();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await PracticeProgressService.instance.currentStreak();
    if (mounted) setState(() => _streak = streak);
  }

  Future<void> _openProgress() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const PracticeProgressScreen()),
    );
    await _loadStreak();
  }

  void _switchTab(int i) {
    if (i == _selectedTab) return;
    _tabController.forward(from: 0);
    setState(() => _selectedTab = i);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F7);
    final sectionColor = _tabColors[_selectedTab];

    final categories = [
      QuizCategory.quickRecall,
      QuizCategory.basics,
      QuizCategory.miscellaneous,
    ][_selectedTab];

    return Scaffold(
      backgroundColor: background,
      appBar: const SpeedMathAppBar(title: 'Practice'),
      body: Column(
        children: [
          // ── Streak Banner ──────────────────────────────────────────────
          _StreakBanner(streak: _streak, isDark: isDark, onTap: _openProgress),

          // ── Tab Selector ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 12, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) => Expanded(
                  child: _PillTab(
                    label: _tabs[i],
                    icon: _tabIcons[i],
                    selected: _selectedTab == i,
                    color: _tabColors[i],
                    isDark: isDark,
                    onTap: () => _switchTab(i),
                  ),
                )),
              ),
            ),
          ),

          // ── Category Grid ──────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _CategoryGrid(
                categories: categories,
                isDark: isDark,
                title: _tabs[_selectedTab],
                sectionColor: sectionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Streak Banner ────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak, required this.isDark, required this.onTap});
  final int streak;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2A1F0E), const Color(0xFF1A1D26)]
                    : [const Color(0xFFFFF7ED), const Color(0xFFFFF3E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF97316).withValues(alpha: .3)),
              boxShadow: isDark ? [] : [BoxShadow(color: const Color(0xFFF97316).withValues(alpha: .1), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _PulsingFire(streak: streak),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          streak == 0 ? 'Start your streak!' : '$streak day${streak == 1 ? '' : 's'} on fire 🔥',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textPrimaryDark : const Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to view calendar, history & badges',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : const Color(0xFFB45309)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: const Color(0xFFF97316).withValues(alpha: .8)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingFire extends StatefulWidget {
  const _PulsingFire({required this.streak});
  final int streak;
  @override
  State<_PulsingFire> createState() => _PulsingFireState();
}

class _PulsingFireState extends State<_PulsingFire> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF97316).withValues(alpha: .15),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 26),
    ),
  );
}

// ── Pill Tab ─────────────────────────────────────────────────────────────────

class _PillTab extends StatelessWidget {
  const _PillTab({required this.label, required this.icon, required this.selected, required this.color, required this.isDark, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        boxShadow: selected ? [BoxShadow(color: color.withValues(alpha: .3), blurRadius: 8, offset: const Offset(0, 3))] : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: selected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 3),
          Text(
            label.split(' ').first,
            style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: selected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ),
        ],
      ),
    ),
  );
}

// ── Category Grid ─────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.isDark, required this.title, required this.sectionColor});

  final List<QuizCategory> categories;
  final bool isDark;
  final String title;
  final Color sectionColor;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              children: [
                Container(width: 4, height: 22, decoration: BoxDecoration(color: sectionColor, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.4, fontSize: 15, color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1E293B)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: sectionColor.withValues(alpha: .15), borderRadius: BorderRadius.circular(12)),
                  child: Text('${categories.length}', style: TextStyle(color: sectionColor, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => MathCategoryCard(category: categories[index], isDark: isDark),
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }
}
