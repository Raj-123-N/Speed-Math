import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pythagorean Triplets Dedicated View
// ─────────────────────────────────────────────────────────────────────────────

class PythagoreanTripletsView extends StatelessWidget {
  const PythagoreanTripletsView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  static const List<_TripletCardData> _triplets = [
    _TripletCardData(
      baseTriplet: '3 - 4 - 5',
      formula: '3² + 4² = 9 + 16 = 25 = 5²',
      multiples: ['6-8-10 (×2)', '9-12-15 (×3)', '12-16-20 (×4)', '15-20-25 (×5)'],
      color: Color(0xFF00C853),
    ),
    _TripletCardData(
      baseTriplet: '5 - 12 - 13',
      formula: '5² + 12² = 25 + 144 = 169 = 13²',
      multiples: ['10-24-26 (×2)', '15-36-39 (×3)', '20-48-52 (×4)'],
      color: Color(0xFF29B6F6),
    ),
    _TripletCardData(
      baseTriplet: '8 - 15 - 17',
      formula: '8² + 15² = 64 + 225 = 289 = 17²',
      multiples: ['16-30-34 (×2)', '24-45-51 (×3)'],
      color: Color(0xFFFF6B2B),
    ),
    _TripletCardData(
      baseTriplet: '7 - 24 - 25',
      formula: '7² + 24² = 49 + 576 = 625 = 25²',
      multiples: ['14-48-50 (×2)', '21-72-75 (×3)'],
      color: Color(0xFF7B75FF),
    ),
    _TripletCardData(
      baseTriplet: '20 - 21 - 29',
      formula: '20² + 21² = 400 + 441 = 841 = 29²',
      multiples: ['40-42-58 (×2)'],
      color: Color(0xFF00BFA5),
    ),
    _TripletCardData(
      baseTriplet: '9 - 40 - 41',
      formula: '9² + 40² = 81 + 1600 = 1681 = 41²',
      multiples: ['18-80-82 (×2)'],
      color: Color(0xFFE91E63),
    ),
    _TripletCardData(
      baseTriplet: '12 - 35 - 37',
      formula: '12² + 35² = 144 + 1225 = 1369 = 37²',
      multiples: ['24-70-74 (×2)'],
      color: Color(0xFF8E24AA),
    ),
    _TripletCardData(
      baseTriplet: '11 - 60 - 61',
      formula: '11² + 60² = 121 + 3600 = 3721 = 61²',
      multiples: ['22-120-122 (×2)'],
      color: Color(0xFF3949AB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      children: [
        // Generator rule card
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt_rounded, color: accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pythagorean Triplet Generator Rule',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'For any integer m > 1, the three sides are:\n• 2m,  (m² - 1),  (m² + 1)  where (m² + 1) is hypotenuse.\nE.g. for m = 2: 4, 3, 5 | for m = 3: 6, 8, 10 | for m = 4: 8, 15, 17',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        // Triplet Cards
        ..._triplets.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : t.color.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: t.color.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: t.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t.baseTriplet,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          t.formula,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textHintDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Common Multiples Chips
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Common Exam Scaled Multiples:',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: t.multiples
                              .map((m) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isDark ? AppColors.borderDarkStrong : const Color(0xFFCBD5E1),
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Text(
                                      m,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _TripletCardData {
  const _TripletCardData({
    required this.baseTriplet,
    required this.formula,
    required this.multiples,
    required this.color,
  });

  final String baseTriplet;
  final String formula;
  final List<String> multiples;
  final Color color;
}
