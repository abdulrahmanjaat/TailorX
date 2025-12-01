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
import '../../../shared/widgets/custom_card.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasRequestedPermission = false;

  @override
  void initState() {
    super.initState();
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
      print('Location service error: $e');
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
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SplashOrb(),
                              const SizedBox(height: AppSizes.lg),
                              Text(
                                'TailorX',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(height: AppSizes.xs),
                              Text(
                                'Luxury workflow intelligence for couture houses',
                                style: AppTextStyles.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSizes.lg),
                              Wrap(
                                spacing: AppSizes.md,
                                runSpacing: AppSizes.md,
                                alignment: WrapAlignment.center,
                                children: const [
                                  _SplashChip(
                                    label: 'Global ateliers online',
                                    value: '58',
                                  ),
                                  _SplashChip(
                                    label: 'Precision fit rate',
                                    value: '99.2%',
                                  ),
                                  _SplashChip(
                                    label: 'Processing orders',
                                    value: '124',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CustomCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.lg,
                            vertical: AppSizes.md,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Crafted precision for modern ateliers',
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.md,
                                  vertical: AppSizes.xs,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                child: Text(
                                  'v1.0.0',
                                  style: AppTextStyles.caption,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _SplashChip extends StatelessWidget {
  const _SplashChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.titleLarge),
        ],
      ),
    );
  }
}
