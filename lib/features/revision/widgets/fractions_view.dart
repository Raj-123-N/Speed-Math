import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../models/revision_models.dart';
import 'math_grid_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fractions: Grouped by Denominator
// ─────────────────────────────────────────────────────────────────────────────

class FractionsView extends StatelessWidget {
  const FractionsView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Group rows by denominator
    final Map<int, List<ContentRow>> grouped = {};
    for (final row in rows) {
      final parts = row.label.split('/');
      if (parts.length == 2) {
        final den = int.tryParse(parts[1]) ?? 0;
        grouped.putIfAbsent(den, () => []).add(row);
      }
    }

    final denominators = grouped.keys.toList()..sort();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: denominators.length,
      itemBuilder: (context, index) {
        final den = denominators[index];
        final familyRows = grouped[den]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Denominator: $den',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: familyRows.length,
              itemBuilder: (context, i) {
                final row = familyRows[i];
                return MathGridCell(
                  question: row.label,
                  answer: row.value,
                  sectionColor: accent,
                  isDark: isDark,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
