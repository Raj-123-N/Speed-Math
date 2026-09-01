import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../data/revision_content_data.dart';
import '../models/revision_models.dart';
import '../widgets/algebra_basics_view.dart';
import '../widgets/arithmetic_formulas_view.dart';
import '../widgets/bodmas_view.dart';
import '../widgets/fractions_view.dart';
import '../widgets/math_grid_view.dart';
import '../widgets/mensuration_2d_view.dart';
import '../widgets/mensuration_3d_view.dart';
import '../widgets/percentages_view.dart';
import '../widgets/powers_indices_view.dart';
import '../widgets/pythagorean_triplets_view.dart';
import '../widgets/ratio_average_view.dart';
import '../widgets/speed_time_work_view.dart';
import '../widgets/tables_grid_view.dart';
import '../widgets/trigonometry_view.dart';
import '../widgets/unit_digit_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Topic Detail Full Screen
// ─────────────────────────────────────────────────────────────────────────────

class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({
    super.key,
    required this.topic,
    required this.isDark,
    required this.accentColor,
    this.moduleTitle = '',
  });

  final LearnTopic topic;
  final bool isDark;
  final Color accentColor;
  final String moduleTitle;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accentColor;
    final rows = RevisionContentData.getRows(topic.id);
    final tips = RevisionContentData.getTips(topic.id);
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF4F6FA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.15 : 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                topic.icon,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(Icons.auto_stories_rounded, color: accent, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: AppTypography.titleLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.moduleTitle.isNotEmpty ? widget.moduleTitle : 'Speed Math Academy',
                    style: AppTypography.tagText.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFEBEFF5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabCtrl,
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              indicator: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w800),
              unselectedLabelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Reference'),
                Tab(text: 'Examples'),
                Tab(text: 'Tips & Tricks'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Reference tab
          _buildReferenceTab(rows, accent, isDark),
          // Examples tab
          _buildExamplesTab(rows, accent, isDark),
          // Tips tab
          _buildTipsTab(tips, isDark),
        ],
      ),
    );
  }

  Widget _buildReferenceTab(
    List<ContentRow> rows,
    Color accent,
    bool isDark,
  ) {
    final topicId = widget.topic.id;

    // 1. Tables: special 2D synchronized scroll grid
    if (topicId == 'tables' || topicId == 'all_tables') {
      return TablesGridView(accent: accent, isDark: isDark);
    }

    // 2. Squares / Cubes / Square Roots / Cube Roots
    if (topicId == 'squares' ||
        topicId == 'all_squares' ||
        topicId == 'cubes' ||
        topicId == 'square_roots' ||
        topicId == 'cube_roots') {
      return MathGridView(
        rows: rows,
        topicId: topicId,
        accent: accent,
        isDark: isDark,
      );
    }

    // 3. Powers & Indices: dedicated full-screen powers, laws, surds & shortcuts
    if (topicId == 'powers_roots') {
      return PowersIndicesView(accent: accent, isDark: isDark);
    }

    // 4. Fractions: denominator-grouped family view
    if (topicId == 'fractions') {
      return FractionsView(rows: rows, accent: accent, isDark: isDark);
    }

    // 5. Key Percentages: two-column cheat-sheet lookup
    if (topicId == 'key_percentages') {
      return PercentagesView(rows: rows, accent: accent, isDark: isDark);
    }

    // 6. Trigonometry & Full Trig Table
    if (topicId == 'trigonometry' || topicId == 'trig_full') {
      return TrigonometryView(rows: rows, accent: accent, isDark: isDark);
    }

    // 7. Mensuration 2D
    if (topicId == 'mensuration_2d') {
      return Mensuration2dView(rows: rows, accent: accent, isDark: isDark);
    }

    // 8. Mensuration 3D
    if (topicId == 'mensuration_3d') {
      return Mensuration3dView(rows: rows, accent: accent, isDark: isDark);
    }

    // 9. Pythagorean Triplets
    if (topicId == 'pythagorean') {
      return PythagoreanTripletsView(rows: rows, accent: accent, isDark: isDark);
    }

    // 10. Arithmetic (SI & CI, Profit & Loss)
    if (topicId == 'arithmetic') {
      return ArithmeticFormulasView(rows: rows, accent: accent, isDark: isDark);
    }

    // 11. Ratio & Average
    if (topicId == 'ratio_average') {
      return RatioAverageView(rows: rows, accent: accent, isDark: isDark);
    }

    // 12. Speed, Time & Work
    if (topicId == 'speed_time_work') {
      return SpeedTimeWorkView(rows: rows, accent: accent, isDark: isDark);
    }

    // 13. BODMAS & Simplification
    if (topicId == 'bodmas') {
      return BodmasView(rows: rows, accent: accent, isDark: isDark);
    }

    // 14. Unit Digit Method
    if (topicId == 'unit_digit') {
      return UnitDigitView(rows: rows, accent: accent, isDark: isDark);
    }

    // 15. Algebra Basics
    if (topicId == 'algebra_basics') {
      return AlgebraBasicsView(rows: rows, accent: accent, isDark: isDark);
    }

    if (rows.isEmpty) {
      return _EmptyTabMessage(
          message: 'Reference content coming soon', isDark: isDark);
    }

    // Fallback formula list
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: rows.length,
      itemBuilder: (_, i) {
        final row = rows[i];

        if (row.isDivider) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark
                ? (i.isEven ? AppColors.surfaceElevatedDark : AppColors.cardDark)
                : (i.isEven ? accent.withValues(alpha: 0.04) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.6,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent strip
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Index badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: AppTypography.tagText.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10)),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Content
                        Expanded(
                          child: Text(
                            row.display.isNotEmpty
                                ? row.display
                                : '${row.label}  =  ${row.value}',
                            style: TextStyle(
                              fontFamily: null,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamplesTab(List<ContentRow> exampleRows, Color accent, bool isDark) {
    final isTables = widget.topic.id == 'tables' || widget.topic.id == 'all_tables';

    if (exampleRows.isEmpty) {
      return _EmptyTabMessage(message: 'Examples coming soon', isDark: isDark);
    }

    if (isTables) {
      final trickColors = [
        AppColors.primary,
        AppColors.module2Color,
        AppColors.module3Color,
        AppColors.module4Color,
        AppColors.module5Color,
        AppColors.info,
        AppColors.accent,
      ];
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: exampleRows.length,
        itemBuilder: (_, i) {
          final row = exampleRows[i];
          final c = trickColors[i % trickColors.length];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.withValues(alpha: 0.35), width: 0.9),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                          color: c.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3)),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [c.withValues(alpha: isDark ? 0.25 : 0.12), c.withValues(alpha: isDark ? 0.1 : 0.04)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          row.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          row.label,
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Text(
                    row.display,
                    style: TextStyle(
                      fontFamily: null,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.7,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final examples = RevisionContentData.getExamples(widget.topic.id);
    if (examples.isEmpty) {
      return _EmptyTabMessage(message: 'Examples coming soon', isDark: isDark);
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: examples.length,
      itemBuilder: (_, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.3), width: 0.8),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8)
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calculate_rounded, color: accent, size: 16),
                    const SizedBox(width: 8),
                    Text('Example ${i + 1}',
                        style: AppTypography.chipText
                            .copyWith(color: accent, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  examples[i],
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipsTab(List<String> tips, bool isDark) {
    if (tips.isEmpty) {
      return _EmptyTabMessage(message: 'Tips coming soon', isDark: isDark);
    }

    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.accent
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: tips.length,
      itemBuilder: (_, i) {
        final c = colors[i % colors.length];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lightbulb_rounded, color: c, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tips[i],
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Tab Message
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyTabMessage extends StatelessWidget {
  const _EmptyTabMessage({required this.message, required this.isDark});
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty_rounded,
              size: 48,
              color: isDark
                  ? AppColors.textHintDark
                  : AppColors.textHintLight),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
