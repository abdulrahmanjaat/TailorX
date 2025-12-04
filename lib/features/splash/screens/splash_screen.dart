import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  bool _hasRequestedPermission = false;
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  final List<Animation<double>> _charAnimations = [];

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeIn),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeOut),
    );

    // Text animation controller - starts after logo animation
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Create staggered animations for each character
    const text = 'TailorX';
    for (int i = 0; i < text.length; i++) {
      final start = i * 0.1; // Stagger each character by 0.1 seconds
      final end = start + 0.5; // Each character animates for 0.5 seconds

      _charAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _textAnimationController,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }

    // Start logo animation
    _logoAnimationController.forward();

    // Start text animation after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _textAnimationController.forward();
      }
    });

    // Request location permission after the screen is visible
    // Add a small delay to ensure the UI is fully ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _requestLocationPermission();
        }
      });
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    if (_hasRequestedPermission) return;
    _hasRequestedPermission = true;

    try {
      // Request location permission and get country code
      // This will show the system permission dialog if needed
      final countryCode = await LocationService.instance.getCountryCode();
      if (countryCode != null && mounted) {
        await SecureStorageService.instance.setCountryCode(countryCode);
      }
    } catch (e) {
      // Silently handle errors - app will work without location
      debugPrint('Location service error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashControllerProvider, (previous, next) async {
      if (next.isReady && previous?.isReady != true) {
        // Use middleware to determine initial route
        final initialRoute = await AuthMiddleware.getInitialRoute(ref);
        if (context.mounted) {
          context.go(initialRoute);
        }
      }
    });
    ref.watch(splashControllerProvider);

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: AuroraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: _SplashOrb(),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      _AnimatedText(
                        text: 'TailorX',
                        charAnimations: _charAnimations,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedText extends StatelessWidget {
  const _AnimatedText({
    required this.text,
    required this.charAnimations,
    required this.style,
  });

  final String text;
  final List<Animation<double>> charAnimations;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(text.length, (index) {
        return AnimatedBuilder(
          animation: charAnimations[index],
          builder: (context, child) {
            return Opacity(
              opacity: charAnimations[index].value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - charAnimations[index].value)),
                child: Text(text[index], style: style),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SplashOrb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
          ),
          Positioned(
            top: 18,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 72,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
