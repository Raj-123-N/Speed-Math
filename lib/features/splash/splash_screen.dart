import 'dart:async';

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
  late AnimationController _lottieCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _fadeAnim;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<double> _lottieFadeAnim;
  late Animation<double> _lottieScaleAnim;
  late Animation<double> _textFadeAnim;
  late Animation<double> _textSlideAnim;

  Timer? _lottieTimer;
  Timer? _textTimer;
  Timer? _navigationTimer;
  bool _navigationCancelled = false;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _lottieCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    // Phase 1: Logo scale & fade
    _logoScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFadeAnim = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);

    // Phase 2: Lottie animation fade & gentle scale
    _lottieFadeAnim = CurvedAnimation(parent: _lottieCtrl, curve: Curves.easeIn);
    _lottieScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _lottieCtrl, curve: Curves.easeOutBack),
    );

    // Phase 3: Text fade & subtle slide
    _textFadeAnim = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlideAnim = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );

    _fadeCtrl.forward();
    _logoCtrl.forward();

    _lottieTimer = Timer(const Duration(milliseconds: 700), () {
      if (!_navigationCancelled && mounted) _lottieCtrl.forward();
    });

    _textTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!_navigationCancelled && mounted) _textCtrl.forward();
    });

    _navigationTimer = Timer(
      const Duration(milliseconds: 3200),
      _navigateToHome,
    );
  }

  Future<void> _navigateToHome() async {
    if (_navigationCancelled || !mounted) return;

    var initialTab = 1;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_navigationCancelled || !mounted) return;

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
    _lottieTimer?.cancel();
    _textTimer?.cancel();
    _navigationTimer?.cancel();
    _fadeCtrl.dispose();
    _logoCtrl.dispose();
    _lottieCtrl.dispose();
    _textCtrl.dispose();
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
            // Ambient glowing circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: size.width * .7,
                height: size.width * .7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: .12),
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
                  color: AppColors.module2Color.withValues(alpha: .10),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phase 1: App Logo
                  FadeTransition(
                    opacity: _logoFadeAnim,
                    child: ScaleTransition(
                      scale: _logoScaleAnim,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: .30),
                              blurRadius: 28,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            AppAssets.iconLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.calculate_rounded,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Phase 2: Lottie animation
                  FadeTransition(
                    opacity: _lottieFadeAnim,
                    child: ScaleTransition(
                      scale: _lottieScaleAnim,
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Lottie.asset(
                          AppAssets.animMathLoader,
                          repeat: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Phase 3: SPEED MATH by Rajan
                  AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _textSlideAnim.value),
                      child: FadeTransition(
                        opacity: _textFadeAnim,
                        child: child,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SPEED MATH',
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 1.5,
                              color: AppColors.primary.withValues(alpha: .6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'by Rajan',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 18,
                              height: 1.5,
                              color: AppColors.primary.withValues(alpha: .6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
