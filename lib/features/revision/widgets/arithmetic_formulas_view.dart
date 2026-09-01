import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Arithmetic Formulas Dedicated View (SI, CI, Profit & Loss, Discount)
// ─────────────────────────────────────────────────────────────────────────────

class ArithmeticFormulasView extends StatelessWidget {
  const ArithmeticFormulasView({
    super.key,
    required this.rows,
    required this.accent,
    required this.isDark,
  });

  final List<ContentRow> rows;
  final Color accent;
  final bool isDark;

  static const List<_FormulaCategoryData> _categories = [
    _FormulaCategoryData(
      title: 'Simple Interest (SI)',
      icon: Icons.percent_rounded,
      color: Color(0xFF00C853),
      items: [
        _FormulaEntry('SI Formula', 'SI = (P × R × T) / 100', 'P = Principal, R = Rate (% per annum), T = Time (years)'),
        _FormulaEntry('Total Amount', 'A = P + SI = P [ 1 + (RT / 100) ]', 'Sum of Principal and Simple Interest'),
        _FormulaEntry('Find Principal', 'P = (100 × SI) / (R × T)', 'Derived directly by rearranging terms'),
        _FormulaEntry('Find Rate', 'R = (100 × SI) / (P × T)', 'Useful when interest and time are given'),
      ],
    ),
    _FormulaCategoryData(
      title: 'Compound Interest (CI)',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF29B6F6),
      items: [
        _FormulaEntry('Annual Compounding', 'A = P [ 1 + (R / 100) ]ⁿ', 'CI = A - P = P [ (1 + R/100)ⁿ - 1 ]'),
        _FormulaEntry('Half-Yearly Compounding', 'A = P [ 1 + (R / 200) ]²ⁿ', 'Rate is halved (R/2) and time is doubled (2n)'),
        _FormulaEntry('Quarterly Compounding', 'A = P [ 1 + (R / 400) ]⁴ⁿ', 'Rate is divided by 4 and time is 4n'),
        _FormulaEntry('CI - SI Difference (2 Years)', 'Difference = P (R / 100)²', 'High-frequency competitive exam shortcut!'),
        _FormulaEntry('CI - SI Difference (3 Years)', 'Diff = P (R / 100)² [ 3 + (R / 100) ]', 'Standard formula for 3-year differences'),
      ],
    ),
    _FormulaCategoryData(
      title: 'Profit, Loss & Discount',
      icon: Icons.storefront_rounded,
      color: Color(0xFFFF6B2B),
      items: [
        _FormulaEntry('Profit % & Loss %', 'Profit% = (Profit / CP) × 100\nLoss% = (Loss / CP) × 100', 'Always computed on Cost Price (CP)'),
        _FormulaEntry('Selling Price (SP)', 'SP = CP × (100 ± P/L %) / 100', '(+) for Profit, (-) for Loss'),
        _FormulaEntry('Cost Price (CP)', 'CP = (SP × 100) / (100 ± P/L %)', 'Calculate original investment from SP'),
        _FormulaEntry('Successive Discounts', 'Net D% = [ a + b - (ab / 100) ] %', 'For 2 successive discounts of a% and b%'),
        _FormulaEntry('Faulty Weights (Cheating)', 'Gain% = [ Error / (True - Error) ] × 100', 'E.g., giving 900g instead of 1kg gives (100/900)×100 = 11.11%'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      itemCount: _categories.length,
      itemBuilder: (context, i) {
        final cat = _categories[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : cat.color.withValues(alpha: 0.25),
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
                  color: cat.color.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Icon(cat.icon, color: cat.color, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      cat.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Formula List
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: cat.items.map((item) {
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
                              color: cat.color,
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

class _FormulaCategoryData {
  const _FormulaCategoryData({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<_FormulaEntry> items;
}

class _FormulaEntry {
  const _FormulaEntry(this.label, this.formula, this.explanation);
  final String label;
  final String formula;
  final String explanation;
}
