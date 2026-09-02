import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtilityService {
  AppUtilityService._();
  static final AppUtilityService instance = AppUtilityService._();

  static const String appUrl = 'https://github.com/Raj-123-N/Speed-Math';

  Future<void> shareApp() async {
    await Share.share('Practice mental maths with Speed Math. $appUrl');
  }

  Future<bool> rateApp() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
      return true;
    }
    final info = await PackageInfo.fromPlatform();
    final uri = Uri.parse('$appUrl/releases?q=${Uri.encodeComponent(info.version)}');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
