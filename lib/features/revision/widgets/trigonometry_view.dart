import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Trigonometry Dedicated View (Standard Table, Identities & Ratios)
// ─────────────────────────────────────────────────────────────────────────────

class TrigonometryView extends StatefulWidget {
  const TrigonometryView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  @override
  State<TrigonometryView> createState() => _TrigonometryViewState();
}

class _TrigonometryViewState extends State<TrigonometryView> {
  int _selectedTab = 0; // 0: Standard Table, 1: Core Identities, 2: Complementary & Signs

  static const List<String> _tabs = [
    'Standard Table (0°–90°)',
    'Core Identities',
    'Angle Rules (CAST)',
  ];

  static const List<String> _angles = ['0°', '30°', '45°', '60°', '90°'];
  static const List<Map<String, String>> _tableData = [
    {'fn': 'sin θ', '0°': '0', '30°': '1/2', '45°': '1/√2', '60°': '√3/2', '90°': '1'},
    {'fn': 'cos θ', '0°': '1', '30°': '√3/2', '45°': '1/√2', '60°': '1/2', '90°': '0'},
    {'fn': 'tan θ', '0°': '0', '30°': '1/√3', '45°': '1', '60°': '√3', '90°': '∞ (ND)'},
    {'fn': 'cosec θ', '0°': '∞ (ND)', '30°': '2', '45°': '√2', '60°': '2/√3', '90°': '1'},
    {'fn': 'sec θ', '0°': '1', '30°': '2/√3', '45°': '√2', '60°': '2', '90°': '∞ (ND)'},
    {'fn': 'cot θ', '0°': '∞ (ND)', '30°': '√3', '45°': '1', '60°': '1/√3', '90°': '0'},
  ];

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final isDark = widget.isDark;

    return Column(
      children: [
        // Top sub-tab strip
        Container(
          height: 44,
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _tabs.length,
            itemBuilder: (context, i) {
              final isSelected = _selectedTab == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent
                        : (isDark ? AppColors.surfaceElevatedDark : const Color(0xFFEBEFF5)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Body Content
        Expanded(
          child: _selectedTab == 0
              ? _buildTableView(accent, isDark)
              : _selectedTab == 1
                  ? _buildIdentitiesView(accent, isDark)
                  : _buildAngleRulesView(accent, isDark),
        ),
      ],
    );
  }

  // ── Tab 0: Standard Table ──────────────────────────────────────────────────
  Widget _buildTableView(Color accent, bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      children: [
        // Memory trick card
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'sin θ values: √0/2, √1/2, √2/2, √3/2, √4/2 \n(0, 1/2, 1/√2, √3/2, 1) — cos θ is simply reverse order!',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Full Interactive Table Card
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  accent.withValues(alpha: isDark ? 0.18 : 0.10),
                ),
                dataRowMinHeight: 44,
                dataRowMaxHeight: 48,
                columnSpacing: 22,
                horizontalMargin: 16,
                columns: [
                  DataColumn(
                    label: Text(
                      'Ratio',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                  ),
                  ..._angles.map((a) => DataColumn(
                        label: Center(
                          child: Text(
                            a,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      )),
                ],
                rows: _tableData.map((row) {
                  final fn = row['fn']!;
                  final isPrimary = fn == 'sin θ' || fn == 'cos θ' || fn == 'tan θ';
                  return DataRow(
                    color: WidgetStateProperty.all(
                      isPrimary
                          ? Colors.transparent
                          : (isDark ? AppColors.surfaceElevatedDark : const Color(0xFFFAFBFD)),
                    ),
                    cells: [
                      DataCell(
                        Text(
                          fn,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: accent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ..._angles.map((a) {
                        final val = row[a]!;
                        return DataCell(
                          Center(
                            child: Text(
                              val,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab 1: Core Identities ────────────────────────────────────────────────
  Widget _buildIdentitiesView(Color accent, bool isDark) {
    const identities = [
      {'title': 'Pythagorean Identity 1', 'formula': 'sin² θ + cos² θ = 1', 'note': '⇒ sin²θ = 1 - cos²θ | cos²θ = 1 - sin²θ'},
      {'title': 'Pythagorean Identity 2', 'formula': '1 + tan² θ = sec² θ', 'note': '⇒ sec²θ - tan²θ = 1 | (secθ - tanθ) = 1/(secθ + tanθ)'},
      {'title': 'Pythagorean Identity 3', 'formula': '1 + cot² θ = cosec² θ', 'note': '⇒ cosec²θ - cot²θ = 1 | (cosecθ - cotθ) = 1/(cosecθ + cotθ)'},
      {'title': 'Quotient Identities', 'formula': 'tan θ = sin θ / cos θ\ncot θ = cos θ / sin θ', 'note': 'tan θ × cot θ = 1'},
      {'title': 'Reciprocal Identities', 'formula': 'cosec θ = 1 / sin θ\nsec θ = 1 / cos θ\ncot θ = 1 / tan θ', 'note': 'Multiplying pairs always yields 1'},
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      itemCount: identities.length,
      itemBuilder: (context, i) {
        final id = identities[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : accent.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                id['title']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  id['formula']!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                id['note']!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 2: Angle Rules & CAST ─────────────────────────────────────────────
  Widget _buildAngleRulesView(Color accent, bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      children: [
        // Complementary Angles
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complementary Angle Relations (90° - θ)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: accent),
              ),
              const SizedBox(height: 8),
              const Text(
                '• sin(90° - θ) = cos θ   |   cos(90° - θ) = sin θ\n'
                '• tan(90° - θ) = cot θ   |   cot(90° - θ) = tan θ\n'
                '• sec(90° - θ) = cosec θ |   cosec(90° - θ) = sec θ',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.6),
              ),
            ],
          ),
        ),

        // CAST Rule
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CAST Sign Rule for Quadrants',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: accent),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Q1 (0° to 90°): ALL positive (A)\n'
                '• Q2 (90° to 180°): SIN & cosec positive (S)\n'
                '• Q3 (180° to 270°): TAN & cot positive (T)\n'
                '• Q4 (270° to 360°): COS & sec positive (C)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
