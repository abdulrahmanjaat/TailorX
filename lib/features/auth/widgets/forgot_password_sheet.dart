import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/custom_card.dart';
import '../services/auth_service.dart';

class ForgotPasswordSheet extends ConsumerStatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  ConsumerState<ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    // Capture navigator before any async operations
    // This ensures we can close the sheet before showing snackbars
    final navigator = Navigator.of(context);

    try {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        // For validation errors, show immediately without closing sheet
        SnackbarService.showError(
          context,
          message: 'Please enter your email address.',
        );
        setState(() => _isLoading = false);
        return;
      }

      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.resetPassword(email: email);

      // Success: Close sheet first, then show success snackbar
      if (mounted) {
        navigator.pop();
        // Use SnackbarService for proper green success styling
        SnackbarService.showSuccess(
          context,
          message:
              'Password reset email sent! Please check your inbox and spam folder. If you don\'t see it, try again in a few minutes.',
        );
      }
    } catch (e) {
      // Error: Close sheet first, then show error snackbar
      if (mounted) {
        navigator.pop();
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        // Use SnackbarService for proper red error styling
        SnackbarService.showError(
          context,
          message: errorMessage.isNotEmpty
              ? errorMessage
              : 'Failed to send password reset email. Please try again or contact support at tailorxteam@gmail.com',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      initialChildSize: 0.65,
      builder: (context, controllerScroll) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: controllerScroll,
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text('Reset Password', style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                CustomCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppInputField(
                          labelText: 'Email',
                          hintText: 'tailorxteam@gmail.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        AppButton(
                          label: 'Send Reset Link',
                          onPressed: _isLoading ? null : _handleReset,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
