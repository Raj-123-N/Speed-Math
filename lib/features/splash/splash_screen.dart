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
      if (mounted) _logoCtrl.forward();
    });

    // Navigate after delay
    Future.delayed(const Duration(milliseconds: 2800), () async {
      int initialTab = 1;
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
      if (mounted) {
        context.go(AppRoutes.home, extra: {'initialTab': initialTab});
      }
    });
  }

  @override
  void dispose() {
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
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Floating math symbols (decorative) ───────────────────────
            ..._buildFloatingSymbols(size),

            // ── Main content ─────────────────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _logoCtrl,
                builder: (_, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing glow ring + logo
                      Transform.translate(
                        offset: Offset(0, _logoSlideAnim.value),
                        child: Transform.scale(
                          scale: _logoScaleAnim.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow ring
                              ScaleTransition(
                                scale: _pulseAnim,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primary.withValues(alpha: 0.25),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Inner ring
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.surfaceDark,
                                      AppColors.backgroundDark,
                                    ],
                                  ),
                                ),
                              ),
                              // Logo
                              ClipOval(
                                child: Image.asset(
                                  AppAssets.iconLogo,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.calculate_rounded, size: 52, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // App name
                      FadeTransition(
                        opacity: _textFadeAnim,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [AppColors.gradOrangeStart, AppColors.gradOrangeEnd],
                              ).createShader(bounds),
                              child: Text(
                                'SPEED MATH',
                                style: AppTypography.displayLarge.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Practice · Master · Excel',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondaryDark,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Lottie loader
                      FadeTransition(
                        opacity: _textFadeAnim,
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: Lottie.asset(
                            AppAssets.animMathLoader,
                            fit: BoxFit.contain,
                            repeat: true,
                            errorBuilder: (_, _, _) => const CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Version label ─────────────────────────────────────────────
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textFadeAnim,
                child: Text(
                  'Vedic Math · Quick Math · Mental Math',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textHintDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingSymbols(Size size) {
    const symbols = ['÷', '+', '×', '−', '²', '√', '%', 'π'];
    final positions = [
      Offset(0.1, 0.1), Offset(0.85, 0.08), Offset(0.05, 0.45),
      Offset(0.9, 0.38), Offset(0.12, 0.75), Offset(0.82, 0.7),
      Offset(0.45, 0.05), Offset(0.5, 0.9),
    ];

    return List.generate(symbols.length, (i) {
      return Positioned(
        left: positions[i].dx * size.width,
        top: positions[i].dy * size.height,
        child: FadeTransition(
          opacity: _textFadeAnim,
          child: Text(
            symbols[i],
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 22 + (i % 3) * 8.0,
              fontWeight: FontWeight.w900,
              color: AppColors.primary.withValues(alpha: 0.08 + (i % 3) * 0.04),
            ),
          ),
        ),
      );
    });
  }
}
