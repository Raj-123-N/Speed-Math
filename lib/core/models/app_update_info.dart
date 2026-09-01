/// Model representing release and update information fetched from GitHub Releases.
class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String tagName;
  final String releaseTitle;
  final String releaseNotes;
  final DateTime? publishedAt;
  final String? apkDownloadUrl;
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
    required this.releaseHtmlUrl,
    required this.hasUpdate,
  });

  factory AppUpdateInfo.fromJson({
    required Map<String, dynamic> json,
    required String currentVersion,
    required bool hasUpdate,
  }) {
    final tagName = json['tag_name'] as String? ?? '';
    final cleanLatestVersion = tagName.replaceFirst(RegExp(r'^v', caseSensitive: false), '');
    final releaseTitle = json['name'] as String? ?? tagName;
    final releaseNotes = json['body'] as String? ?? 'No release notes provided.';
    final releaseHtmlUrl = json['html_url'] as String? ?? '';
    
    DateTime? publishedAt;
    if (json['published_at'] != null) {
      publishedAt = DateTime.tryParse(json['published_at'] as String);
    }

    String? apkDownloadUrl;
    final assets = json['assets'] as List<dynamic>?;
    if (assets != null) {
      for (final asset in assets) {
        if (asset is Map<String, dynamic>) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          if (name.endsWith('.apk')) {
            apkDownloadUrl = asset['browser_download_url'] as String?;
            break;
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
      releaseNotes: 'You are running the latest version.',
      publishedAt: null,
      apkDownloadUrl: null,
      releaseHtmlUrl: '',
      hasUpdate: false,
    );
  }
}
