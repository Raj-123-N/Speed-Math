import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Algebra Basics Dedicated View
// ─────────────────────────────────────────────────────────────────────────────

class AlgebraBasicsView extends StatelessWidget {
  const AlgebraBasicsView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  static const List<_AlgebraSection> _sections = [
    _AlgebraSection(
      title: 'Core Algebraic Expansions',
      icon: Icons.functions_rounded,
      color: Color(0xFF00C853),
      formulas: [
        _AlgebraFormula('(a + b)²', 'a² + 2ab + b²', 'Square of a sum | (a+b)² = (a-b)² + 4ab'),
        _AlgebraFormula('(a - b)²', 'a² - 2ab + b²', 'Square of a difference | (a-b)² = (a+b)² - 4ab'),
        _AlgebraFormula('(a + b)(a - b)', 'a² - b²', 'Difference of two squares (rapid factorization)'),
        _AlgebraFormula('(a + b + c)²', 'a² + b² + c² + 2(ab + bc + ca)', '3-variable square expansion'),
        _AlgebraFormula('(a + b)³', 'a³ + 3a²b + 3ab² + b³ = a³ + b³ + 3ab(a + b)', 'Cube of sum expansion'),
        _AlgebraFormula('(a - b)³', 'a³ - 3a²b + 3ab² - b³ = a³ - b³ - 3ab(a - b)', 'Cube of difference expansion'),
        _AlgebraFormula('a³ + b³', '(a + b)(a² - ab + b²)', 'Sum of cubes factorization'),
        _AlgebraFormula('a³ - b³', '(a - b)(a² + ab + b²)', 'Difference of cubes factorization'),
      ],
    ),
    _AlgebraSection(
      title: 'Conditional Algebraic Identities',
      icon: Icons.bolt_rounded,
      color: Color(0xFF29B6F6),
      formulas: [
        _AlgebraFormula('a³ + b³ + c³ - 3abc', '(a + b + c)(a² + b² + c² - ab - bc - ca)', 'Standard 3-variable cubic expansion'),
        _AlgebraFormula('If a + b + c = 0', 'a³ + b³ + c³ = 3abc', 'Extremely high-frequency competitive exam rule!'),
        _AlgebraFormula('x + 1/x = k', 'x² + 1/x² = k² - 2\nx³ + 1/x³ = k³ - 3k', 'Instant power simplification technique'),
        _AlgebraFormula('x - 1/x = k', 'x² + 1/x² = k² + 2\nx³ - 1/x³ = k³ + 3k', 'Sign flip variant'),
      ],
    ),
    _AlgebraSection(
      title: 'Quadratic Equations (ax² + bx + c = 0)',
      icon: Icons.linear_scale_rounded,
      color: Color(0xFFFF6B2B),
      formulas: [
        _AlgebraFormula('Quadratic Formula', 'x = [ -b ± √(b² - 4ac) ] / (2a)', 'Roots of any quadratic equation'),
        _AlgebraFormula('Discriminant (D)', 'D = b² - 4ac', '• D > 0: Real & Distinct\n• D = 0: Real & Equal\n• D < 0: Complex / No Real Roots'),
        _AlgebraFormula('Sum of Roots (α + β)', 'α + β = -b / a', 'Direct coefficient relation'),
        _AlgebraFormula('Product of Roots (αβ)', 'α × β = c / a', 'Direct coefficient relation'),
        _AlgebraFormula('Form Quadratic Equation', 'x² - (Sum of Roots)x + (Product) = 0', 'x² - (α+β)x + αβ = 0'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      itemCount: _sections.length,
      itemBuilder: (context, i) {
        final s = _sections[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : s.color.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Icon(s.icon, color: s.color, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      s.title,
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
                  children: s.formulas.map((item) {
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
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: s.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.expansion,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          if (item.note.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.note,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textHintDark : AppColors.textSecondaryLight,
                                height: 1.3,
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

class _AlgebraSection {
  const _AlgebraSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.formulas,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<_AlgebraFormula> formulas;
}

class _AlgebraFormula {
  const _AlgebraFormula(this.label, this.expansion, this.note);
  final String label;
  final String expansion;
  final String note;
}
