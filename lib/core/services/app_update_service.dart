import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_update_info.dart';

/// Service for checking and managing application updates via GitHub Releases.
class AppUpdateService {
  AppUpdateService({
    http.Client? httpClient,
    this.owner = 'Raj-123-N',
    this.repo = 'Speed-Math',
  }) : _client = httpClient ?? http.Client();

  final http.Client _client;
  final String owner;
  final String repo;

  static const String _keyAutoCheck = 'settings_auto_check_updates';
  static const String _keyLastCheck = 'settings_last_update_check';
  static const String _keySkippedVersion = 'settings_skipped_update_version';

  static const Duration _autoCheckInterval = Duration(hours: 6);

  /// Fetch the current installed version of the app.
  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version.isNotEmpty ? packageInfo.version : '0.1.3';
    } catch (_) {
      return '0.1.3';
    }
  }

  /// Whether auto update checking is enabled in preferences.
  Future<bool> isAutoCheckEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoCheck) ?? true;
  }

  /// Update the auto update checking preference.
  Future<void> setAutoCheckEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoCheck, enabled);
  }

  /// Gets the last check timestamp.
  Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_keyLastCheck);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Saves the skipped version tag so the user is not prompted repeatedly in auto-check.
  Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySkippedVersion, version);
  }

  /// Checks if an auto check should run based on user preferences and throttle interval.
  Future<bool> shouldRunAutoCheck() async {
    final enabled = await isAutoCheckEnabled();
    if (!enabled) return false;

    final lastCheck = await getLastCheckTime();
    if (lastCheck == null) return true;

    return DateTime.now().difference(lastCheck) >= _autoCheckInterval;
  }

  /// Queries GitHub Releases for the latest version.
  /// If [force] is false and it's an auto-check, checks throttle and skipped version.
  Future<AppUpdateInfo?> checkForUpdate({bool force = false}) async {
    final currentVersion = await getCurrentVersion();

    if (!force) {
      final shouldRun = await shouldRunAutoCheck();
      if (!shouldRun) return null;
    }

    try {
      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest');
      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Speed-Math-App',
        },
      ).timeout(const Duration(seconds: 10));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastCheck, DateTime.now().millisecondsSinceEpoch);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final tagName = data['tag_name'] as String? ?? '';
        final latestVersion = tagName.replaceFirst(RegExp(r'^v', caseSensitive: false), '');

        final hasNewerVersion = isVersionNewer(currentVersion, latestVersion);

        // If not force check, ignore if user chose to skip this specific version
        if (!force && hasNewerVersion) {
          final skippedVersion = prefs.getString(_keySkippedVersion);
          if (skippedVersion == latestVersion || skippedVersion == tagName) {
            return null;
          }
        }

        return AppUpdateInfo.fromJson(
          json: data,
          currentVersion: currentVersion,
          hasUpdate: hasNewerVersion,
        );
      } else if (response.statusCode == 404) {
        // No releases published yet
        return AppUpdateInfo.upToDate(currentVersion);
      } else {
        if (kDebugMode) {
          print('Failed to check update: HTTP ${response.statusCode}');
        }
        return force ? AppUpdateInfo.upToDate(currentVersion) : null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking for updates: $e');
      }
      return force ? AppUpdateInfo.upToDate(currentVersion) : null;
    }
  }

  /// Compares two semantic version strings (e.g., '0.1.2' vs '0.1.3' or 'v0.1.3+2').
  /// Returns `true` if [latest] is strictly greater than [current].
  static bool isVersionNewer(String current, String latest) {
    final currentParts = _parseVersion(current);
    final latestParts = _parseVersion(latest);

    final maxLen = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for (int i = 0; i < maxLen; i++) {
      final curr = i < currentParts.length ? currentParts[i] : 0;
      final lat = i < latestParts.length ? latestParts[i] : 0;

      if (lat > curr) return true;
      if (lat < curr) return false;
    }

    return false;
  }

  static List<int> _parseVersion(String version) {
    // Strip leading 'v' or 'V'
    var clean = version.trim().replaceFirst(RegExp(r'^[vV]'), '');
    // Remove build metadata (anything after '+')
    if (clean.contains('+')) {
      clean = clean.split('+').first;
    }
    // Remove prerelease metadata (anything after '-')
    if (clean.contains('-')) {
      clean = clean.split('-').first;
    }

    return clean
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }

  /// Launches the download URL for the update (APK or GitHub Release page).
  Future<bool> launchUpdate(AppUpdateInfo info) async {
    final targetUrl = info.apkDownloadUrl ?? info.releaseHtmlUrl;
    if (targetUrl.isEmpty) return false;

    final uri = Uri.parse(targetUrl);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
