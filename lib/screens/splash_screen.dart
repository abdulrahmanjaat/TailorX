import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

class PremiumSplashScreen extends StatefulWidget {
  const PremiumSplashScreen({super.key});

  @override
  State<PremiumSplashScreen> createState() => _PremiumSplashScreenState();
}

class _PremiumSplashScreenState extends State<PremiumSplashScreen> {
  static const Duration _splashDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  void _navigateAfterSplash() async {
    await Future.delayed(_splashDuration);

    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize =
        (size.width * 0.45).clamp(140.0, 260.0); // responsive sizing
    final headingSpacing = size.height * 0.03;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.6,
                    colors: const [
                      AppColors.onyx,
                      AppColors.charcoal,
                    ],
                    stops: const [0.2, 1],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(painter: _GoldenParticlesPainter()),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.3),
                              blurRadius: 36,
                              spreadRadius: 6,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.7),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'lib/assets/images/logo.png',
                          width: logoSize,
                          color: Colors.white,
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .scaleXY(
                              begin: 0.75,
                              end: 1.05,
                              curve: Curves.easeOutBack,
                            )
                            .then()
                            .scaleXY(begin: 1.05, end: 1.0),
                      ),
                      SizedBox(height: headingSpacing),
                      Column(
                        children: [
                          Text(
                            'TailorX',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.gold,
                              fontSize: 32.sp,
                              letterSpacing: 6,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideY(
                                begin: 0.35,
                                end: 0,
                                curve: Curves.easeOut,
                              ),
                          SizedBox(height: 10.h),
                          Text(
                            'CRAFTING ELEGANCE SINCE 1995',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              letterSpacing: 3,
                            ),
                          ).animate().fadeIn(delay: 550.ms),
                          SizedBox(height: 18.h),
                          Container(
                            width: 140.w,
                            height: 1.2,
                            color: AppColors.gold.withValues(alpha: 0.35),
                          ).animate().scaleX(
                                delay: 800.ms,
                                duration: 500.ms,
                                curve: Curves.easeOut,
                              ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                      CustomPaint(
                        size: Size(220.w, 24.h),
                        painter: _GoldenThreadPainter(),
                      ).animate().scaleX(
                            delay: 1100.ms,
                            duration: 700.ms,
                            curve: Curves.elasticOut,
                          ),
                      SizedBox(height: 36.h),
                      const _GoldenStitchIndicator()
                          .animate()
                          .fadeIn(delay: 1400.ms),
                    ],
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

// ---------- Custom Painters & Widgets ----------

// Golden Particles Background
class _GoldenParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final rng = _SeededRandom(42);

    for (int i = 0; i < 50; i++) {
      final radius = rng.nextDouble() * 3 + 1;
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Golden Thread Painter
class _GoldenThreadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double x = 0; x < size.width; x += 10) {
      path.quadraticBezierTo(
        x + 5,
        size.height / 2 + (x % 20 == 0 ? -8 : 8),
        x + 10,
        size.height / 2,
      );
    }

    canvas.drawPath(path, paint);

    // Stitch marks
    final stitchPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2;

    for (double x = 5; x < size.width; x += 15) {
      canvas.drawLine(
        Offset(x, size.height / 2 - 4),
        Offset(x, size.height / 2 + 4),
        stitchPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Golden Stitch Loading Indicator
class _GoldenStitchIndicator extends StatefulWidget {
  const _GoldenStitchIndicator();

  @override
  State<_GoldenStitchIndicator> createState() => _GoldenStitchIndicatorState();
}

class _GoldenStitchIndicatorState extends State<_GoldenStitchIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(100, 20),
          painter: _StitchAnimationPainter(_controller.value),
        );
      },
    );
  }
}

class _StitchAnimationPainter extends CustomPainter {
  final double animationValue;

  _StitchAnimationPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const stitchCount = 5;
    final activeStitch = (animationValue * stitchCount).floor();

    for (int i = 0; i < stitchCount; i++) {
      final x = size.width / (stitchCount - 1) * i;
      final isActive = i == activeStitch % stitchCount;

      canvas.drawLine(
        Offset(x, size.height / 2 - 6),
        Offset(x, size.height / 2 + 6),
        paint..color = isActive
            ? const Color(0xFFD4AF37).withValues(alpha: 0.8)
            : const Color(0xFFD4AF37).withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Helper: Seeded random for particles
class _SeededRandom {
  int seed;
  _SeededRandom(this.seed);

  double nextDouble() {
    seed = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
    return seed / 0x7FFFFFFF;
  }
}
