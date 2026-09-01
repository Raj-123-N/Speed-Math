import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/theme_provider.dart';
import '../../core/services/app_update_service.dart';
import '../../core/widgets/update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _updateService = AppUpdateService();

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;

  bool _autoCheckUpdates = true;

  String? _lastCheckStr;

  static const _keys = {
    'sound': 'settings_sound',
    'vibration': 'settings_vibration',
    'notifications': 'settings_notifications',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final autoCheck = await _updateService.isAutoCheckEnabled();
    final lastCheck = await _updateService.getLastCheckTime();

    try {
      await PackageInfo.fromPlatform();
    } catch (_) {}

    String? lastCheckFormatted;
    if (lastCheck != null) {
      lastCheckFormatted = DateFormat('MMM d, h:mm a').format(lastCheck);
    }

    if (!mounted) return;
    setState(() {
      _soundEnabled = prefs.getBool(_keys['sound']!) ?? true;
      _vibrationEnabled = prefs.getBool(_keys['vibration']!) ?? true;
      _notificationsEnabled = prefs.getBool(_keys['notifications']!) ?? true;
      _autoCheckUpdates = autoCheck;
      _lastCheckStr = lastCheckFormatted;
    });
  }

  Future<void> _checkForUpdatesManually() async {
    await UpdateDialog.checkWithProgress(
      context,
      updateService: _updateService,
      onCheckComplete: (lastCheck) {
        if (mounted && lastCheck != null) {
          setState(() {
            _lastCheckStr = DateFormat('MMM d, h:mm a').format(lastCheck);
          });
        }
      },
    );
  }

  Future<void> _saveBool(String key, bool value) async {
    setState(() {
      switch (key) {
        case 'sound':
          _soundEnabled = value;
          break;
        case 'vibration':
          _vibrationEnabled = value;
          break;
        case 'notifications':
          _notificationsEnabled = value;
          break;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keys[key]!, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F7);
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text('Settings',
            style: AppTypography.appBarTitle.copyWith(color: textPrimary)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Display ─────────────────────────────────────────────────────
          _SectionHeader(label: 'Display', isDark: isDark),

          Consumer<ThemeProvider>(
            builder: (_, tp, _) => _SettingsCard(
              isDark: isDark,
              children: [
                _ToggleRow(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark Mode',
                  subtitle: 'Switch between light and dark theme',
                  value: tp.isDarkMode,
                  isDark: isDark,
                  color: AppColors.accent,
                  onChanged: (_) => tp.toggleTheme(),
                ),
              ],
            ),
          ),

          // ── Audio & Haptic ───────────────────────────────────────────────
          _SectionHeader(label: 'Audio & Haptic', isDark: isDark),

          _SettingsCard(
            isDark: isDark,
            children: [
              _ToggleRow(
                icon: Icons.volume_up_rounded,
                label: 'Sound Effects',
                subtitle: 'Play sounds across the app',
                value: _soundEnabled,
                isDark: isDark,
                color: AppColors.module3Color,
                onChanged: (v) => _saveBool('sound', v),
              ),
              _Divider(isDark: isDark),
              _ToggleRow(
                icon: Icons.vibration_rounded,
                label: 'Haptic Feedback',
                subtitle: 'Vibrate on interactions',
                value: _vibrationEnabled,
                isDark: isDark,
                color: AppColors.module2Color,
                onChanged: (v) => _saveBool('vibration', v),
              ),
            ],
          ),

          // ── Notifications ────────────────────────────────────────────────
          _SectionHeader(label: 'Notifications', isDark: isDark),

          _SettingsCard(
            isDark: isDark,
            children: [
              _ToggleRow(
                icon: Icons.notifications_rounded,
                label: 'Push Notifications',
                subtitle: 'Daily reminders and alerts',
                value: _notificationsEnabled,
                isDark: isDark,
                color: AppColors.module1Color,
                onChanged: (v) => _saveBool('notifications', v),
              ),
            ],
          ),

          // ── App Updates ──────────────────────────────────────────────────
          _SectionHeader(label: 'App Updates', isDark: isDark),

          _SettingsCard(
            isDark: isDark,
            children: [
              _ToggleRow(
                icon: Icons.sync_rounded,
                label: 'Auto-Check for Updates',
                subtitle: 'Check for new releases periodically',
                value: _autoCheckUpdates,
                isDark: isDark,
                color: AppColors.module3Color,
                onChanged: (v) async {
                  setState(() => _autoCheckUpdates = v);
                  await _updateService.setAutoCheckEnabled(v);
                },
              ),
              _Divider(isDark: isDark),
              InkWell(
                onTap: _checkForUpdatesManually,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.system_update_alt_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check for Updates',
                              style: AppTypography.titleMedium.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _lastCheckStr != null
                                  ? 'Last checked: $_lastCheckStr'
                                  : 'Tap to check GitHub Releases',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Check',
                          style: AppTypography.tagText.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(label.toUpperCase(),
          style: AppTypography.sectionHeader.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.5,
          )),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.children});
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.color,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final bool value;
  final bool isDark;
  final Color color;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    )),
                if (subtitle != null)
                  Text(subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      )),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Divider(
      height: 1,
      indent: 52,
      color: isDark ? AppColors.dividerDark : AppColors.dividerLight);
}
