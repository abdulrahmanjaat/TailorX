import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/auth_shell.dart';
import '../services/auth_service.dart';

class LoginOptionsScreen extends ConsumerStatefulWidget {
  const LoginOptionsScreen({super.key});

  @override
  ConsumerState<LoginOptionsScreen> createState() => _LoginOptionsScreenState();
}

class _LoginOptionsScreenState extends ConsumerState<LoginOptionsScreen> {
  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithGoogle();

      if (mounted) {
        SnackbarService.showSuccess(context, message: 'Welcome!');
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        SnackbarService.showError(context, message: errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

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
                backgroundColor: Colors.white,
                textColor: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Login with Google button
              AppButton(
                label: 'Login with Google',
                onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                isLoading: _isGoogleLoading,
                imageIcon: 'assets/icons/google_icon.png',
                fullWidth: true,
                backgroundColor: Colors.transparent,
                textColor: const Color(0x9915161A), // #15161A99
                borderColor: const Color(0x6615161A), // #15161A66
                borderWidth: 1.0,
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? AppSizes.md : AppSizes.lg),
        ],
      ),
    );
  }
}
