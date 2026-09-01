import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

class SpeedMathApp extends StatelessWidget {
  const SpeedMathApp({super.key});

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
