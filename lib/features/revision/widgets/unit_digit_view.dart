import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Unit Digit Method Dedicated View
// ─────────────────────────────────────────────────────────────────────────────

class UnitDigitView extends StatelessWidget {
  const UnitDigitView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  static const List<_UnitDigitGroup> _groups = [
    _UnitDigitGroup(
      title: 'Cyclicity = 1 (Fixed Ending Digits)',
      subtitle: 'Always ends in the EXACT same digit for ANY positive integer power',
      color: Color(0xFF00C853),
      items: [
        '0ⁿ → Ends in 0  (e.g. 10⁴⁵ = ...0)',
        '1ⁿ → Ends in 1  (e.g. 21⁸⁹ = ...1)',
        '5ⁿ → Ends in 5  (e.g. 75³⁴ = ...5)',
        '6ⁿ → Ends in 6  (e.g. 36¹² = ...6)',
      ],
    ),
    _UnitDigitGroup(
      title: 'Cyclicity = 2 (Odd / Even Power Alternation)',
      subtitle: 'Result depends solely on whether the exponent is Odd or Even',
      color: Color(0xFF29B6F6),
      items: [
        '4^(odd) = 4  |  4^(even) = 6  (e.g. 4³ = 64, 4⁴ = 256)',
        '9^(odd) = 9  |  9^(even) = 1  (e.g. 9³ = 729, 9⁴ = 6561)',
      ],
    ),
    _UnitDigitGroup(
      title: 'Cyclicity = 4 (Divide Exponent by 4)',
      subtitle: 'Divide exponent by 4 and use the remainder as the new exponent (if rem=0, use power 4)',
      color: Color(0xFFFF6B2B),
      items: [
        'Base 2: 2¹=2, 2²=4, 2³=8, 2⁴=6  (Pattern: 2, 4, 8, 6)',
        'Base 3: 3¹=3, 3²=9, 3³=7, 3⁴=1  (Pattern: 3, 9, 7, 1)',
        'Base 7: 7¹=7, 7²=9, 7³=3, 7⁴=1  (Pattern: 7, 9, 3, 1)',
        'Base 8: 8¹=8, 8²=4, 8³=2, 8⁴=6  (Pattern: 8, 4, 2, 6)',
      ],
    ),
    _UnitDigitGroup(
      title: 'Factorials & Product Shortcuts',
      subtitle: 'Instant elimination rules for large exam expressions',
      color: Color(0xFF7B75FF),
      items: [
        'For any n ≥ 5, unit digit of n! is ALWAYS 0  (contains 2 × 5)',
        'Any Even Number × (...5) = ...0',
        'Any Odd Number × (...5) = ...5',
        'Sum of factorials 1! + 2! + 3! + 4! + 5! + ... = 1 + 2 + 6 + 24 + 0... = 33 ⇒ unit digit is 3 ✔',
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
          margin: const EdgeInsets.only(bottom: 14),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      g.subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: g.color,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: g.items
                      .map((item) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UnitDigitGroup {
  const _UnitDigitGroup({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.items,
  });

  final String title;
  final String subtitle;
  final Color color;
  final List<String> items;
}
