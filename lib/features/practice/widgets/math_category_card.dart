import 'package:flutter/material.dart';
import '../../../core/models/quiz_category.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../screens/practice_setup_screen.dart';

class MathCategoryCard extends StatelessWidget {
  const MathCategoryCard({super.key, required this.category, required this.isDark});
  final QuizCategory category;
  final bool isDark;

  Color get _sectionColor {
    switch (category.section) {
      case PracticeSection.basics: return const Color(0xFF22C55E);
      case PracticeSection.quickRecall: return const Color(0xFFF97316);
      case PracticeSection.miscellaneous: return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _sectionColor;
    return Semantics(
      button: true,
      label: 'Practice ${category.name}',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeSetupScreen(category: category))),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: .7),
            boxShadow: isDark ? [] : [BoxShadow(color: accent.withValues(alpha: .08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              Positioned(top: 0, left: 0, right: 0, child: Container(height: 4, color: accent.withValues(alpha: .85))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), child: Row(children: [
                Container(width: 44, height: 44, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Image.asset(category.iconAsset, errorBuilder: (_, _, _) => Icon(Icons.calculate_rounded, color: accent))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(category.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.titleMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 13, height: 1.2)), const SizedBox(height: 3), Text(category.isAdvanced ? 'Advanced drill' : 'Custom drill', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: accent))])),
                Icon(Icons.chevron_right_rounded, color: accent, size: 22),
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}
