import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../shared/widgets/auth_shell.dart';

class LoginOptionsScreen extends StatelessWidget {
  const LoginOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return AuthShell(
      hideBrandMark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallScreen ? AppSizes.md : AppSizes.lg),
          // Logo circle in upper left
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppColors.dark.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: 44,
              width: 44,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: isSmallScreen ? AppSizes.md : AppSizes.lg),
          // Title with each word on separate line
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Where',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: isSmallScreen ? 32 : 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,

                  height: 1.1,
                ),
              ),
              Text(
                'Precision',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: isSmallScreen ? 32 : 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,

                  height: 1.1,
                ),
              ),
              Text(
                'Meets',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: isSmallScreen ? 32 : 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,

                  height: 1.1,
                ),
              ),
              Text(
                'Perfection!',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: isSmallScreen ? 32 : 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,

                  height: 1.1,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? AppSizes.sm : AppSizes.md),
          // Subtitle
          Text(
            'Manage your tailoring business, track orders, and deliver excellence with every stitch.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.dark.withValues(alpha: 0.65),
              fontWeight: FontWeight.w400,
              fontSize: isSmallScreen ? 15 : 16,
              height: 1.5,
            ),
          ),
          const Spacer(),
          // Buttons at bottom
          Column(
            children: [
              // Sign up button
              AppButton(
                label: 'Sign up',
                onPressed: () => context.go(AppRoutes.signup),
                fullWidth: true,
              ),
              const SizedBox(height: 14),
              // Login button
              AppButton(
                label: 'Login',
                onPressed: () => context.go(AppRoutes.login),
                fullWidth: true,
              ),
              const SizedBox(height: 14),
              // Continue with Phone Number button
              AppButton(
                label: 'Continue with Phone Number',
                onPressed: () => context.go(AppRoutes.phoneLogin),
                icon: Icons.phone_outlined,
                fullWidth: true,
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? AppSizes.md : AppSizes.lg),
        ],
      ),
    );
  }
}
