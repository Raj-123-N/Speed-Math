import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Premium section header with gradient accent pill + count badge + optional "See All" action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.onSeeAll,
    this.accentColor = AppColors.primary,
    this.horizontalMargin = 16.0,
    this.topMargin = 20.0,
    this.bottomMargin = 4.0,
  });

  final String title;
  final int? count;
  final VoidCallback? onSeeAll;
  final Color accentColor;
  final double horizontalMargin;
  final double topMargin;
  final double bottomMargin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        topMargin,
        horizontalMargin,
        bottomMargin,
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),

          // Title
          Text(
            title.toUpperCase(),
            style: AppTypography.sectionHeader.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),

          // Count badge
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: AppTypography.tagText.copyWith(color: accentColor),
              ),
            ),
          ],

          const Spacer(),

          // See All button
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: AppTypography.labelMedium.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: accentColor),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
