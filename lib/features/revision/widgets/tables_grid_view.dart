import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tables 2D Synchronized Scroll Grid View (Tables 2–100 × 1–10)
// ─────────────────────────────────────────────────────────────────────────────

class TablesGridView extends StatefulWidget {
  const TablesGridView({
    super.key,
    required this.accent,
    required this.isDark,
  });

  final Color accent;
  final bool isDark;

  @override
  State<TablesGridView> createState() => _TablesGridViewState();
}

class _TablesGridViewState extends State<TablesGridView> {
  // Two scroll controllers that are linked together so they always move in sync
  late final ScrollController _headerScrollCtrl;
  late final ScrollController _bodyScrollCtrl;

  static const int _firstTable = 2;
  static const int _lastTable = 100;
  static const int _rowCount = 10; // multipliers 1–10

  // Cell dimensions
  static const double _leftColWidth = 52.0;
  static const double _headerHeight = 46.0;
  static const double _cellWidth = 78.0;
  static const double _cellHeight = 42.0;

  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _headerScrollCtrl = ScrollController();
    _bodyScrollCtrl = ScrollController();

    // Keep header and body in horizontal sync
    _headerScrollCtrl.addListener(_syncFromHeader);
    _bodyScrollCtrl.addListener(_syncFromBody);
  }

  void _syncFromHeader() {
    if (_syncing) return;
    if (!_bodyScrollCtrl.hasClients) return;
    _syncing = true;
    _bodyScrollCtrl.jumpTo(_headerScrollCtrl.offset);
    _syncing = false;
  }

  void _syncFromBody() {
    if (_syncing) return;
    if (!_headerScrollCtrl.hasClients) return;
    _syncing = true;
    _headerScrollCtrl.jumpTo(_bodyScrollCtrl.offset);
    _syncing = false;
  }

  @override
  void dispose() {
    _headerScrollCtrl.removeListener(_syncFromHeader);
    _bodyScrollCtrl.removeListener(_syncFromBody);
    _headerScrollCtrl.dispose();
    _bodyScrollCtrl.dispose();
    super.dispose();
  }

  Color get _accent => widget.accent;
  bool get _isDark => widget.isDark;

  Color get _headerBg => _isDark
      ? AppColors.surfaceElevatedDark
      : _accent.withValues(alpha: 0.08);

  Color get _leftColBg => _isDark
      ? const Color(0xFF1A1D26)
      : _accent.withValues(alpha: 0.12);

  Color _rowBg(int rowIdx) {
    if (_isDark) {
      return rowIdx.isEven ? AppColors.surfaceElevatedDark : AppColors.cardDark;
    }
    return rowIdx.isEven
        ? _accent.withValues(alpha: 0.04)
        : Colors.white;
  }

  static const List<int> _rangeStarts = [2, 11, 21, 31, 41, 51, 61, 71, 81, 91];
  int _activeStart = 2;

  void _jumpTo(int tableNum) {
    setState(() => _activeStart = tableNum);
    final colIdx = (tableNum - _firstTable).clamp(0, _lastTable - _firstTable);
    final targetOffset = colIdx * _cellWidth;
    if (_bodyScrollCtrl.hasClients) {
      _bodyScrollCtrl.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCols = _lastTable - _firstTable + 1; // 99 columns

    return Column(
      children: [
        // ── Quick Jump Range Chips Bar ──────────────────────────────────────
        Container(
          height: 42,
          margin: const EdgeInsets.only(top: 6, bottom: 4),
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              // All 2-100 Chip
              GestureDetector(
                onTap: () => _jumpTo(2),
                child: Container(
                  margin: const EdgeInsets.only(right: 6, top: 2, bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _activeStart == 2
                        ? _accent
                        : (_isDark ? AppColors.surfaceElevatedDark : const Color(0xFFEBEFF5)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _activeStart == 2
                        ? [
                            BoxShadow(
                              color: _accent.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'All 2–100',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _activeStart == 2
                            ? Colors.white
                            : (_isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ),
              ),
              // Segment chips (11-20, 21-30, etc.)
              ..._rangeStarts.skip(1).map((start) {
                final end = (start + 9).clamp(2, 100);
                final isSelected = _activeStart == start;
                return GestureDetector(
                  onTap: () => _jumpTo(start),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6, top: 2, bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _accent
                          : (_isDark ? AppColors.surfaceElevatedDark : const Color(0xFFEBEFF5)),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$start–$end',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (_isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // ── Header row + table grid ─────────────────────────────────────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Fixed left column ─────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Corner cell (×)
                  Container(
                    width: _leftColWidth,
                    height: _headerHeight,
                    decoration: BoxDecoration(
                      color: _isDark
                          ? AppColors.cardDark
                          : _accent.withValues(alpha: 0.18),
                      border: Border(
                        right: BorderSide(
                          color: _isDark
                              ? AppColors.borderDarkStrong
                              : _accent.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        bottom: BorderSide(
                          color: _isDark
                              ? AppColors.borderDarkStrong
                              : _accent.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '\u00D7',
                        style: AppTypography.titleLarge.copyWith(
                          color: _accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),

                  // Fixed multiplier rows 1–10
                  ...List.generate(_rowCount, (rowIdx) {
                    final multiplier = rowIdx + 1;
                    return Container(
                      width: _leftColWidth,
                      height: _cellHeight,
                      decoration: BoxDecoration(
                        color: _leftColBg,
                        border: Border(
                          right: BorderSide(
                            color: _isDark
                                ? AppColors.borderDarkStrong
                                : _accent.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                          bottom: BorderSide(
                            color: _isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            width: 0.6,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '\u00D7$multiplier',
                          style: AppTypography.titleMedium.copyWith(
                            color: _accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),

              // ── Scrollable grid columns ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top sticky header (Table 2 → 100)
                    SizedBox(
                      height: _headerHeight,
                      child: ListView.builder(
                        controller: _headerScrollCtrl,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        itemCount: totalCols,
                        itemBuilder: (_, colIdx) {
                          final tableNum = _firstTable + colIdx;
                          final isMilestone = tableNum % 10 == 0;
                          return Container(
                            width: _cellWidth,
                            height: _headerHeight,
                            decoration: BoxDecoration(
                              color: isMilestone
                                  ? _accent.withValues(
                                      alpha: _isDark ? 0.25 : 0.15)
                                  : _headerBg,
                              border: Border(
                                right: BorderSide(
                                  color: _isDark
                                      ? AppColors.borderDarkStrong
                                      : _accent.withValues(alpha: 0.2),
                                  width: isMilestone ? 1.5 : 0.6,
                                ),
                                bottom: BorderSide(
                                  color: _isDark
                                      ? AppColors.borderDarkStrong
                                      : _accent.withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$tableNum',
                                  style: AppTypography.headlineMedium.copyWith(
                                    color: isMilestone
                                        ? _accent
                                        : (_isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'TABLE',
                                  style: AppTypography.tagText.copyWith(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: _accent.withValues(alpha: 0.8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Grid body (rows 1–10 for each column)
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _bodyScrollCtrl,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: totalCols * _cellWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(_rowCount, (rowIdx) {
                              final multiplier = rowIdx + 1;
                              return SizedBox(
                                height: _cellHeight,
                                child: Row(
                                  children: List.generate(totalCols, (colIdx) {
                                    final tableNum = _firstTable + colIdx;
                                    final product = tableNum * multiplier;
                                    final isMilestone = tableNum % 10 == 0;

                                    return Container(
                                      width: _cellWidth,
                                      height: _cellHeight,
                                      decoration: BoxDecoration(
                                        color: isMilestone
                                            ? _accent.withValues(
                                                alpha: _isDark ? 0.08 : 0.04)
                                            : _rowBg(rowIdx),
                                        border: Border(
                                          right: BorderSide(
                                            color: _isDark
                                                ? AppColors.borderDark
                                                : AppColors.borderLight,
                                            width: isMilestone ? 1.5 : 0.5,
                                          ),
                                          bottom: BorderSide(
                                            color: _isDark
                                                ? AppColors.borderDark
                                                : AppColors.borderLight,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$product',
                                              style: AppTypography.titleLarge
                                                  .copyWith(
                                                fontSize: 14,
                                                fontWeight: isMilestone
                                                    ? FontWeight.w900
                                                    : FontWeight.w700,
                                                color: isMilestone
                                                    ? _accent
                                                    : (_isDark
                                                        ? AppColors
                                                            .textPrimaryDark
                                                        : AppColors
                                                            .textPrimaryLight),
                                              ),
                                            ),
                                            Text(
                                              '$tableNum\u00D7$multiplier',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w500,
                                                color: _isDark
                                                    ? AppColors.textHintDark
                                                    : AppColors.textHintLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
