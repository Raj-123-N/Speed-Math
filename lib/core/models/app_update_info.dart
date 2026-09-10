import 'package:intl/intl.dart';

/// Model representing release and update information fetched from GitHub Releases.
class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String tagName;
  final String releaseTitle;
  final String releaseNotes;
  final DateTime? publishedAt;
  final String? apkDownloadUrl;
  final int? apkSizeBytes;
  final String? apkFileName;
  final int downloadCount;
  final bool isPreRelease;
  final String releaseHtmlUrl;
  final bool hasUpdate;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.tagName,
    required this.releaseTitle,
    required this.releaseNotes,
    this.publishedAt,
    this.apkDownloadUrl,
    this.apkSizeBytes,
    this.apkFileName,
    this.downloadCount = 0,
    this.isPreRelease = false,
    required this.releaseHtmlUrl,
    required this.hasUpdate,
  });

  factory AppUpdateInfo.fromJson({
    required Map<String, dynamic> json,
    required String currentVersion,
    required bool hasUpdate,
  }) {
    final tagName = json['tag_name'] as String? ?? '';
    final cleanLatestVersion =
        tagName.replaceFirst(RegExp(r'^v', caseSensitive: false), '');
    final releaseTitle = json['name'] as String? ?? tagName;
    final releaseNotes =
        json['body'] as String? ?? 'Exciting new improvements and speed enhancements!';
    final releaseHtmlUrl = json['html_url'] as String? ?? '';
    final isPreRelease = json['prerelease'] as bool? ?? false;

    DateTime? publishedAt;
    if (json['published_at'] != null) {
      publishedAt = DateTime.tryParse(json['published_at'] as String);
    }

    String? apkDownloadUrl;
    int? apkSizeBytes;
    String? apkFileName;
    int downloadCount = 0;

    final assets = json['assets'] as List<dynamic>?;
    if (assets != null) {
      for (final asset in assets) {
        if (asset is Map<String, dynamic>) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          final count = asset['download_count'] as int? ?? 0;
          downloadCount += count;
          if (name.endsWith('.apk')) {
            apkDownloadUrl = asset['browser_download_url'] as String?;
            apkSizeBytes = asset['size'] as int?;
            apkFileName = asset['name'] as String?;
            // Prefer universal or release APK if available
            if (name.contains('universal') || name.contains('release')) {
              break;
            }
          }
        }
      }
    }

    return AppUpdateInfo(
      currentVersion: currentVersion,
      latestVersion: cleanLatestVersion.isNotEmpty ? cleanLatestVersion : currentVersion,
      tagName: tagName,
      releaseTitle: releaseTitle.isNotEmpty ? releaseTitle : 'Speed Math Update',
      releaseNotes: releaseNotes,
      publishedAt: publishedAt,
      apkDownloadUrl: apkDownloadUrl,
      apkSizeBytes: apkSizeBytes,
      apkFileName: apkFileName,
      downloadCount: downloadCount,
      isPreRelease: isPreRelease,
      releaseHtmlUrl: releaseHtmlUrl,
      hasUpdate: hasUpdate,
    );
  }

  factory AppUpdateInfo.upToDate(String currentVersion) {
    return AppUpdateInfo(
      currentVersion: currentVersion,
      latestVersion: currentVersion,
      tagName: 'v$currentVersion',
      releaseTitle: 'Speed Math v$currentVersion',
      releaseNotes: 'You are running the latest official version of Speed Math.',
      publishedAt: null,
      apkDownloadUrl: null,
      apkSizeBytes: null,
      apkFileName: null,
      downloadCount: 0,
      isPreRelease: false,
      releaseHtmlUrl: 'https://github.com/Raj-123-N/Speed-Math/releases',
      hasUpdate: false,
    );
  }

  /// Formatted download size e.g. "21.4 MB" or "840 KB".
  String get formattedSize {
    if (apkSizeBytes == null || apkSizeBytes! <= 0) return '';
    final bytes = apkSizeBytes!;
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  /// Formatted publish date e.g. "Sep 10, 2026".
  String get formattedPublishedDate {
    if (publishedAt == null) return '';
    return DateFormat('MMM d, yyyy').format(publishedAt!);
  }

  /// Whether a direct APK download link is available.
  bool get hasDirectApk => apkDownloadUrl != null && apkDownloadUrl!.isNotEmpty;

  /// Clean list of bullet points or highlighted changes from the release notes.
  List<String> get highlights {
    final lines = releaseNotes.split('\n');
    final clean = <String>[];
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#') || line.startsWith('---')) continue;
      // Strip markdown bullet symbols
      final stripped = line.replaceFirst(RegExp(r'^[-*+]\s*'), '').trim();
      if (stripped.isNotEmpty) {
        clean.add(stripped);
      }
    }
    return clean;
  }
}
