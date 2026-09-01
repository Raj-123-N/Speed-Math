import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../revision/revision_screen.dart';
import '../practice/practice_screen.dart';
import '../settings/settings_screen.dart';
import '../../app/theme/app_colors.dart';
import '../../core/services/app_update_service.dart';
import '../../core/widgets/update_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────
const _kActiveColor    = AppColors.navSelected;
const _kInactiveColor  = Color(0xFF6B7280);
const _kNavHeight      = 68.0;
const _kNavHMargin     = 14.0;
const _kNavBMargin     = 10.0;
const _kNavRadius      = 24.0;
const _kAnimDuration   = Duration(milliseconds: 250);

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen (3-Tab Modern Floating Dock Navigation)
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
  with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animCtrl;
  late Animation<double> _indicatorAnim;
  Timer? _updateCheckTimer;

  late final List<Widget> _pages;

  static const _tabs = [
    _Tab('Learn',    Icons.auto_stories_outlined, Icons.auto_stories_rounded),
    _Tab('Practice', Icons.tune_rounded,          Icons.tune_rounded),
    _Tab('Settings', Icons.settings_outlined,     Icons.settings_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);

    _animCtrl = AnimationController(vsync: this, duration: _kAnimDuration);
    _indicatorAnim = Tween<double>(
      begin: _currentIndex.toDouble(),
      end: _currentIndex.toDouble(),
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _pages = [
      const RevisionScreen(),
      const PracticeScreen(),
      const SettingsScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCheckTimer = Timer(const Duration(milliseconds: 1500), () {
        _triggerAutoUpdateCheck();
      });
    });
  }

  Future<void> _triggerAutoUpdateCheck() async {
    if (!mounted) return;

    try {
      final updateService = AppUpdateService();
      final info = await updateService.checkForUpdate(force: false);
      if (mounted && info != null && info.hasUpdate) {
        UpdateDialog.show(context, info: info, updateService: updateService);
      }
    } catch (_) {}
  }

  void _onTabTapped(int i) async {
    if (i == _currentIndex) return;
    final old = _currentIndex;
    setState(() => _currentIndex = i);
    _indicatorAnim = Tween<double>(
      begin: old.toDouble(),
      end: i.toDouble(),
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward(from: 0);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_tab', i);
      await prefs.setString(
        'last_date',
        DateTime.now().toIso8601String().substring(0, 10),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _updateCheckTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final navBarTotalHeight = _kNavHeight + _kNavBMargin + bottomPad;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SizedBox(
        height: navBarTotalHeight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            _kNavHMargin,
            0,
            _kNavHMargin,
            _kNavBMargin + bottomPad,
          ),
          child: _FloatingNavBar(
            currentIndex: _currentIndex,
            indicatorAnim: _indicatorAnim,
            tabs: _tabs,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab model
// ─────────────────────────────────────────────────────────────────────────────
class _Tab {
  const _Tab(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Nav Bar
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.indicatorAnim,
    required this.tabs,
    required this.onTap,
  });

  final int currentIndex;
  final Animation<double> indicatorAnim;
  final List<_Tab> tabs;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: indicatorAnim,
      builder: (_, _) {
        return Container(
          height: _kNavHeight,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161922) : Colors.white,
            borderRadius: BorderRadius.circular(_kNavRadius),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2C3242)
                  : const Color(0xFFE5E9F0),
              width: 0.9,
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.primaryGlow.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              return Expanded(
                child: _NavItem(
                  tab: tabs[i],
                  isSelected: i == currentIndex,
                  isDark: isDark,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual Nav Item
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final _Tab tab;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _kAnimDuration,
        curve: Curves.easeOutCubic,
        height: _kNavHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with active glow
            AnimatedContainer(
              duration: _kAnimDuration,
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? _kActiveColor.withValues(alpha: isDark ? 0.22 : 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? tab.activeIcon : tab.icon,
                size: 26,
                color: isSelected ? _kActiveColor : (isDark ? const Color(0xFF8891A5) : _kInactiveColor),
              ),
            ),
            const SizedBox(height: 4),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? _kActiveColor
                    : (isDark ? const Color(0xFF8891A5) : _kInactiveColor),
                letterSpacing: 0.2,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}
