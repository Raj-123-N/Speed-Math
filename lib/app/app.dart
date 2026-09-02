import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import '../core/services/app_update_service.dart';
import '../core/widgets/update_dialog.dart';

class SpeedMathApp extends StatefulWidget {
  const SpeedMathApp({super.key});

  @override
  State<SpeedMathApp> createState() => _SpeedMathAppState();
}

class _SpeedMathAppState extends State<SpeedMathApp> {
  bool _autoCheckStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_autoCheckStarted) return;
    _autoCheckStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    final service = AppUpdateService();
    try {
      final info = await service.checkForUpdate();
      final navigatorContext = rootNavigatorKey.currentContext;
      if (!mounted || navigatorContext == null || info == null || !info.hasUpdate) return;
      await UpdateDialog.show(navigatorContext, info: info, updateService: service);
    } catch (_) {
      // Update checks are optional and must never block normal app usage.
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      title: 'Speed Math',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
