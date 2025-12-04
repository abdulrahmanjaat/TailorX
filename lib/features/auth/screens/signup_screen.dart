import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/auth_shell.dart';
import '../services/auth_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _initialCountryCode;

  // Real-time validation state
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  void initState() {
    super.initState();
    _loadCountryCode();
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

  Future<void> _loadCountryCode() async {
    final countryCode = await SecureStorageService.instance.getCountryCode();
    if (mounted) {
      setState(() {
        _initialCountryCode = countryCode ?? 'PK';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final phoneNumber = _phoneNumber?.completeNumber;

      await authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userName: _nameController.text.trim(),
        shopName: _organizationController.text.trim(),
        phoneNumber: phoneNumber,
      );

      if (mounted) {
        SnackbarService.showSuccess(
          context,
          message: 'Account created successfully!',
        );
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
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
    return AuthShell(
      subtitle: 'Get started',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get Started',
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
                'Create your account to begin your journey',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.dark.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: AppSizes.xxl + AppSizes.lg),
              AppInputField(
                labelText: 'Full name',
                hintText: 'Abdul Rahman',
                controller: _nameController,
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Name'),
                prefix: Icon(
                  Icons.person_outline,
                  color: AppColors.dark.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              AppInputField(
                labelText: 'Shop / Studio',
                hintText: 'TailorX',
                controller: _organizationController,
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Studio'),
                prefix: Icon(
                  Icons.store_outlined,
                  color: AppColors.dark.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              AppInputField(
                labelText: 'Email',
                hintText: 'team@tailorx.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.emailRequired,
                onChanged: (_) => _validateEmail(),
                decoration: InputDecoration(
                  hintText: 'team@tailorx.com',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Number',
                    style: AppTextStyles.bodyRegular.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  _initialCountryCode == null
                      ? const SizedBox(
                          height: 56,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : IntlPhoneField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: 'Enter phone number',
                            hintStyle: AppTextStyles.inputHint.copyWith(
                              color: AppColors.dark.withValues(alpha: 0.6),
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.dark,
                              fontWeight: FontWeight.w500,
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
                              borderSide: const BorderSide(
                                color: AppColors.borderGray,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGray,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
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
                          initialCountryCode: _initialCountryCode ?? 'PK',
                          onChanged: (phone) {
                            setState(() {
                              _phoneNumber = phone;
                            });
                          },
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (phone.number.length < 10) {
                              return 'Phone number must be at least 10 digits';
                            }
                            return null;
                          },
                        ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              AppInputField(
                labelText: 'Password',
                hintText: 'Create a strong password (min 8 characters)',
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: Validators.password,
                onChanged: (_) => _validatePassword(),
                decoration: InputDecoration(
                  hintText: 'Create a strong password (min 8 characters)',
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
              const SizedBox(height: AppSizes.xl),
              Center(
                child: AppButton(
                  label: 'Create account',
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Login',
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
    );
  }
}
