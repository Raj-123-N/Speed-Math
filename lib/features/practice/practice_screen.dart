import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/models/quiz_category.dart';
import '../../core/widgets/speed_app_bar.dart';
import 'widgets/math_category_card.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F7);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bg,
        appBar: const SpeedMathAppBar(title: 'Practice Topics'),
        body: Column(
          children: [
            // Custom TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                labelStyle: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Quick Recall'),
                  Tab(text: 'Basics'),
                  Tab(text: 'Miscellaneous'),
                ],
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _CategoryGrid(
                    title: 'Quick Recall',
                    count: QuizCategory.quickRecall.length,
                    sectionColor: const Color(0xFFF97316),
                    categories: QuizCategory.quickRecall,
                    isDark: isDark,
                  ),
                  _CategoryGrid(
                    title: 'Basics',
                    count: QuizCategory.basics.length,
                    sectionColor: const Color(0xFF22C55E),
                    categories: QuizCategory.basics,
                    isDark: isDark,
                  ),
                  _CategoryGrid(
                    title: 'Miscellaneous',
                    count: QuizCategory.miscellaneous.length,
                    sectionColor: const Color(0xFF8B5CF6),
                    categories: QuizCategory.miscellaneous,
                    isDark: isDark,
                  ),
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
  const _CategoryGrid({
    required this.title,
    required this.count,
    required this.sectionColor,
    required this.categories,
    required this.isDark,
  });

  final String title;
  final int count;
  final Color sectionColor;
  final List<QuizCategory> categories;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: sectionColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title.toUpperCase(),
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 16,
                    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sectionColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: sectionColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
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
              (context, index) {
                return MathCategoryCard(
                  category: categories[index],
                  isDark: isDark,
                );
              },
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }
}
