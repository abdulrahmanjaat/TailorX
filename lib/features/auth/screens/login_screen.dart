import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/auth_shell.dart';
import '../../profile/controllers/profile_controller.dart';
import '../services/auth_service.dart';
import '../widgets/forgot_password_sheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Real-time validation state
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  void initState() {
    super.initState();
    // Add listeners for real-time validation
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    // Only validate if field has content
    if (email.isNotEmpty) {
      final isValid = Validators.emailRequired(email) == null;
      if (_isEmailValid != isValid) {
        setState(() {
          _isEmailValid = isValid;
        });
      }
    } else {
      // Empty field should show normal border
      if (!_isEmailValid) {
        setState(() {
          _isEmailValid = true;
        });
      }
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    // Only validate if field has content
    if (password.isNotEmpty) {
      final isValid = Validators.password(password) == null;
      if (_isPasswordValid != isValid) {
        setState(() {
          _isPasswordValid = isValid;
        });
      }
    } else {
      // Empty field should show normal border
      if (!_isPasswordValid) {
        setState(() {
          _isPasswordValid = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final email = _emailController.text.trim();

      await authRepository.signIn(
        email: email,
        password: _passwordController.text,
      );

      if (mounted) {
        // Finish autofill context to save credentials in password manager
        TextInput.finishAutofillContext(shouldSave: true);

        // Refresh profile to load fresh data from Firestore
        try {
          ref.read(profileProvider.notifier).refreshProfile();
        } catch (_) {
          // Profile provider might not be initialized yet - that's okay,
          // it will load fresh data when the profile screen is accessed
        }

        SnackbarService.showSuccess(context, message: 'Welcome back!');
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        final lowerMessage = errorMessage.toLowerCase();

        // Check if it's a wrong password error - catch all possible Firebase error messages
        final isPasswordError =
            lowerMessage.contains('wrong password') ||
            lowerMessage.contains('incorrect password') ||
            lowerMessage.contains('invalid password') ||
            lowerMessage.contains('password provided') ||
            lowerMessage.contains('supplied auth credential') ||
            lowerMessage.contains('credential is incorrect') ||
            (lowerMessage.contains('credential') &&
                (lowerMessage.contains('incorrect') ||
                    lowerMessage.contains('malformed') ||
                    lowerMessage.contains('expired')));

        if (isPasswordError) {
          SnackbarService.showError(
            context,
            message: 'Incorrect password. Please enter the correct password.',
          );
        } else {
          SnackbarService.showError(context, message: errorMessage);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openForgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ForgotPasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      subtitle: 'Welcome back',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  'Sign in to continue to your workspace',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.dark.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: AppSizes.xxl + AppSizes.lg),
                AppInputField(
                  labelText: 'Email',
                  hintText: 'tailorxteam@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.emailRequired,
                  onChanged: (_) => _validateEmail(),
                  decoration: InputDecoration(
                    hintText: 'tailorxteam@gmail.com',
                    hintStyle: AppTextStyles.inputHint.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.6),
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: AppColors.dark,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: AppColors.dark.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.md,
                    ),
                    constraints: const BoxConstraints(minHeight: 56),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isEmailValid
                            ? AppColors.borderGray
                            : AppColors.error,
                        width: _isEmailValid ? 1 : 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isEmailValid
                            ? AppColors.borderGray
                            : AppColors.error,
                        width: _isEmailValid ? 1 : 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isEmailValid
                            ? AppColors.primary
                            : AppColors.error,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                AppInputField(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: Validators.password,
                  onChanged: (_) => _validatePassword(),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: AppTextStyles.inputHint.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.6),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: AppColors.dark,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.dark.withValues(alpha: 0.5),
                    ),
                    suffixIcon: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          key: ValueKey(_obscurePassword),
                          color: AppColors.dark.withValues(alpha: 0.5),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.md,
                    ),
                    constraints: const BoxConstraints(minHeight: 56),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isPasswordValid
                            ? AppColors.borderGray
                            : AppColors.error,
                        width: _isPasswordValid ? 1 : 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isPasswordValid
                            ? AppColors.borderGray
                            : AppColors.error,
                        width: _isPasswordValid ? 1 : 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isPasswordValid
                            ? AppColors.primary
                            : AppColors.error,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _openForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                      ),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),
                Center(
                  child: AppButton(
                    label: 'Sign In',
                    onPressed: _isLoading ? null : _submit,
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.dark.withValues(alpha: 0.6),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.signup),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign up',
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
