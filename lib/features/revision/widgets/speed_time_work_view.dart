import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Speed, Time & Work Dedicated View
// ─────────────────────────────────────────────────────────────────────────────

class SpeedTimeWorkView extends StatelessWidget {
  const SpeedTimeWorkView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  static const List<_StwGroupData> _groups = [
    _StwGroupData(
      title: 'Speed, Distance & Time',
      icon: Icons.speed_rounded,
      color: Color(0xFF00C853),
      items: [
        _StwItem('Core Formula', 'Speed = Distance / Time\nDistance = Speed × Time | Time = Distance / Speed', 'Fundamental relationship'),
        _StwItem('Unit Conversion (Crucial!)', '1 km/h = 5/18 m/s\n1 m/s = 18/5 km/h', 'To convert km/h to m/s, multiply by 5/18'),
        _StwItem('Average Speed (Equal Distances)', 'Avg Speed = (2 × u × v) / (u + v)', 'Harmonic mean for journey to & fro at speeds u and v'),
        _StwItem('Average Speed (General)', 'Avg Speed = Total Distance / Total Time', 'Used when distance or time segments differ'),
      ],
    ),
    _StwGroupData(
      title: 'Trains, Relative Speed & Boats',
      icon: Icons.train_rounded,
      color: Color(0xFF29B6F6),
      items: [
        _StwItem('Relative Speed (Opposite Direction)', 'Relative Speed = S₁ + S₂', 'When moving towards each other, speeds ADD'),
        _StwItem('Relative Speed (Same Direction)', 'Relative Speed = |S₁ - S₂|', 'When moving in same direction, speeds SUBTRACT'),
        _StwItem('Train Crossing Platform / Bridge', 'Time = (Length of Train + Length of Platform) / Speed', 'Distance is sum of both lengths'),
        _StwItem('Boats & Streams (Downstream / Upstream)', 'Downstream (d) = u + v | Upstream (s) = u - v\nBoat Speed u = (d + s) / 2 | Stream Speed v = (d - s) / 2', 'u = boat speed in still water, v = stream speed'),
      ],
    ),
    _StwGroupData(
      title: 'Time & Work / Pipes & Cisterns',
      icon: Icons.engineering_rounded,
      color: Color(0xFFFF6B2B),
      items: [
        _StwItem('Work Rate Principle', 'If A finishes in "a" days ⇒ 1 Day Work = 1/a', 'Work = Rate × Time'),
        _StwItem('A & B Working Together', 'Time Together = (a × b) / (a + b) days', 'Rate: 1/a + 1/b = (a+b)/ab'),
        _StwItem('Chain Rule (MDH Formula)', '(M₁ × D₁ × H₁) / W₁ = (M₂ × D₂ × H₂) / W₂', 'M=Men, D=Days, H=Hours/day, W=Work done'),
        _StwItem('Pipes & Cisterns (Fill & Leak)', 'Net Rate = (1 / Fill Time) - (1 / Drain Time)', 'Time = (a × b) / (b - a)  (if fill < drain)'),
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
          margin: const EdgeInsets.only(bottom: 16),
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
                child: Row(
                  children: [
                    Icon(g.icon, color: g.color, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      g.title,
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
                  children: g.items.map((item) {
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
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: g.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.formula,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          if (item.explanation.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.explanation,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textHintDark : AppColors.textSecondaryLight,
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

class _StwGroupData {
  const _StwGroupData({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<_StwItem> items;
}

class _StwItem {
  const _StwItem(this.label, this.formula, this.explanation);
  final String label;
  final String formula;
  final String explanation;
}
