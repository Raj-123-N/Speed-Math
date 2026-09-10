import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_update_info.dart';

/// Advanced GitHub release and in-app update service for Speed Math.
///
/// Features:
/// - Official GitHub Releases API integration
/// - Resilience against GitHub unauthenticated API rate-limiting (HTTP 403 fallback)
/// - Semantic versioning comparison with build-number support
/// - Configurable auto-check intervals and skip-version memory
/// - Direct APK download or web release page launching
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
  static const Duration autoCheckInterval = Duration(hours: 6);

  /// Retrieves currently installed app version (e.g., '0.5.0').
  Future<String> getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version.isNotEmpty ? info.version : '0.5.0';
    } catch (_) {
      return '0.5.0';
    }
  }

  /// Retrieves the build number if available.
  Future<String> getCurrentBuildNumber() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.buildNumber;
    } catch (_) {
      return '5';
    }
  }

  Future<bool> isAutoCheckEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoCheck) ?? true;
  }

  Future<void> setAutoCheckEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoCheck, enabled);
  }

  Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_keyLastCheck);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<String?> getSkippedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySkippedVersion);
  }

  Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySkippedVersion, version);
  }

  Future<void> clearSkippedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySkippedVersion);
  }

  Future<bool> shouldRunAutoCheck() async {
    if (!await isAutoCheckEnabled()) return false;
    final last = await getLastCheckTime();
    if (last == null) return true;
    return DateTime.now().difference(last) >= autoCheckInterval;
  }

  /// Checks GitHub for the latest release.
  ///
  /// When [force] is true, ignores auto-check timers and skipped versions.
  Future<AppUpdateInfo?> checkForUpdate({bool force = false}) async {
    final current = await getCurrentVersion();
    if (!force && !await shouldRunAutoCheck()) {
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastCheck, DateTime.now().millisecondsSinceEpoch);

      // Attempt 1: Fetch latest release from GitHub API
      final latestUri =
          Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest');
      final response = await _client.get(
        latestUri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Speed-Math-Flutter-App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _processReleaseData(data, current, force, prefs);
      }

      // Attempt 2: If latest release not found (404), check releases list
      if (response.statusCode == 404) {
        try {
          final listUri =
              Uri.parse('https://api.github.com/repos/$owner/$repo/releases');
          final listResp = await _client.get(listUri, headers: {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Speed-Math-Flutter-App',
          }).timeout(const Duration(seconds: 8));
          if (listResp.statusCode == 200) {
            final list = jsonDecode(listResp.body) as List<dynamic>;
            if (list.isNotEmpty) {
              return _processReleaseData(
                list.first as Map<String, dynamic>,
                current,
                force,
                prefs,
              );
            }
          }
        } catch (_) {}
      }

      // Attempt 3: Check remote git tags
      try {
        final tagsUri =
            Uri.parse('https://api.github.com/repos/$owner/$repo/tags');
        final tagsResp = await _client.get(tagsUri, headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Speed-Math-Flutter-App',
        }).timeout(const Duration(seconds: 8));
        if (tagsResp.statusCode == 200) {
          final tagList = jsonDecode(tagsResp.body) as List<dynamic>;
          if (tagList.isNotEmpty) {
            final firstTag =
                (tagList.first as Map<String, dynamic>)['name'] as String? ?? '';
            final cleanLatest =
                firstTag.replaceFirst(RegExp(r'^v', caseSensitive: false), '');
            final newer = isVersionNewer(current, cleanLatest);
            if (newer) {
              final skipped = prefs.getString(_keySkippedVersion);
              if (!force && (skipped == cleanLatest || skipped == firstTag)) {
                return null;
              }
              return AppUpdateInfo(
                currentVersion: current,
                latestVersion: cleanLatest,
                tagName: firstTag,
                releaseTitle: 'Speed Math $firstTag',
                releaseNotes:
                    'A new release ($firstTag) is available on GitHub with updated mental math drills and performance improvements.',
                apkDownloadUrl:
                    'https://github.com/$owner/$repo/raw/main/releases/SpeedMath-$firstTag.apk',
                releaseHtmlUrl:
                    'https://github.com/$owner/$repo/releases/tag/$firstTag',
                hasUpdate: true,
              );
            }
          }
        }
      } catch (_) {}

      // Attempt 4: If 403 (Rate Limit) or no releases/tags, fallback to checking raw pubspec on main branch
      final fallbackInfo = await _checkFallbackRawPubspec(current, force, prefs);
      if (fallbackInfo != null) return fallbackInfo;

      return force ? AppUpdateInfo.upToDate(current) : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking for updates: $e');
      }
      return force ? AppUpdateInfo.upToDate(current) : null;
    }
  }

  AppUpdateInfo? _processReleaseData(
    Map<String, dynamic> data,
    String current,
    bool force,
    SharedPreferences prefs,
  ) {
    final tag = data['tag_name'] as String? ?? '';
    final latest = tag.replaceFirst(RegExp(r'^v', caseSensitive: false), '');
    final newer = isVersionNewer(current, latest);

    if (!force && newer) {
      final skipped = prefs.getString(_keySkippedVersion);
      if (skipped == latest || skipped == tag) {
        return null;
      }
    }

    return AppUpdateInfo.fromJson(
      json: data,
      currentVersion: current,
      hasUpdate: newer,
    );
  }

  /// Fallback check by reading raw pubspec.yaml on GitHub main branch.
  Future<AppUpdateInfo?> _checkFallbackRawPubspec(
    String current,
    bool force,
    SharedPreferences prefs,
  ) async {
    try {
      final rawUri = Uri.parse(
        'https://raw.githubusercontent.com/$owner/$repo/main/pubspec.yaml',
      );
      final rawResp = await _client.get(rawUri).timeout(const Duration(seconds: 6));
      if (rawResp.statusCode == 200) {
        final match = RegExp(r'^version:\s*([0-9\.\+\-a-zA-Z]+)', multiLine: true)
            .firstMatch(rawResp.body);
        if (match != null) {
          final remoteVer = match.group(1)!.split('+').first;
          final newer = isVersionNewer(current, remoteVer);
          if (!force && newer) {
            final skipped = prefs.getString(_keySkippedVersion);
            if (skipped == remoteVer) return null;
          }
          return AppUpdateInfo(
            currentVersion: current,
            latestVersion: remoteVer,
            tagName: 'v$remoteVer',
            releaseTitle: 'Speed Math v$remoteVer Update',
            releaseNotes:
                'A new version (v$remoteVer) is available on GitHub! Download the latest APK to get the newest features, drills, and accuracy improvements.',
            apkDownloadUrl:
                'https://github.com/$owner/$repo/raw/main/releases/SpeedMath-v$remoteVer.apk',
            releaseHtmlUrl: 'https://github.com/$owner/$repo/releases',
            hasUpdate: newer,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Compares two version strings (e.g. '0.4.0' vs '0.5.0' or '1.0.0+4' vs '1.0.0+5').
  static bool isVersionNewer(String current, String latest) {
    final a = _parseVersion(current);
    final b = _parseVersion(latest);
    final n = max(a.length, b.length);

    for (var i = 0; i < n; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (y > x) return true;
      if (y < x) return false;
    }
    return false;
  }

  static List<int> _parseVersion(String v) {
    var s = v.trim().replaceFirst(RegExp(r'^[vV]'), '');
    int buildNum = 0;
    if (s.contains('+')) {
      final parts = s.split('+');
      s = parts.first;
      if (parts.length > 1) {
        buildNum = int.tryParse(parts[1]) ?? 0;
      }
    }
    if (s.contains('-')) {
      s = s.split('-').first;
    }
    final numbers = s.split('.').map((x) => int.tryParse(x) ?? 0).toList();
    if (buildNum > 0) {
      numbers.add(buildNum);
    }
    return numbers;
  }

  /// Launches either the direct APK download or the GitHub release web page.
  Future<bool> launchUpdate(AppUpdateInfo info) async {
    final target = info.apkDownloadUrl ?? info.releaseHtmlUrl;
    if (target.isEmpty) return false;
    final uri = Uri.parse(target);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
