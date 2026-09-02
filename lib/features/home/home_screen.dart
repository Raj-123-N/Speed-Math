import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../revision/revision_screen.dart';
import '../practice/practice_screen.dart';
import '../settings/settings_screen.dart';
import '../../app/theme/app_colors.dart';
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

  Future<void> _check() async {
    if (!mounted) return;
    try {
      final s = AppUpdateService();
      final i = await s.checkForUpdate(force: false);
      if (mounted && i != null && i.hasUpdate) UpdateDialog.show(context, info: i, updateService: s);
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
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: pages),
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
