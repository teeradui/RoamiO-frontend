import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roamio_frontend/screens/authentication/authentication_screen.dart';
import 'package:roamio_frontend/screens/authentication/animated_roamio_logo.dart';
import 'package:roamio_frontend/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _taglineController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  final String _appName = 'RoamiO';

  @override
  void initState() {
    super.initState();

    // =========================
    // LOGO
    // =========================

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    // =========================
    // RoamiO
    // =========================

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // =========================
    // TAGLINE
    // =========================

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Logo
    await _logoController.forward();

    // เว้นนิดนึง
    await Future.delayed(
      const Duration(milliseconds: 150),
    );

    // ตัวอักษรทีละตัว
    _textController.forward();

    // รอจนตัวอักษรเกือบครบ
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    // Tagline
    await _taglineController.forward();

    // ค้างไว้
    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            const AuthenticationScreen(),
        transitionDuration: const Duration(
          milliseconds: 500,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [


            FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: const AnimatedRoamiOLogo(
                  width: 145,
                  height: 155,
                ),
              ),
            ),

            const SizedBox(height: 8),


            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _appName.length,
                    (index) {
                      // แต่ละตัวเริ่มห่างกัน 250ms
                      final start =
                          index * 0.13;

                      final end =
                          start + 0.19;

                      final progress =
                          ((_textController.value - start) /
                                  (end - start))
                              .clamp(0.0, 1.0);

                      final curvedProgress =
                          Curves.elasticOut.transform(
                        progress,
                      );

                      return Transform.translate(
                        offset: Offset(
                          0,
                          32 * (1 - curvedProgress),
                        ),
                        child: Opacity(
                          opacity: progress,
                          child: Transform.scale(
                            scale: 0.5 +
                                (0.5 * curvedProgress),
                            child: Text(
                              _appName[index],
                              style: GoogleFonts.fredoka(
                                color: AppColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 6),

            // =========================
            // TAGLINE
            // =========================

            FadeTransition(
              opacity: _taglineController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _taglineController,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Text(
                  'Your journey, together.',
                  style: GoogleFonts.nunito(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}