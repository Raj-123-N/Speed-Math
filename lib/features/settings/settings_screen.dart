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
  String _version = '';
  static const _keys = {
    'sound': 'settings_sound',
    'vibration': 'settings_vibration',
    'animations': 'settings_practice_animations',
    'notifications': 'settings_notifications',
  };

  @override
  void initState() { super.initState(); _loadSettings(); }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final autoCheck = await _updateService.isAutoCheckEnabled();
    final lastCheck = await _updateService.getLastCheckTime();
    final daily = await _notifications.isDailyReminderEnabled();
    final smart = await _notifications.isSmartReminderEnabled();
    final lastCheckFormatted = lastCheck == null ? null : DateFormat('MMM d, h:mm a').format(lastCheck);
    String version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      version = 'v${info.version}';
    } catch (_) {}
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
      _version = version;
    });
    await _feedback.refresh();
  }

  Future<void> _checkForUpdatesManually() async {
    await UpdateDialog.checkWithProgress(context, updateService: _updateService, onCheckComplete: (lastCheck) {
      if (mounted && lastCheck != null) setState(() => _lastCheckStr = DateFormat('MMM d, h:mm a').format(lastCheck));
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    setState(() {
      switch (key) {
        case 'sound': _soundEnabled = value; break;
        case 'vibration': _vibrationEnabled = value; break;
        case 'animations': _animationsEnabled = value; break;
        case 'notifications': _notificationsEnabled = value; break;
      }
    });
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
    try { await _utilities.shareApp(); } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open sharing.')));
    }
  }

  Future<void> _rate() async {
    try { await _utilities.rateApp(); } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open rating.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F7);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Header Banner ─────────────────────────────────────────
          SliverToBoxAdapter(child: _AppHeader(isDark: isDark, version: _version)),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Display
                _SectionHeader(label: 'Display', icon: Icons.palette_rounded, color: AppColors.accent, isDark: isDark),
                Consumer<ThemeProvider>(
                  builder: (_, tp, _) => _SettingsCard(isDark: isDark, children: [
                    _ToggleRow(
                      icon: tp.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      label: 'Dark Mode',
                      subtitle: 'Switch between light and dark theme',
                      value: tp.isDarkMode,
                      isDark: isDark,
                      color: AppColors.accent,
                      onChanged: (_) => tp.toggleTheme(),
                    ),
                  ]),
                ),

                // Audio & Haptic
                _SectionHeader(label: 'Audio & Haptic', icon: Icons.volume_up_rounded, color: AppColors.module3Color, isDark: isDark),
                _SettingsCard(isDark: isDark, children: [
                  _ToggleRow(icon: Icons.music_note_rounded, label: 'Sound Effects', subtitle: 'Play sounds across supported app interactions', value: _soundEnabled, isDark: isDark, color: AppColors.module3Color, onChanged: (v) => _saveBool('sound', v)),
                  _Divider(isDark: isDark),
                  _ToggleRow(icon: Icons.vibration_rounded, label: 'Haptic Feedback', subtitle: 'Vibrate on supported interactions', value: _vibrationEnabled, isDark: isDark, color: AppColors.module2Color, onChanged: (v) => _saveBool('vibration', v)),
                ]),

                // Practice Experience
                _SectionHeader(label: 'Practice Experience', icon: Icons.tune_rounded, color: AppColors.primary, isDark: isDark),
                _SettingsCard(isDark: isDark, children: [
                  _ActionRow(icon: Icons.play_circle_outline_rounded, label: 'Preview Practice Sound', subtitle: 'Preview the current Practice start sound', isDark: isDark, color: AppColors.module3Color, onTap: _feedback.previewSound),
                  _Divider(isDark: isDark),
                  _ToggleRow(icon: Icons.animation_rounded, label: 'Practice Animations', subtitle: 'Question transitions, answer feedback and result motion', value: _animationsEnabled, isDark: isDark, color: AppColors.primary, onChanged: (v) => _saveBool('animations', v)),
                ]),

                // Notifications
                _SectionHeader(label: 'Notifications', icon: Icons.notifications_rounded, color: AppColors.module1Color, isDark: isDark),
                _SettingsCard(isDark: isDark, children: [
                  _ToggleRow(icon: Icons.notifications_active_rounded, label: 'Practice Notifications', subtitle: 'Allow reminders to practise learned topics', value: _notificationsEnabled, isDark: isDark, color: AppColors.module1Color, onChanged: (v) => _saveBool('notifications', v)),
                  _Divider(isDark: isDark),
                  _ToggleRow(icon: Icons.event_available_rounded, label: 'Daily Practice Reminder', subtitle: 'One reliable evening reminder every day', value: _dailyReminder, isDark: isDark, color: AppColors.module2Color, onChanged: (v) => _setReminder('daily', v)),
                  _Divider(isDark: isDark),
                  _ToggleRow(icon: Icons.auto_awesome_rounded, label: 'Smart Random Reminder', subtitle: 'One varied reminder at a different time each day', value: _smartReminder, isDark: isDark, color: AppColors.module3Color, onChanged: (v) => _setReminder('smart', v)),
                ]),

                // Share & Support
                _SectionHeader(label: 'Share & Support', icon: Icons.favorite_rounded, color: const Color(0xFFEC4899), isDark: isDark),
                _SettingsCard(isDark: isDark, children: [
                  _ActionRow(icon: Icons.share_rounded, label: 'Share this App', subtitle: 'Share Speed Math with friends', isDark: isDark, color: AppColors.primary, onTap: _share),
                  _Divider(isDark: isDark),
                  _ActionRow(icon: Icons.star_rate_rounded, label: 'Rate this App', subtitle: 'Leave a rating when store review is available', isDark: isDark, color: const Color(0xFFF59E0B), onTap: _rate),
                ]),

                // App Updates
                _SectionHeader(label: 'App Updates', icon: Icons.system_update_rounded, color: AppColors.module3Color, isDark: isDark),
                _SettingsCard(isDark: isDark, children: [
                  _ToggleRow(icon: Icons.sync_rounded, label: 'Automatic Update Check', subtitle: 'Check for new releases periodically', value: _autoCheckUpdates, isDark: isDark, color: AppColors.module3Color, onChanged: (v) async { setState(() => _autoCheckUpdates = v); await _updateService.setAutoCheckEnabled(v); }),
                  _Divider(isDark: isDark),
                  _ActionRow(icon: Icons.system_update_alt_rounded, label: 'Check for Update', subtitle: _lastCheckStr != null ? 'Last checked: $_lastCheckStr' : 'Check the latest GitHub Release', isDark: isDark, color: AppColors.primary, onTap: _checkForUpdatesManually, trailing: 'Check'),
                ]),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App Header ────────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.isDark, required this.version});
  final bool isDark;
  final String version;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      margin: EdgeInsets.fromLTRB(16, top + 16, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1328), const Color(0xFF1A1D26)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: isDark ? .25 : .2)),
        boxShadow: isDark ? [] : [BoxShadow(color: AppColors.primary.withValues(alpha: .08), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.speed_rounded, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Speed Math', style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w900, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                const SizedBox(height: 2),
                Text('Mental Math Academy', style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          ),
          if (version.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(version, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon, required this.color, required this.isDark});
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 20, 4, 10),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: AppTypography.sectionHeader.copyWith(color: color, letterSpacing: 1.4),
        ),
      ],
    ),
  );
}

// ── Settings Card ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.children});
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: .8),
      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: Column(children: children),
  );
}

// ── Toggle Row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.isDark, required this.color, required this.onChanged, this.subtitle});
  final IconData icon;
  final String label;
  final bool value;
  final bool isDark;
  final Color color;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.titleMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w700)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ],
          ),
        ),
        Switch(value: value, activeThumbColor: color, activeTrackColor: color.withValues(alpha: .3), onChanged: onChanged),
      ],
    ),
  );
}

// ── Action Row ────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label, required this.subtitle, required this.isDark, required this.color, required this.onTap, this.trailing});
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDark;
  final Color color;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.titleMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          ),
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
              child: Text(trailing!, style: AppTypography.tagText.copyWith(color: color, fontWeight: FontWeight.w800)),
            )
          else
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black38),
        ],
      ),
    ),
  );
}

// ── Divider ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: 54,
    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
  );
}
