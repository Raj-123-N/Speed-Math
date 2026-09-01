import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mensuration 3D Dedicated Shape Formulas View
// ─────────────────────────────────────────────────────────────────────────────

class Mensuration3dView extends StatelessWidget {
  const Mensuration3dView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  static const List<_Shape3dData> _shapes = [
    _Shape3dData(
      name: 'Cube',
      icon: Icons.view_in_ar_rounded,
      volume: 'V = a³',
      csa: 'LSA = 4a²',
      tsa: 'TSA = 6a²',
      extra: 'Diagonal d = a√3',
      color: Color(0xFF00C853),
    ),
    _Shape3dData(
      name: 'Cuboid',
      icon: Icons.check_box_outline_blank_rounded,
      volume: 'V = l × b × h',
      csa: 'LSA = 2h(l + b)',
      tsa: 'TSA = 2(lb + bh + hl)',
      extra: 'Diagonal d = √(l² + b² + h²)',
      color: Color(0xFF29B6F6),
    ),
    _Shape3dData(
      name: 'Right Circular Cylinder',
      icon: Icons.dns_outlined,
      volume: 'V = πr²h',
      csa: 'CSA = 2πrh',
      tsa: 'TSA = 2πr(r + h)',
      extra: 'Base Area = πr²',
      color: Color(0xFFFF6B2B),
    ),
    _Shape3dData(
      name: 'Right Circular Cone',
      icon: Icons.change_history_rounded,
      volume: 'V = ⅓ πr²h',
      csa: 'CSA = πrl',
      tsa: 'TSA = πr(l + r)',
      extra: 'Slant Height l = √(r² + h²)',
      color: Color(0xFF7B75FF),
    ),
    _Shape3dData(
      name: 'Sphere',
      icon: Icons.sports_volleyball_outlined,
      volume: 'V = 4/3 πr³',
      csa: 'Surface Area = 4πr²',
      tsa: 'TSA = 4πr²',
      extra: 'Curved and Total areas are identical',
      color: Color(0xFFE91E63),
    ),
    _Shape3dData(
      name: 'Hemisphere',
      icon: Icons.radio_button_checked_rounded,
      volume: 'V = ⅔ πr³',
      csa: 'CSA = 2πr²',
      tsa: 'TSA = 3πr²',
      extra: 'Base circle area = πr²',
      color: Color(0xFF8E24AA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      itemCount: _shapes.length,
      itemBuilder: (context, i) {
        final s = _shapes[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
              // Header
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
                      s.name,
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
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FormulaPill3D(
                            label: 'VOLUME',
                            formula: s.volume,
                            color: s.color,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _FormulaPill3D(
                            label: 'CSA / LSA',
                            formula: s.csa,
                            color: s.color,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _FormulaPill3D(
                            label: 'TSA',
                            formula: s.tsa,
                            color: s.color,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    if (s.extra.isNotEmpty) ...[
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
                          '💡 ${s.extra}',
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

class _FormulaPill3D extends StatelessWidget {
  const _FormulaPill3D({
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
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formula,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Shape3dData {
  const _Shape3dData({
    required this.name,
    required this.icon,
    required this.volume,
    required this.csa,
    required this.tsa,
    required this.extra,
    required this.color,
  });
  final String name;
  final IconData icon;
  final String volume;
  final String csa;
  final String tsa;
  final String extra;
  final Color color;
}
