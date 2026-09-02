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

class _PracticeScreenState extends State<PracticeScreen> {
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await PracticeProgressService.instance.currentStreak();
    if (mounted) {
      setState(() => _streak = streak);
    }
  }

  Future<void> _openProgress() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const PracticeProgressScreen(),
      ),
    );
    await _loadStreak();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F7);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: background,
        appBar: const SpeedMathAppBar(title: 'Practice Topics'),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: InkWell(
                onTap: _openProgress,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary.withValues(alpha: .22)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_fire_department_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$_streak day Practice streak', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to open calendar, history and badges',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                labelStyle: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'Quick Recall'),
                  Tab(text: 'Basics'),
                  Tab(text: 'Miscellaneous'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _CategoryGrid(categories: QuizCategory.quickRecall, isDark: isDark, title: 'Quick Recall', sectionColor: const Color(0xFFF97316)),
                  _CategoryGrid(categories: QuizCategory.basics, isDark: isDark, title: 'Basics', sectionColor: const Color(0xFF22C55E)),
                  _CategoryGrid(categories: QuizCategory.miscellaneous, isDark: isDark, title: 'Miscellaneous', sectionColor: const Color(0xFF8B5CF6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Container(width: 4, height: 24, decoration: BoxDecoration(color: sectionColor, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16, color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1E293B)),
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
