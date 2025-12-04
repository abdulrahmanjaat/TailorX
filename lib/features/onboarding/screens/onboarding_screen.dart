import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/theme/app_buttons.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Reset onboarding state immediately when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = ref.read(onboardingControllerProvider.notifier);

        // Always reset to ensure clean state after logout/delete
        controller.reset();

        // Ensure PageController is at first page
        if (_pageController.hasClients && _pageController.page != 0) {
          _pageController.jumpToPage(0);
        }

        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(onboardingPagesProvider);
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    ref.listen<OnboardingState>(onboardingControllerProvider, (
      previous,
      next,
    ) async {
      if (next.completed && previous?.completed != true) {
        // Mark onboarding as seen
        await SecureStorageService.instance.setHasSeenOnboarding(true);
        if (context.mounted) {
          context.go(AppRoutes.loginOptions);
        }
        return;
      }
      // Only animate if initialized and PageController is ready
      if (_isInitialized &&
          _pageController.hasClients &&
          previous?.index != next.index &&
          next.index < pages.length &&
          next.index >= 0) {
        _pageController.animateToPage(
          next.index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });

    return AppScaffold(
      padding: EdgeInsets.zero,
      showBackButton: false,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                  vertical: AppSizes.md,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TailorX', style: AppTextStyles.titleLarge),
                        Text(
                          'Immersive atelier onboarding',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.skip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: AppSizes.sm,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Skip',
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    // Only update index if initialized to prevent conflicts
                    if (_isInitialized) {
                      controller.updateIndex(index);
                    }
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                      ),
                      child: _OnboardingSlide(page: page, index: index),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                  vertical: AppSizes.lg,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSizes.xs,
                          ),
                          width: state.index == index ? 36 : 10,
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: state.index == index
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                  )
                                : null,
                            color: state.index == index
                                ? null
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppButton(
                      label: state.index == pages.length - 1
                          ? 'Launch workspace'
                          : 'Continue',
                      onPressed: controller.next,
                      icon: Icons.arrow_forward,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.page, required this.index});

  final OnboardingPage page;
  final int index;

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [AppColors.primary, AppColors.secondary],
      [AppColors.secondary, AppColors.primary.withValues(alpha: 0.8)],
      [
        AppColors.primary.withValues(alpha: 0.9),
        AppColors.secondary.withValues(alpha: 0.7),
      ],
    ];

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.xl),
      gradient: LinearGradient(
        colors: gradients[index % gradients.length],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Icon(page.icon, size: 40, color: Colors.white),
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                '0${index + 1}',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            page.title,
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            page.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Container(
            height: 1.5,
            width: 80,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'Swipe to explore how TailorX elevates every atelier touchpoint.',
            style: AppTextStyles.bodyRegular.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
