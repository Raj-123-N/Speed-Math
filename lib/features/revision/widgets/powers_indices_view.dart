import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Powers & Indices: Dedicated full-screen interactive reference
// ─────────────────────────────────────────────────────────────────────────────

class PowersIndicesView extends StatefulWidget {
  const PowersIndicesView({
    super.key,
    required this.accent,
    required this.isDark,
  });

  final Color accent;
  final bool isDark;

  @override
  State<PowersIndicesView> createState() => _PowersIndicesViewState();
}

class _PowersIndicesViewState extends State<PowersIndicesView> {
  int _selectedSubTab = 0; // 0: Powers (2-12), 1: Laws, 2: Surds, 3: Shortcuts
  int _selectedBase = 0; // 0: All bases, 2..12: specific base

  static const List<String> _subTabs = [
    'Powers (2–12)',
    'Laws of Indices',
    'Surds & Radicals',
    'Exam Shortcuts',
  ];

  static const List<int> _baseFilters = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final isDark = widget.isDark;

    return Column(
      children: [
        // ── Top Sub-Tab Navigation Strip ────────────────────────────────────
        Container(
          height: 44,
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _subTabs.length,
            itemBuilder: (context, i) {
              final isSelected = _selectedSubTab == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedSubTab = i),
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
                      _subTabs[i],
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

        // ── Sub-Tab Views ───────────────────────────────────────────────────
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildSubTabContent(accent, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabContent(Color accent, bool isDark) {
    switch (_selectedSubTab) {
      case 0:
        return _buildPowersTableView(accent, isDark);
      case 1:
        return _buildLawsOfIndicesView(accent, isDark);
      case 2:
        return _buildSurdsView(accent, isDark);
      case 3:
        return _buildExamShortcutsView(accent, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Tab 0: Powers Table (2 to 12) ──────────────────────────────────────────
  Widget _buildPowersTableView(Color accent, bool isDark) {
    final groups = _getPowerGroups();
    final displayedGroups = _selectedBase == 0
        ? groups
        : groups.where((g) => g.base == _selectedBase).toList();

    return Column(
      key: const ValueKey('tab_powers'),
      children: [
        // Base Quick Jump Bar
        Container(
          height: 36,
          margin: const EdgeInsets.fromLTRB(14, 2, 14, 6),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _baseFilters.length,
            itemBuilder: (context, i) {
              final b = _baseFilters[i];
              final isSel = _selectedBase == b;
              return GestureDetector(
                onTap: () => setState(() => _selectedBase = b),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel
                        ? accent.withValues(alpha: 0.18)
                        : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSel
                          ? accent
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: isSel ? 1.2 : 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      b == 0 ? 'All Bases' : '$bⁿ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                        color: isSel
                            ? accent
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // List of Base Groups
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
            itemCount: displayedGroups.length,
            itemBuilder: (context, idx) {
              final g = displayedGroups[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : g.color.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: g.color.withValues(alpha: isDark ? 0.05 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                      decoration: BoxDecoration(
                        color: g.color.withValues(alpha: isDark ? 0.12 : 0.07),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: g.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Base ${g.base}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                if (g.tagline.isNotEmpty)
                                  Text(
                                    g.tagline,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textHintDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grid of power items
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: g.items.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.35,
                        ),
                        itemBuilder: (context, i) {
                          final item = g.items[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceElevatedDark
                                  : g.color.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : g.color.withValues(alpha: 0.15),
                                width: 0.6,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Expression badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: g.color.withValues(alpha: isDark ? 0.20 : 0.12),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    item.exponent,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: g.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                // Value
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      item.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                ),
                                if (item.note.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Text(
                                      item.note,
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.textHintDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Tab 1: Laws of Indices ────────────────────────────────────────────────
  Widget _buildLawsOfIndicesView(Color accent, bool isDark) {
    final laws = _getLawsOfIndices();

    return ListView.builder(
      key: const ValueKey('tab_laws'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      itemCount: laws.length,
      itemBuilder: (context, i) {
        final law = laws[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : law.color.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: law.color.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: law.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        law.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        law.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Formula Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceElevatedDark
                            : const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDarkStrong
                              : law.color.withValues(alpha: 0.2),
                          width: 0.6,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          law.formula,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            color: law.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Explanation
                    Text(
                      law.explanation,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Example strip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : law.color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border(
                          left: BorderSide(color: law.color, width: 3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Ex: ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: law.color,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              law.example,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
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
          ),
        );
      },
    );
  }

  // ── Tab 2: Surds & Radicals ───────────────────────────────────────────────
  Widget _buildSurdsView(Color accent, bool isDark) {
    final surds = _getSurdRules();

    return ListView.builder(
      key: const ValueKey('tab_surds'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      itemCount: surds.length,
      itemBuilder: (context, i) {
        final item = surds[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : item.color.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Rule ${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceElevatedDark
                            : const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDarkStrong
                              : item.color.withValues(alpha: 0.2),
                          width: 0.6,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item.formula,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: item.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.explanation,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : item.color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border(
                          left: BorderSide(color: item.color, width: 3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ex: ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: item.color,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.example,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
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
          ),
        );
      },
    );
  }

  // ── Tab 3: Exam Shortcuts ─────────────────────────────────────────────────
  Widget _buildExamShortcutsView(Color accent, bool isDark) {
    final shortcuts = _getExamShortcuts();

    return ListView.builder(
      key: const ValueKey('tab_shortcuts'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
      itemCount: shortcuts.length,
      itemBuilder: (context, i) {
        final s = shortcuts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : s.color.withValues(alpha: 0.25),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: s.color.withValues(alpha: isDark ? 0.05 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flash_on_rounded,
                          color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            s.summary,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: s.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceElevatedDark
                        : const Color(0xFFF9FAFD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      width: 0.6,
                    ),
                  ),
                  child: Text(
                    s.content,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : const Color(0xFF2D3748),
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Data Providers ────────────────────────────────────────────────────────
  List<_PowerGroupData> _getPowerGroups() {
    return const [
      _PowerGroupData(
        base: 2,
        title: 'Base 2 Powers (2¹ → 2¹²)',
        tagline: 'Binary & doubling sequence',
        color: Color(0xFF00C853),
        items: [
          _PowerItemData('2¹', '2', ''),
          _PowerItemData('2²', '4', ''),
          _PowerItemData('2³', '8', ''),
          _PowerItemData('2⁴', '16', 'Nibble'),
          _PowerItemData('2⁵', '32', ''),
          _PowerItemData('2⁶', '64', '8²'),
          _PowerItemData('2⁷', '128', ''),
          _PowerItemData('2⁸', '256', '1 Byte / 16²'),
          _PowerItemData('2⁹', '512', '8³'),
          _PowerItemData('2¹⁰', '1024', '1 Kilo / 32²'),
          _PowerItemData('2¹¹', '2048', ''),
          _PowerItemData('2¹²', '4096', '4K / 64² / 16³'),
        ],
      ),
      _PowerGroupData(
        base: 3,
        title: 'Base 3 Powers (3¹ → 3⁸)',
        tagline: 'Tripling powers & cube relations',
        color: Color(0xFF29B6F6),
        items: [
          _PowerItemData('3¹', '3', ''),
          _PowerItemData('3²', '9', ''),
          _PowerItemData('3³', '27', ''),
          _PowerItemData('3⁴', '81', '9²'),
          _PowerItemData('3⁵', '243', ''),
          _PowerItemData('3⁶', '729', '9³ / 27²'),
          _PowerItemData('3⁷', '2187', ''),
          _PowerItemData('3⁸', '6561', '81²'),
        ],
      ),
      _PowerGroupData(
        base: 4,
        title: 'Base 4 Powers (4¹ → 4⁶)',
        tagline: 'Equivalent to 2²ⁿ',
        color: Color(0xFFFF6B2B),
        items: [
          _PowerItemData('4¹', '4', '2²'),
          _PowerItemData('4²', '16', '2⁴'),
          _PowerItemData('4³', '64', '2⁶'),
          _PowerItemData('4⁴', '256', '2⁸'),
          _PowerItemData('4⁵', '1024', '2¹⁰'),
          _PowerItemData('4⁶', '4096', '2¹²'),
        ],
      ),
      _PowerGroupData(
        base: 5,
        title: 'Base 5 Powers (5¹ → 5⁶)',
        tagline: 'Always ends in 25 (for n≥2)',
        color: Color(0xFF7B75FF),
        items: [
          _PowerItemData('5¹', '5', ''),
          _PowerItemData('5²', '25', ''),
          _PowerItemData('5³', '125', ''),
          _PowerItemData('5⁴', '625', '25²'),
          _PowerItemData('5⁵', '3125', ''),
          _PowerItemData('5⁶', '15625', '125² / 25³'),
        ],
      ),
      _PowerGroupData(
        base: 6,
        title: 'Base 6 Powers (6¹ → 6⁵)',
        tagline: 'Always ends in 6',
        color: Color(0xFF00BFA5),
        items: [
          _PowerItemData('6¹', '6', ''),
          _PowerItemData('6²', '36', ''),
          _PowerItemData('6³', '216', ''),
          _PowerItemData('6⁴', '1296', '36²'),
          _PowerItemData('6⁵', '7776', ''),
        ],
      ),
      _PowerGroupData(
        base: 7,
        title: 'Base 7 Powers (7¹ → 7⁵)',
        tagline: 'Key prime powers in exams',
        color: Color(0xFFE91E63),
        items: [
          _PowerItemData('7¹', '7', ''),
          _PowerItemData('7²', '49', ''),
          _PowerItemData('7³', '343', ''),
          _PowerItemData('7⁴', '2401', '49²'),
          _PowerItemData('7⁵', '16807', ''),
        ],
      ),
      _PowerGroupData(
        base: 8,
        title: 'Base 8 Powers (8¹ → 8⁴)',
        tagline: 'Equivalent to 2³ⁿ',
        color: Color(0xFF8E24AA),
        items: [
          _PowerItemData('8¹', '8', '2³'),
          _PowerItemData('8²', '64', '2⁶'),
          _PowerItemData('8³', '512', '2⁹'),
          _PowerItemData('8⁴', '4096', '2¹²'),
        ],
      ),
      _PowerGroupData(
        base: 9,
        title: 'Base 9 Powers (9¹ → 9⁴)',
        tagline: 'Equivalent to 3²ⁿ',
        color: Color(0xFF3949AB),
        items: [
          _PowerItemData('9¹', '9', '3²'),
          _PowerItemData('9²', '81', '3⁴'),
          _PowerItemData('9³', '729', '3⁶ / 27²'),
          _PowerItemData('9⁴', '6561', '3⁸ / 81²'),
        ],
      ),
      _PowerGroupData(
        base: 10,
        title: 'Base 10 Powers (10¹ → 10⁸)',
        tagline: 'Decimal place value system',
        color: Color(0xFF00ACC1),
        items: [
          _PowerItemData('10¹', '10', 'Ten'),
          _PowerItemData('10²', '100', 'Hundred'),
          _PowerItemData('10³', '1,000', '1 Thousand (1K)'),
          _PowerItemData('10⁴', '10,000', '10 Thousand'),
          _PowerItemData('10⁵', '100,000', '1 Lakh / 100K'),
          _PowerItemData('10⁶', '1,000,000', '10 Lakh / 1 Million'),
          _PowerItemData('10⁷', '10,000,000', '1 Crore / 10 Million'),
          _PowerItemData('10⁸', '100,000,000', '10 Crore / 100 Million'),
        ],
      ),
      _PowerGroupData(
        base: 11,
        title: 'Base 11 Powers (11¹ → 11⁴)',
        tagline: 'Pascal Triangle row symmetry',
        color: Color(0xFF43A047),
        items: [
          _PowerItemData('11¹', '11', '1 1'),
          _PowerItemData('11²', '121', '1 2 1'),
          _PowerItemData('11³', '1331', '1 3 3 1'),
          _PowerItemData('11⁴', '14641', '1 4 6 4 1'),
        ],
      ),
      _PowerGroupData(
        base: 12,
        title: 'Base 12 Powers (12¹ → 12⁴)',
        tagline: 'Dozens & gross combinations',
        color: Color(0xFFFB8C00),
        items: [
          _PowerItemData('12¹', '12', 'Dozen'),
          _PowerItemData('12²', '144', 'Gross (12²)'),
          _PowerItemData('12³', '1728', 'Great Gross (12³)'),
          _PowerItemData('12⁴', '20736', '144²'),
        ],
      ),
    ];
  }

  List<_LawItemData> _getLawsOfIndices() {
    return const [
      _LawItemData(
        'Law 1',
        'Product of Powers',
        'aᵐ × aⁿ = aᵐ⁺ⁿ',
        'When multiplying terms with the same base, keep the base and ADD the exponents.',
        '2³ × 2⁴ = 2³⁺⁴ = 2⁷ = 128',
        Color(0xFF00C853),
      ),
      _LawItemData(
        'Law 2',
        'Quotient of Powers',
        'aᵐ / aⁿ = aᵐ⁻ⁿ',
        'When dividing terms with the same base, keep the base and SUBTRACT the exponents.',
        '3⁶ / 3² = 3⁶⁻² = 3⁴ = 81',
        Color(0xFF29B6F6),
      ),
      _LawItemData(
        'Law 3',
        'Power of a Power',
        '(aᵐ)ⁿ = aᵐⁿ',
        'When raising a power to another power, MULTIPLY the exponents together.',
        '(2³)² = 2³ˣ² = 2⁶ = 64',
        Color(0xFFFF6B2B),
      ),
      _LawItemData(
        'Law 4',
        'Power of a Product',
        '(ab)ⁿ = aⁿ × bⁿ',
        'A power outside parentheses applies to every factor inside the multiplication.',
        '(2 × 5)³ = 2³ × 5³ = 8 × 125 = 1000',
        Color(0xFF7B75FF),
      ),
      _LawItemData(
        'Law 5',
        'Power of a Quotient',
        '(a / b)ⁿ = aⁿ / bⁿ',
        'A power outside parentheses applies to both the numerator and the denominator.',
        '(6 / 2)³ = 6³ / 2³ = 216 / 8 = 27 (= 3³)',
        Color(0xFF00BFA5),
      ),
      _LawItemData(
        'Law 6',
        'Zero Exponent Rule',
        'a⁰ = 1  (for a ≠ 0)',
        'Any non-zero number raised to the power of zero is ALWAYS equal to 1.',
        '5⁰ = 1,  (-17)⁰ = 1,  (2026)⁰ = 1',
        Color(0xFFE91E63),
      ),
      _LawItemData(
        'Law 7',
        'Negative Exponent Rule',
        'a⁻ⁿ = 1 / aⁿ  &  (a/b)⁻ⁿ = (b/a)ⁿ',
        'A negative exponent means taking the reciprocal of the base and making the exponent positive.',
        '2⁻³ = 1 / 2³ = 1/8 = 0.125  |  (2/3)⁻² = (3/2)² = 9/4',
        Color(0xFF8E24AA),
      ),
      _LawItemData(
        'Law 8',
        'Fractional Exponent (Unit Roots)',
        'a^(1/n) = ⁿ√a',
        'A unit fractional exponent 1/n represents the n-th root of the number.',
        '64^(1/2) = √64 = 8  |  27^(1/3) = ∛27 = 3',
        Color(0xFF3949AB),
      ),
      _LawItemData(
        'Law 9',
        'General Fractional Exponent',
        'a^(m/n) = (ⁿ√a)ᵐ = ⁿ√(aᵐ)',
        'Take the n-th root FIRST, then raise to power m (keeps intermediate numbers smaller).',
        '16^(3/4) = (⁴√16)³ = 2³ = 8',
        Color(0xFF00ACC1),
      ),
      _LawItemData(
        'Law 10',
        'Power Inversion Principle',
        'If aˣ = b  \u21d2  a = b^(1/x)',
        'Moving an exponent to the other side of an equation turns it into its reciprocal.',
        'x³ = 125  \u21d2  x = 125^(1/3) = 5',
        Color(0xFF43A047),
      ),
      _LawItemData(
        'Law 11',
        'Base Equating Principle',
        'If aˣ = aʸ  \u21d2  x = y  (a ≠ 0, 1, -1)',
        'If bases on both sides are identical, their exponents MUST be equal.',
        '2^(2x + 1) = 32 = 2⁵  \u21d2  2x + 1 = 5  \u21d2  x = 2',
        Color(0xFFFB8C00),
      ),
      _LawItemData(
        'Law 12',
        'Exponent Equating Principle',
        'If xⁿ = yⁿ  \u21d2  x = y  (for odd n)',
        'If odd exponents match, bases are equal. If even, x = ±y.',
        'x³ = 2³  \u21d2  x = 2  |  x² = 2²  \u21d2  x = ±2',
        Color(0xFF5C6BC0),
      ),
    ];
  }

  List<_SurdRuleData> _getSurdRules() {
    return const [
      _SurdRuleData(
        'Product Rule for Radicals',
        '√(a × b) = √a × √b',
        'A root of a product can be split into the product of individual roots for simplification.',
        '√72 = √(36 × 2) = √36 × √2 = 6√2 ≈ 8.485',
        Color(0xFF00C853),
      ),
      _SurdRuleData(
        'Quotient Rule for Radicals',
        '√(a / b) = √a / √b',
        'A root of a fraction equals the root of the numerator divided by root of denominator.',
        '√(49 / 16) = √49 / √16 = 7/4 = 1.75',
        Color(0xFF29B6F6),
      ),
      _SurdRuleData(
        'Nested Root Identity',
        'ᵐ√(ⁿ√a) = ᵐⁿ√a',
        'Nested radical roots multiply their indices together into a single combined root.',
        '√(∛64) = ⁶√64 = 2',
        Color(0xFFFF6B2B),
      ),
      _SurdRuleData(
        'Monomial Rationalization',
        '1 / √a = √a / a',
        'Eliminate square roots from denominators by multiplying numerator & denominator by √a.',
        '1 / √2 = (1 × √2) / (√2 × √2) = √2 / 2 ≈ 0.707',
        Color(0xFF7B75FF),
      ),
      _SurdRuleData(
        'Conjugate Binomial Rationalization',
        '1 / (√a ± √b) = (√a ∓ √b) / (a - b)',
        'Multiply by the conjugate surd to apply the difference of squares identity (x+y)(x-y) = x²-y².',
        '1 / (√7 - √5) = (√7 + √5) / (7 - 5) = (√7 + √5) / 2',
        Color(0xFF00BFA5),
      ),
      _SurdRuleData(
        'Infinite Product Radical',
        '√(x√(x√(x... \u221e))) = x',
        'When an infinite sequence of square roots is multiplied together, the value is always x.',
        '√(13√(13√(13... \u221e))) = 13',
        Color(0xFFE91E63),
      ),
      _SurdRuleData(
        'Infinite Sum & Difference Radicals',
        '√(N ± √(N ± √(N... \u221e)))',
        'Factor N into consecutive integers a(a+1). For (+), answer is (a+1). For (-), answer is a.',
        '√(20 + √(20 + ...)) : 20 = 4×5 \u21d2 Answer is 5 ✔\n√(20 - √(20 - ...)) : 20 = 4×5 \u21d2 Answer is 4 ✔',
        Color(0xFF8E24AA),
      ),
      _SurdRuleData(
        'Finite Nested Radical Formula',
        '√(x√(x... n times)) = x^((2ⁿ - 1) / 2ⁿ)',
        'Computes the exact value when square roots are nested a finite number of n times.',
        '√(3√(3√(3))) [n=3] = 3^((2³ - 1)/2³) = 3^(7/8)',
        Color(0xFF3949AB),
      ),
    ];
  }

  List<_ShortcutData> _getExamShortcuts() {
    return const [
      _ShortcutData(
        'Comparing Exponents (HCF Method)',
        'Technique for ranking huge power expressions',
        'Problem: Which is largest among 2⁶⁰, 3⁴⁸, 4³⁶, 5²⁴ ?\n\n'
            'Step 1: Find HCF of exponents (60, 48, 36, 24) = 12\n'
            'Step 2: Express each term with common exponent 12:\n'
            '   • 2⁶⁰ = (2⁵)¹² = 32¹²\n'
            '   • 3⁴⁸ = (3⁴)¹² = 81¹²\n'
            '   • 4³⁶ = (4³)¹² = 64¹²\n'
            '   • 5²⁴ = (5²)¹² = 25¹²\n\n'
            'Step 3: Compare inner bases: 81 > 64 > 32 > 25\n'
            'Result: 3⁴⁸ is largest and 5²⁴ is smallest! ✔',
        Color(0xFF00C853),
      ),
      _ShortcutData(
        'Unit Digit Cyclicity Table',
        'Instant mental calculation of unit digits in powers',
        'To find the last digit of N^P:\n\n'
            '1. Cyclicity = 1 (Always ends in same digit):\n'
            '   • 0ⁿ \u2192 0,  1ⁿ \u2192 1,  5ⁿ \u2192 5,  6ⁿ \u2192 6\n\n'
            '2. Cyclicity = 2 (Depends on Odd/Even power):\n'
            '   • 4^(odd) = 4,  4^(even) = 6\n'
            '   • 9^(odd) = 9,  9^(even) = 1\n\n'
            '3. Cyclicity = 4 (Divide P by 4, take remainder):\n'
            '   • 2ⁿ: 2, 4, 8, 6\n'
            '   • 3ⁿ: 3, 9, 7, 1\n'
            '   • 7ⁿ: 7, 9, 3, 1\n'
            '   • 8ⁿ: 8, 4, 2, 6\n'
            '   (Note: If remainder is 0, use power 4).',
        Color(0xFF29B6F6),
      ),
      _ShortcutData(
        'Base Reduction Cheat Sheet',
        'Convert all composite terms to prime powers',
        'Exam simplifications become trivial when converted to base 2, 3, or 5:\n\n'
            '• Base 2: 4=2², 8=2³, 16=2⁴, 32=2⁵, 64=2⁶, 128=2⁷, 256=2⁸, 512=2⁹, 1024=2¹⁰\n'
            '• Base 3: 9=3², 27=3³, 81=3⁴, 243=3⁵, 729=3⁶\n'
            '• Base 5: 25=5², 125=5³, 625=5⁴, 3125=5⁵\n'
            '• Base 6: 36=6², 216=6³, 1296=6⁴\n'
            '• Base 7: 49=7², 343=7³, 2401=7⁴',
        Color(0xFFFF6B2B),
      ),
      _ShortcutData(
        'High-Yield Exam Traps',
        'Common mistakes tested in competitive exams',
        '❌ Trap 1: (-2)⁴ = +16, but -2⁴ = -(2⁴) = -16\n'
            'Parentheses matter! An exponent only applies to the negative sign if inside brackets.\n\n'
            '❌ Trap 2: (a + b)ⁿ ≠ aⁿ + bⁿ\n'
            'Powers DO NOT distribute over addition or subtraction!\n\n'
            '❌ Trap 3: a^(-n) does NOT make the answer negative!\n'
            '2⁻³ = 1/8 = +0.125 (Positive reciprocal, not negative number).',
        Color(0xFFE91E63),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting Model Classes for Powers & Indices View
// ─────────────────────────────────────────────────────────────────────────────

class _PowerGroupData {
  const _PowerGroupData({
    required this.base,
    required this.title,
    required this.tagline,
    required this.color,
    required this.items,
  });
  final int base;
  final String title;
  final String tagline;
  final Color color;
  final List<_PowerItemData> items;
}

class _PowerItemData {
  const _PowerItemData(this.exponent, this.value, this.note);
  final String exponent;
  final String value;
  final String note;
}

class _LawItemData {
  const _LawItemData(
    this.number,
    this.title,
    this.formula,
    this.explanation,
    this.example,
    this.color,
  );
  final String number;
  final String title;
  final String formula;
  final String explanation;
  final String example;
  final Color color;
}

class _SurdRuleData {
  const _SurdRuleData(
    this.title,
    this.formula,
    this.explanation,
    this.example,
    this.color,
  );
  final String title;
  final String formula;
  final String explanation;
  final String example;
  final Color color;
}

class _ShortcutData {
  const _ShortcutData(
    this.title,
    this.summary,
    this.content,
    this.color,
  );
  final String title;
  final String summary;
  final String content;
  final Color color;
}
