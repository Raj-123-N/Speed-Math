import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/theme_provider.dart';
import '../../core/services/app_update_service.dart';
import '../../core/services/app_utility_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/practice_feedback_service.dart';
import '../../core/widgets/update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _updateService = AppUpdateService();
  final _feedback = PracticeFeedbackService.instance;
  final _notifications = NotificationService.instance;
  final _utilities = AppUtilityService.instance;
  bool _soundEnabled = true, _vibrationEnabled = true, _animationsEnabled = true;
  bool _notificationsEnabled = true, _dailyReminder = true, _smartReminder = true, _autoCheckUpdates = true;
  String? _lastCheckStr;
  static const _keys = {'sound': 'settings_sound', 'vibration': 'settings_vibration', 'animations': 'settings_practice_animations', 'notifications': 'settings_notifications'};

  @override
  void initState() { super.initState(); _loadSettings(); }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final autoCheck = await _updateService.isAutoCheckEnabled();
    final lastCheck = await _updateService.getLastCheckTime();
    final daily = await _notifications.isDailyReminderEnabled();
    final smart = await _notifications.isSmartReminderEnabled();
    final lastCheckFormatted = lastCheck == null ? null : DateFormat('MMM d, h:mm a').format(lastCheck);
    try { await PackageInfo.fromPlatform(); } catch (_) {}
    if (!mounted) return;
    setState(() {
      _soundEnabled = prefs.getBool(_keys['sound']!) ?? true;
      _vibrationEnabled = prefs.getBool(_keys['vibration']!) ?? true;
      _animationsEnabled = prefs.getBool(_keys['animations']!) ?? true;
      _notificationsEnabled = prefs.getBool(_keys['notifications']!) ?? true;
      _dailyReminder = daily;
      _smartReminder = smart;
      _autoCheckUpdates = autoCheck;
      _lastCheckStr = lastCheckFormatted;
    });
    await _feedback.refresh();
  }

  Future<void> _checkForUpdatesManually() async {
    await UpdateDialog.checkWithProgress(context, updateService: _updateService, onCheckComplete: (lastCheck) { if (mounted && lastCheck != null) setState(() => _lastCheckStr = DateFormat('MMM d, h:mm a').format(lastCheck)); });
  }

  Future<void> _saveBool(String key, bool value) async {
    setState(() { switch (key) { case 'sound': _soundEnabled = value; break; case 'vibration': _vibrationEnabled = value; break; case 'animations': _animationsEnabled = value; break; case 'notifications': _notificationsEnabled = value; break; } });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keys[key]!, value);
    if (key == 'notifications') await _notifications.setEnabled(value);
    if (key == 'sound' || key == 'vibration' || key == 'animations') await _feedback.refresh();
  }

  Future<void> _setReminder(String type, bool value) async {
    setState(() { if (type == 'daily') _dailyReminder = value; else _smartReminder = value; });
    if (type == 'daily') await _notifications.setDailyReminder(value); else await _notifications.setSmartReminder(value);
  }

  Future<void> _share() async {
    try { await _utilities.shareApp(); } catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open sharing.'))); }
  }

  Future<void> _rate() async {
    try { await _utilities.rateApp(); } catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open rating.'))); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F7);
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return Scaffold(backgroundColor: bg, appBar: AppBar(backgroundColor: bg, elevation: 0, title: Text('Settings', style: AppTypography.appBarTitle.copyWith(color: textPrimary))), body: ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(16, 8, 16, 40), children: [
      _SectionHeader(label: 'Display', isDark: isDark),
      Consumer<ThemeProvider>(builder: (_, tp, _) => _SettingsCard(isDark: isDark, children: [_ToggleRow(icon: Icons.dark_mode_rounded, label: 'Dark Mode', subtitle: 'Switch between light and dark theme', value: tp.isDarkMode, isDark: isDark, color: AppColors.accent, onChanged: (_) => tp.toggleTheme())])),
      _SectionHeader(label: 'Audio & Haptic', isDark: isDark),
      _SettingsCard(isDark: isDark, children: [
        _ToggleRow(icon: Icons.volume_up_rounded, label: 'Sound Effects', subtitle: 'Play sounds across supported app interactions', value: _soundEnabled, isDark: isDark, color: AppColors.module3Color, onChanged: (v) => _saveBool('sound', v)),
        _Divider(isDark: isDark),
        _ToggleRow(icon: Icons.vibration_rounded, label: 'Haptic Feedback', subtitle: 'Vibrate on supported interactions', value: _vibrationEnabled, isDark: isDark, color: AppColors.module2Color, onChanged: (v) => _saveBool('vibration', v)),
      ]),
      _SectionHeader(label: 'Practice Experience', isDark: isDark),
      _SettingsCard(isDark: isDark, children: [
        _ActionRow(icon: Icons.play_circle_outline_rounded, label: 'Preview Practice Sound', subtitle: 'Preview the current Practice start sound', isDark: isDark, color: AppColors.module3Color, onTap: _feedback.previewSound),
        _Divider(isDark: isDark),
        _ToggleRow(icon: Icons.animation_rounded, label: 'Practice Animations', subtitle: 'Question transitions, answer feedback and result motion', value: _animationsEnabled, isDark: isDark, color: AppColors.primary, onChanged: (v) => _saveBool('animations', v)),
      ]),
      _SectionHeader(label: 'Notifications', isDark: isDark),
      _SettingsCard(isDark: isDark, children: [
        _ToggleRow(icon: Icons.notifications_rounded, label: 'Practice Notifications', subtitle: 'Allow reminders to practise learned topics', value: _notificationsEnabled, isDark: isDark, color: AppColors.module1Color, onChanged: (v) => _saveBool('notifications', v)),
        _Divider(isDark: isDark),
        _ToggleRow(icon: Icons.event_available_rounded, label: 'Daily Practice Reminder', subtitle: 'One reliable evening reminder every day', value: _dailyReminder, isDark: isDark, color: AppColors.module2Color, onChanged: (v) => _setReminder('daily', v)),
        _Divider(isDark: isDark),
        _ToggleRow(icon: Icons.auto_awesome_rounded, label: 'Smart Random Reminder', subtitle: 'One varied reminder at a different time each day', value: _smartReminder, isDark: isDark, color: AppColors.module3Color, onChanged: (v) => _setReminder('smart', v)),
      ]),
      _SectionHeader(label: 'Share & Support', isDark: isDark),
      _SettingsCard(isDark: isDark, children: [
        _ActionRow(icon: Icons.share_rounded, label: 'Share this App', subtitle: 'Share Speed Math with friends', isDark: isDark, color: AppColors.primary, onTap: _share),
        _Divider(isDark: isDark),
        _ActionRow(icon: Icons.star_rate_rounded, label: 'Rate this App', subtitle: 'Leave a rating when store review is available', isDark: isDark, color: AppColors.module3Color, onTap: _rate),
      ]),
      _SectionHeader(label: 'App Updates', isDark: isDark),
      _SettingsCard(isDark: isDark, children: [
        _ToggleRow(icon: Icons.sync_rounded, label: 'Automatic Update Check', subtitle: 'Check for new releases periodically', value: _autoCheckUpdates, isDark: isDark, color: AppColors.module3Color, onChanged: (v) async { setState(() => _autoCheckUpdates = v); await _updateService.setAutoCheckEnabled(v); }),
        _Divider(isDark: isDark),
        _ActionRow(icon: Icons.system_update_alt_rounded, label: 'Check for Update', subtitle: _lastCheckStr != null ? 'Last checked: $_lastCheckStr' : 'Check the latest GitHub Release', isDark: isDark, color: AppColors.primary, onTap: _checkForUpdatesManually, trailing: 'Check'),
      ]),
      const SizedBox(height: 16),
    ]));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});
  final String label;
  final bool isDark;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(4, 20, 4, 8), child: Text(label.toUpperCase(), style: AppTypography.sectionHeader.copyWith(color: AppColors.primary, letterSpacing: 1.5)));
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.children});
  final bool isDark;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: .8)), child: Column(children: children));
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.isDark, required this.color, required this.onChanged, this.subtitle});
  final IconData icon; final String label; final bool value; final bool isDark; final Color color; final ValueChanged<bool> onChanged; final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AppTypography.titleMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w600)), if (subtitle != null) Text(subtitle!, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))])), Switch(value: value, activeThumbColor: color, activeTrackColor: color.withValues(alpha: .3), onChanged: onChanged)]));
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label, required this.subtitle, required this.isDark, required this.color, required this.onTap, this.trailing});
  final IconData icon; final String label; final String subtitle; final bool isDark; final Color color; final VoidCallback onTap; final String? trailing;
  @override
  Widget build(BuildContext context) => InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AppTypography.titleMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w600)), Text(subtitle, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))])), if (trailing != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)), child: Text(trailing!, style: AppTypography.tagText.copyWith(color: color, fontWeight: FontWeight.w800))) else Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black38)])));
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) => Divider(height: 1, indent: 52, color: isDark ? AppColors.dividerDark : AppColors.dividerLight);
}
