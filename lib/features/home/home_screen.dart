import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../revision/revision_screen.dart';
import '../practice/practice_screen.dart';
import '../settings/settings_screen.dart';
import '../../app/theme/app_colors.dart';
import '../../core/models/app_update_info.dart';
import '../../core/services/app_update_service.dart';
import '../../core/widgets/update_dialog.dart';

const _active = AppColors.navSelected;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late int index;
  late AnimationController anim;
  Timer? timer;
  late final List<Widget> pages;

  static const tabs = [
    _Tab('Learn', Icons.school_outlined, Icons.school_rounded),
    _Tab('Practice', Icons.tune_rounded, Icons.tune_rounded),
    _Tab('Settings', Icons.settings_outlined, Icons.settings_rounded),
  ];

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex.clamp(0, 2);
    anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    pages = [
      const LearnScreen(),
      const PracticeScreen(),
      const SettingsScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        timer = Timer(const Duration(milliseconds: 1500), _check));
  }

  AppUpdateInfo? _availableUpdate;
  bool _bannerDismissed = false;

  Future<void> _check() async {
    if (!mounted) return;
    try {
      final s = AppUpdateService();
      final i = await s.checkForUpdate(force: false);
      if (mounted && i != null && i.hasUpdate) {
        setState(() => _availableUpdate = i);
        UpdateDialog.show(context, info: i, updateService: s);
      }
    } catch (_) {}
  }

  void tap(int i) async {
    if (i == index) return;
    setState(() => index = i);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt('last_tab', i);
      await p.setString('last_date', DateTime.now().toIso8601String().substring(0, 10));
    } catch (_) {}
  }

  @override
  void dispose() {
    timer?.cancel();
    anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: index, children: pages),
          if (_availableUpdate != null && !_bannerDismissed)
            Positioned(
              top: top + 10,
              left: 14,
              right: 14,
              child: _buildUpdateBanner(context, isDark),
            ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 70 + 10 + bottom,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10 + bottom),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: Row(
              children: List.generate(
                tabs.length,
                (i) => Expanded(child: _NavItem(tab: tabs[i], selected: i == index, onTap: () => tap(i))),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateBanner(BuildContext context, bool isDark) {
    final info = _availableUpdate!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2130) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradOrangeStart, AppColors.gradOrangeEnd],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => UpdateDialog.show(context, info: info, updateService: AppUpdateService()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Update Available: v${info.latestVersion}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (info.formattedSize.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(${info.formattedSize})',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Tap to view what is new and download',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => UpdateDialog.show(context, info: info, updateService: AppUpdateService()),
            child: const Text('Update', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => setState(() => _bannerDismissed = true),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 16, color: isDark ? Colors.white54 : Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab {
  const _Tab(this.label, this.icon, this.active);
  final String label;
  final IconData icon, active;
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});
  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext c) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: selected ? _active.withValues(alpha: .12) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? tab.active : tab.icon, size: 25, color: selected ? _active : Colors.grey),
          const SizedBox(height: 3),
          Text(tab.label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: selected ? _active : Colors.grey)),
        ],
      ),
    ),
  );
}
