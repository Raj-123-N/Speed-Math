import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/theme/theme_provider.dart';
import 'core/services/app_engagement_service.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await AppEngagementService.instance.recordOpen();
  try {
    await NotificationService.instance.initialize();
    await NotificationService.instance.syncSchedules();
  } catch (_) {
    // Notifications are optional; app startup must never depend on them.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const SpeedMathApp(),
    ),
  );
}
