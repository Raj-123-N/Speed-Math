import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _fadeAnim;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoSlideAnim;
  late Animation<double> _textFadeAnim;
  late Animation<double> _pulseAnim;

  bool _navigationCancelled = false;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _logoScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoSlideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_navigationCancelled && mounted) _logoCtrl.forward();
    });
    _scheduleNavigation();
  }

  Future<void> _scheduleNavigation() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (_navigationCancelled || !mounted) return;

    var initialTab = 1;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDate = prefs.getString('last_date');
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (lastDate == today) {
        initialTab = prefs.getInt('last_tab') ?? 1;
      } else {
        await prefs.setString('last_date', today);
        await prefs.setInt('last_tab', 1);
      }
    } catch (_) {}

    if (!mounted || _navigationCancelled) return;
    context.go(AppRoutes.home, extra: {'initialTab': initialTab});
  }

  @override
  void dispose() {
    _navigationCancelled = true;
    _fadeCtrl.dispose();
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── Ambient background blobs ──────────────────────────────────
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: size.width * .7,
                height: size.width * .7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: .10),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: size.width * .65,
                height: size.width * .65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.module2Color.withValues(alpha: .08),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _logoSlideAnim.value),
                  child: Transform.scale(
                    scale: _logoScaleAnim.value,
                    child: child,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: _pulseAnim.value,
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.gradOrangeStart, AppColors.gradOrangeEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: .28),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Lottie.asset(AppAssets.logoAnimation, repeat: true),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _textFadeAnim,
                      child: Column(
                        children: [
                          Text(
                            'SPEED MATH',
                            style: AppTypography.displaySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Practice. Improve. Master.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white70,
                              letterSpacing: .4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
