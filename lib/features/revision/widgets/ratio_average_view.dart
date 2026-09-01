import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Ratio & Average Dedicated View
// ─────────────────────────────────────────────────────────────────────────────

class RatioAverageView extends StatelessWidget {
  const RatioAverageView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  static const List<_RatioEntryGroup> _groups = [
    _RatioEntryGroup(
      title: 'Ratio & Proportion Fundamentals',
      icon: Icons.pie_chart_rounded,
      color: Color(0xFF00C853),
      items: [
        _RatioItem('Ratio Definition', 'If a : b = m : n ⇒ a = mk, b = nk', 'k is the common multiplying constant'),
        _RatioItem('Fourth Proportional', 'If a : b :: c : d ⇒ d = (b × c) / a', 'Product of Extremes = Product of Means (ad = bc)'),
        _RatioItem('Third Proportional', 'Third prop to a & b is c = b² / a', 'Since a : b :: b : c ⇒ ac = b²'),
        _RatioItem('Mean Proportional', 'Mean prop between a & b = √(ab)', 'Also known as Geometric Mean'),
        _RatioItem('Duplicate / Triplicate', 'Duplicate = a² : b² | Triplicate = a³ : b³', 'Sub-duplicate = √a : √b | Sub-triplicate = ∛a : ∛b'),
      ],
    ),
    _RatioEntryGroup(
      title: 'Averages & Central Tendency',
      icon: Icons.analytics_rounded,
      color: Color(0xFF29B6F6),
      items: [
        _RatioItem('Simple Average', 'Average = Sum of all items / Total Count (n)', 'Sum = Average × Count'),
        _RatioItem('Weighted Average', 'Weighted Avg = Σ(w × x) / Σw', 'Used when groups have different sizes or weights'),
        _RatioItem('Inclusion / Exclusion Effect', 'New Avg = Old Avg ± (Diff / New Total)', 'Instant mental math for age/marks replacement'),
        _RatioItem('Mean, Median, Mode Relationship', 'Mode = 3(Median) - 2(Mean)', 'Crucial empirical formula for moderately skewed data'),
        _RatioItem('Consecutive Numbers Average', 'Avg = (First Term + Last Term) / 2', 'For any arithmetic progression (e.g. 1 to 100 avg = 50.5)'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      itemCount: _groups.length,
      itemBuilder: (context, i) {
        final g = _groups[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : g.color.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: g.color.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Icon(g.icon, color: g.color, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      g.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: g.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                          width: 0.6,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: g.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.formula,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          if (item.explanation.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.explanation,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textHintDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RatioEntryGroup {
  const _RatioEntryGroup({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<_RatioItem> items;
}

class _RatioItem {
  const _RatioItem(this.label, this.formula, this.explanation);
  final String label;
  final String formula;
  final String explanation;
}
