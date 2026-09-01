import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';


abstract final class AppRoutes {
  static const splash = '/';

  static const home = '/home';
  static const settings = '/settings';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, _) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final initialTab = extra?['initialTab'] as int? ?? 0;
        return HomeScreen(initialIndex: initialTab);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (_, _) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
