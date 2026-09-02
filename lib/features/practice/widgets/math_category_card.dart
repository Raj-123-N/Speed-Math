import 'package:flutter/material.dart';
import '../../../core/models/quiz_category.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../screens/practice_setup_screen.dart';

class MathCategoryCard extends StatefulWidget {
  const MathCategoryCard({super.key, required this.category, required this.isDark});
  final QuizCategory category;
  final bool isDark;

  @override
  State<MathCategoryCard> createState() => _MathCategoryCardState();
}

class _MathCategoryCardState extends State<MathCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 130), lowerBound: 0.93, upperBound: 1.0, value: 1.0);
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _accent {
    switch (widget.category.section) {
      case PracticeSection.basics:        return const Color(0xFF22C55E);
      case PracticeSection.quickRecall:   return const Color(0xFFF97316);
      case PracticeSection.miscellaneous: return const Color(0xFF8B5CF6);
    }
  }

  void _onTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PracticeSetupScreen(category: widget.category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final isDark = widget.isDark;

    return ScaleTransition(
      scale: _scale,
      child: Semantics(
        button: true,
        label: 'Practice ${widget.category.name}',
        child: GestureDetector(
          onTapDown: (_) => _ctrl.reverse(),
          onTapUp: (_) { _ctrl.forward(); _onTap(); },
          onTapCancel: () => _ctrl.forward(),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: .7),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(color: accent.withValues(alpha: .10), blurRadius: 14, offset: const Offset(0, 4)),
                      BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // top accent strip with gradient
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [accent, accent.withValues(alpha: .5)]),
                      ),
                    ),
                  ),
                  // subtle background tint
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent.withValues(alpha: isDark ? .04 : .03), Colors.transparent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            widget.category.iconAsset,
                            errorBuilder: (_, _, _) => Icon(Icons.calculate_rounded, color: accent),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.category.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.category.isAdvanced ? 'Advanced' : 'Standard',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: accent, letterSpacing: .3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: accent, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
