import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BODMAS & Simplification Dedicated View
// ─────────────────────────────────────────────────────────────────────────────

class BodmasView extends StatelessWidget {
  const BodmasView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  static const List<_BodmasStepData> _steps = [
    _BodmasStepData(
      letter: 'B',
      title: 'Brackets (Parentheses)',
      subtitle: 'Order: Vinculum (—) → Round ( ) → Curly { } → Square [ ]',
      example: 'Evaluate inside innermost brackets first: 4 × (3 + 2) = 4 × 5 = 20',
      color: Color(0xFFE91E63),
    ),
    _BodmasStepData(
      letter: 'O',
      title: 'Orders / "Of" / Exponents',
      subtitle: 'Powers (x²), Roots (√x), and mathematical "of" (e.g. 50% of 80)',
      example: '"Of" precedes division! 12 ÷ 2 of 3 = 12 ÷ 6 = 2 (not 18)',
      color: Color(0xFFFF6B2B),
    ),
    _BodmasStepData(
      letter: 'D',
      title: 'Division',
      subtitle: 'Division and Multiplication have EQUAL priority (evaluate Left-to-Right)',
      example: '24 ÷ 6 × 2 = (24 ÷ 6) × 2 = 4 × 2 = 8',
      color: Color(0xFF00C853),
    ),
    _BodmasStepData(
      letter: 'M',
      title: 'Multiplication',
      subtitle: 'Evaluated along with Division from Left-to-Right',
      example: '10 - 3 × 2 = 10 - 6 = 4',
      color: Color(0xFF29B6F6),
    ),
    _BodmasStepData(
      letter: 'A',
      title: 'Addition',
      subtitle: 'Addition and Subtraction have EQUAL priority (evaluate Left-to-Right)',
      example: '8 + 4 - 2 = 12 - 2 = 10',
      color: Color(0xFF7B75FF),
    ),
    _BodmasStepData(
      letter: 'S',
      title: 'Subtraction',
      subtitle: 'Final step in the order of operations hierarchy',
      example: '15 - 5 + 3 = (15 - 5) + 3 = 10 + 3 = 13',
      color: Color(0xFF8E24AA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      children: [
        // Top Banner
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hierarchy of Operations (BODMAS / VBODMAS)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Always evaluate from highest to lowest rank. For equal-ranked operations (÷ / × and + / -), always evaluate STRICTLY from LEFT TO RIGHT.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        // Step Cards
        ..._steps.map((step) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : step.color.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Big Letter Banner
                  Container(
                    width: 46,
                    height: 82,
                    decoration: BoxDecoration(
                      color: step.color.withValues(alpha: isDark ? 0.18 : 0.10),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
                      border: Border(right: BorderSide(color: step.color.withValues(alpha: 0.25))),
                    ),
                    child: Center(
                      child: Text(
                        step.letter,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: step.color,
                        ),
                      ),
                    ),
                  ),

                  // Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.subtitle,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Ex: ${step.example}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: step.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _BodmasStepData {
  const _BodmasStepData({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.example,
    required this.color,
  });

  final String letter;
  final String title;
  final String subtitle;
  final String example;
  final Color color;
}
