import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mensuration 2D Dedicated Shape Formulas View
// ─────────────────────────────────────────────────────────────────────────────

class Mensuration2dView extends StatelessWidget {
  const Mensuration2dView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  static const List<_Shape2dData> _shapes = [
    _Shape2dData(
      name: 'Square',
      icon: Icons.crop_square_rounded,
      area: 'Area = a²',
      perimeter: 'Perimeter = 4a',
      extra: 'Diagonal d = a√2',
      color: Color(0xFF00C853),
    ),
    _Shape2dData(
      name: 'Rectangle',
      icon: Icons.rectangle_outlined,
      area: 'Area = l × b',
      perimeter: 'Perimeter = 2(l + b)',
      extra: 'Diagonal d = √(l² + b²)',
      color: Color(0xFF29B6F6),
    ),
    _Shape2dData(
      name: 'Right-Angled Triangle',
      icon: Icons.change_history_rounded,
      area: 'Area = ½ × b × h',
      perimeter: 'Perimeter = a + b + c',
      extra: 'Hypotenuse c² = a² + b²',
      color: Color(0xFFFF6B2B),
    ),
    _Shape2dData(
      name: 'Equilateral Triangle',
      icon: Icons.details_rounded,
      area: 'Area = (√3 / 4) a²',
      perimeter: 'Perimeter = 3a',
      extra: 'Height h = (√3 / 2) a',
      color: Color(0xFF7B75FF),
    ),
    _Shape2dData(
      name: "Heron's Formula (Scalene)",
      icon: Icons.filter_hdr_rounded,
      area: 'Area = √[s(s-a)(s-b)(s-c)]',
      perimeter: 'Perimeter = a + b + c',
      extra: 'Semi-perimeter s = (a + b + c) / 2',
      color: Color(0xFF00BFA5),
    ),
    _Shape2dData(
      name: 'Circle',
      icon: Icons.circle_outlined,
      area: 'Area = πr²',
      perimeter: 'Circumference = 2πr',
      extra: 'Diameter d = 2r | π ≈ 22/7',
      color: Color(0xFFE91E63),
    ),
    _Shape2dData(
      name: 'Semi-Circle',
      icon: Icons.pie_chart_outline_rounded,
      area: 'Area = ½ πr²',
      perimeter: 'Perimeter = πr + 2r = r(π + 2)',
      extra: 'Perimeter ≈ (36/7)r',
      color: Color(0xFF8E24AA),
    ),
    _Shape2dData(
      name: 'Parallelogram',
      icon: Icons.crop_free_rounded,
      area: 'Area = base × height',
      perimeter: 'Perimeter = 2(a + b)',
      extra: 'Area = ab sin θ',
      color: Color(0xFF3949AB),
    ),
    _Shape2dData(
      name: 'Rhombus',
      icon: Icons.diamond_outlined,
      area: 'Area = ½ × d₁ × d₂',
      perimeter: 'Perimeter = 4a',
      extra: 'Side a = ½ √(d₁² + d₂²)',
      color: Color(0xFF00ACC1),
    ),
    _Shape2dData(
      name: 'Trapezium',
      icon: Icons.polyline_rounded,
      area: 'Area = ½ (a + b) × h',
      perimeter: 'Perimeter = Sum of all 4 sides',
      extra: 'a, b are parallel sides, h is distance',
      color: Color(0xFF43A047),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      itemCount: _shapes.length,
      itemBuilder: (context, i) {
        final shape = _shapes[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : shape.color.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: shape.color.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Icon(shape.icon, color: shape.color, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      shape.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Formulas
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FormulaPill(
                            label: 'AREA',
                            formula: shape.area,
                            color: shape.color,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FormulaPill(
                            label: 'PERIMETER',
                            formula: shape.perimeter,
                            color: shape.color,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    if (shape.extra.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          '💡 ${shape.extra}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FormulaPill extends StatelessWidget {
  const _FormulaPill({
    required this.label,
    required this.formula,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String formula;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDarkStrong : color.withValues(alpha: 0.20),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.tagText.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formula,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class _Shape2dData {
  const _Shape2dData({
    required this.name,
    required this.icon,
    required this.area,
    required this.perimeter,
    required this.extra,
    required this.color,
  });
  final String name;
  final IconData icon;
  final String area;
  final String perimeter;
  final String extra;
  final Color color;
}
