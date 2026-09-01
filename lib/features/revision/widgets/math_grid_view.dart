import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Squares / Cubes / Roots — Number Grid View
// 4 sections of 25 items each, with per-section color coding and card cells
// ─────────────────────────────────────────────────────────────────────────────

class MathGridView extends StatelessWidget {
  const MathGridView({
    super.key,
    required this.rows,
    required this.topicId,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final String topicId;
  final Color accent;
  final bool isDark;

  int get _crossCount => (topicId == 'cube_roots' || topicId == 'square_roots') ? 3 : 4;

  double get _aspectRatio => (topicId == 'cube_roots' || topicId == 'square_roots') ? 1.15 : 1.25;

  String _question(ContentRow row) {
    switch (topicId) {
      case 'squares':
      case 'all_squares':
        return '${row.label}\u00b2';
      case 'cubes':
        return '${row.label}\u00b3';
      case 'square_roots':
        return '\u221a${row.label}';
      case 'cube_roots':
        return '\u221b${row.label}';
      default:
        return row.label;
    }
  }

  String get _headerTitle {
    switch (topicId) {
      case 'squares':
      case 'all_squares':
        return 'Perfect Squares  1\u00b2 \u2192 100\u00b2';
      case 'cubes':
        return 'Perfect Cubes  1\u00b3 \u2192 100\u00b3';
      case 'square_roots':
        return 'Square Roots  \u221a1 \u2192 \u221a100';
      case 'cube_roots':
        return 'Cube Roots  \u221b1 \u2192 \u221b100';
      default:
        return '';
    }
  }

  static const List<Color> _sectionColors = [
    Color(0xFF00C853), // green  n=1-25
    Color(0xFF29B6F6), // sky    n=26-50
    Color(0xFFFF6B2B), // orange n=51-75
    Color(0xFF7B75FF), // indigo n=76-100
  ];

  @override
  Widget build(BuildContext context) {
    const sectionSize = 25;
    final sectionCount = (rows.length / sectionSize).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info header strip
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _headerTitle,
                  style: AppTypography.chipText.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${rows.length} values',
                style: AppTypography.tagText.copyWith(
                  color: isDark
                      ? AppColors.textHintDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),

        // Scrollable sectioned grid
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              for (int s = 0; s < sectionCount; s++) ...[
                // Section Range Header
                SliverToBoxAdapter(
                  child: GridSectionHeader(
                    start: s * sectionSize + 1,
                    end: ((s + 1) * sectionSize).clamp(0, rows.length),
                    color: _sectionColors[s % _sectionColors.length],
                    isDark: isDark,
                  ),
                ),

                // Grid of 25 cards
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, localIdx) {
                        final rowIdx = s * sectionSize + localIdx;
                        if (rowIdx >= rows.length) return null;
                        final row = rows[rowIdx];
                        return MathGridCell(
                          question: _question(row),
                          answer: row.value,
                          sectionColor: _sectionColors[s % _sectionColors.length],
                          isDark: isDark,
                        );
                      },
                      childCount: ((s + 1) * sectionSize).clamp(0, rows.length) -
                          s * sectionSize,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossCount,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: _aspectRatio,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual card cell in the math grid
// ─────────────────────────────────────────────────────────────────────────────

class MathGridCell extends StatelessWidget {
  const MathGridCell({
    super.key,
    required this.question,
    required this.answer,
    required this.sectionColor,
    required this.isDark,
  });

  final String question;
  final String answer;
  final Color sectionColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : sectionColor.withValues(alpha: 0.20),
          width: isDark ? 0.6 : 0.8,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: sectionColor.withValues(alpha: 0.07),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question chip  e.g. "12²" or "√144"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: sectionColor.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                question,
                style: AppTypography.tagText.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: sectionColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          // Answer value  e.g. "144" or "12"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                answer,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section range header  e.g. «  n = 1 – 25  ─────────── »
// ─────────────────────────────────────────────────────────────────────────────

class GridSectionHeader extends StatelessWidget {
  const GridSectionHeader({
    super.key,
    required this.start,
    required this.end,
    required this.color,
    required this.isDark,
  });

  final int start;
  final int end;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'n = $start \u2013 $end',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: isDark ? 0.25 : 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
