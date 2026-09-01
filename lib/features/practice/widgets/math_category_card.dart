import 'package:flutter/material.dart';
import '../../../core/models/quiz_category.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class MathCategoryCard extends StatelessWidget {
  const MathCategoryCard({
    super.key,
    required this.category,
    required this.isDark,
  });

  final QuizCategory category;
  final bool isDark;

  Color get _sectionColor {
    switch (category.section) {
      case PracticeSection.basics:
        return const Color(0xFF22C55E); // Green
      case PracticeSection.quickRecall:
        return const Color(0xFFF97316); // Orange
      case PracticeSection.miscellaneous:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${category.name} practice is currently under construction!',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _sectionColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionColor = _sectionColor;

    return GestureDetector(
      onTap: () => _showComingSoon(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: sectionColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Top border line
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  color: sectionColor.withValues(alpha: 0.8),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: sectionColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        category.iconAsset,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.calculate_rounded, size: 24, color: sectionColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : const Color(0xFF1E293B),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              height: 1.2,
                            ),
                          ),
                          if (category.isAdvanced) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Advanced',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: sectionColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Chevron
                    Icon(
                      Icons.chevron_right_rounded,
                      color: sectionColor,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
